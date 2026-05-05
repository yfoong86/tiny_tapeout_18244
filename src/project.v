/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_yfoong86_chasey (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  // All output pins must be assigned. If not used, assign to 0.
  assign uio_out = 8'd0;
  assign uio_oe  = 8'b11111111;

  // ui_in[0] is rst_n
  // ui_in[1] is btn_left
  // ui_in[2] is btn_right
  // ui_in[3] is btn_up
  // ui_in[4] is btn_down
  // uo_out[0] is vga_r1
  // uo_out[1] is vga_g1
  // uo_out[2] is vga_b1
  // uo_out[3] is vga_vs
  // uo_out[4] is vga_r0
  // uo_out[5] is vga_g0
  // uo_out[6] is vga_b0
  // uo_out[7] is vga_hs

  ChipInterface c0(.clk, .btn_rst(rst_n || ~ui_in[0]),
                   .btn_left(ui_in[1]), 
                   .btn_right(ui_in[2]), 
                   .btn_up(ui_in[3]), 
                   .btn_down(ui_in[4]),
                   .vga_r0(uo_out[4]), .vga_r1(uo_out[0]),
                   .vga_g0(uo_out[5]), .vga_g1(uo_out[1]),
                   .vga_b0(uo_out[6]), .vga_b1(uo_out[2]),
                   .vga_hs(uo_out[7]), .vga_vs(uo_out[3]));
  
  // List all unused inputs to prevent warnings
  wire _unused = &{ena, 1'b0};
  wire unused2 = &{uio_in, 8'd0};
  wire unused3 = &{ui_in[7:5], 3'd0};

endmodule
