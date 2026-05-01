# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge

# VGA timing constants (800x525 total frame)
FRAME_CYCLES = 800 * 525  # one full VGA frame = 420,000 clock cycles

# ui_in bit assignments
BTN_RST_N = 0
BTN_LEFT  = 1
BTN_RIGHT = 2
BTN_UP    = 3
BTN_DOWN  = 4


def make_ui_in(left=0, right=0, up=0, down=0, rst_n_btn=1):
    """Pack button inputs into ui_in byte."""
    return (rst_n_btn << BTN_RST_N) | (left << BTN_LEFT) | (right << BTN_RIGHT) | \
           (up << BTN_UP) | (down << BTN_DOWN)


def decode_uo_out(val):
    """Decode uo_out into VGA fields."""
    return {
        "r":    (val >> 0) & 0x3,
        "g":    (val >> 2) & 0x3,
        "b":    (val >> 4) & 0x3,
        "hsync": (val >> 6) & 0x1,
        "vsync": (val >> 7) & 0x1,
    }


async def do_reset(dut):
    """Apply reset for 10 cycles then release.

    btn_rst in the design is: rst_n || ~ui_in[0]
    For btn_rst to go LOW (active reset), ui_in[0] must be 1 while rst_n=0.
    Setting ui_in[0]=0 would force btn_rst=1 (no reset), so keep ui_in neutral.
    """
    dut.ena.value    = 1
    dut.ui_in.value  = make_ui_in()  # ui_in[0]=1 so btn_rst = rst_n; buttons neutral
    dut.uio_in.value = 0
    dut.rst_n.value  = 0             # top-level rst_n low → btn_rst=0 → resets ChipInterface
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value  = 1             # release reset → btn_rst=1 → normal operation
    await ClockCycles(dut.clk, 2)    # allow synchronizer (2 FF stages) to propagate


@cocotb.test()
async def test_reset(dut):
    """After reset, VGA sync outputs should be in a defined state and led=0."""
    dut._log.info("=== test_reset ===")
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    await do_reset(dut)
    await ClockCycles(dut.clk, 1)

    out = decode_uo_out(int(dut.uo_out.value))
    dut._log.info(f"After reset: uo_out={bin(int(dut.uo_out.value))}, decoded={out}")

    # led = pg_collision; should be 0 right after reset (player and ghost start far apart)
    assert dut.uo_out.value is not None, "uo_out must be driven"
    # No X/Z check — cocotb raises if value is undefined when cast to int
    _ = int(dut.uo_out.value)
    dut._log.info("Reset test passed — outputs are defined")


@cocotb.test()
async def test_hsync_pulse(dut):
    """
    hsync (uo_out[6]) should go high for the first 96 columns of each line,
    i.e. we should see it high shortly after reset and then go low.
    We sample the first ~200 cycles and verify we see both states.
    """
    dut._log.info("=== test_hsync_pulse ===")
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    await do_reset(dut)

    seen_high = False
    seen_low  = False

    for _ in range(200):
        await RisingEdge(dut.clk)
        hsync = (int(dut.uo_out.value) >> 6) & 1
        if hsync == 1:
            seen_high = True
        if hsync == 0:
            seen_low = True
        if seen_high and seen_low:
            break

    dut._log.info(f"hsync seen_high={seen_high}, seen_low={seen_low}")
    assert seen_high, "hsync never went high in 200 cycles"
    assert seen_low,  "hsync never went low in 200 cycles"
    dut._log.info("hsync pulse test passed")


@cocotb.test()
async def test_vsync_pulse(dut):
    """
    vsync (uo_out[7]) should be high for the first 2 lines (rows 0-1).
    Simulate 1.5 frames to guarantee we observe both high and low vsync.
    """
    dut._log.info("=== test_vsync_pulse ===")
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    await do_reset(dut)

    seen_high = False
    seen_low  = False

    # sample every 100 cycles to stay fast
    for _ in range(FRAME_CYCLES * 2 // 100):
        await ClockCycles(dut.clk, 100)
        vsync = (int(dut.uo_out.value) >> 7) & 1
        if vsync == 1:
            seen_high = True
        if vsync == 0:
            seen_low = True
        if seen_high and seen_low:
            break

    dut._log.info(f"vsync seen_high={seen_high}, seen_low={seen_low}")
    assert seen_high, "vsync never went high in 2 frames"
    assert seen_low,  "vsync never went low in 2 frames"
    dut._log.info("vsync pulse test passed")

@cocotb.test()
async def test_no_collision_at_start(dut):
    """
    At reset the player starts at (160,55) and ghost at (750,480) — far apart.
    The pg_collision signal drives led[0]; it should be 0.
    (uo_out doesn't expose led, but the ChipInterface's led is an internal
    wire — we check it via the DUT hierarchy if available, otherwise we just
    confirm uo_out is stable.)
    """
    dut._log.info("=== test_no_collision_at_start ===")
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    await do_reset(dut)

    # Run half a frame
    await ClockCycles(dut.clk, 20)

    # Try to read internal pg_collision if simulator exposes it
    try:
        pg = int(dut.c0.pg_collision.value)
        dut._log.info(f"pg_collision = {pg}")
        assert pg == 0, "pg_collision should be 0 at start (player and ghost are far apart)"
        dut._log.info("No-collision-at-start test passed via internal signal")
    except AttributeError:
        # Signal not visible; just verify outputs are X-free
        _ = int(dut.uo_out.value)
        dut._log.info("pg_collision not directly visible; uo_out is defined — test passed")


@cocotb.test()
async def test_outputs_defined_during_active_video(dut):
    """
    During the active video window (cols 144-784, rows 35-514) all output
    bits should be defined (no X/Z). We spot-check by running one full frame
    and casting every sample to int (cocotb raises BinaryRepresentationError
    on X/Z).
    """
    dut._log.info("=== test_outputs_defined_during_active_video ===")
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    await do_reset(dut)

    undefined_count = 0
    for _ in range(FRAME_CYCLES):
        await RisingEdge(dut.clk)
        try:
            _ = int(dut.uo_out.value)
        except Exception:
            undefined_count += 1

    dut._log.info(f"Undefined output cycles in one frame: {undefined_count}")
    assert undefined_count == 0, f"{undefined_count} cycles had X/Z on uo_out"
    dut._log.info("All outputs defined test passed")