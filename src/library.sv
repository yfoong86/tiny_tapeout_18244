// `default_nettype none

module Comparator
    #(parameter WIDTH = 16)
    (input logic [WIDTH-1:0]A, B,
     output logic AeqB);

    assign AeqB = (A == B);
endmodule: Comparator

module MagComp
    #(parameter WIDTH = 16)
    (input logic [WIDTH-1:0]A, B,
     output logic AltB, AeqB, AgtB);

    assign AltB = (A < B);
    assign AeqB = (A == B);
    assign AgtB = (A > B);

endmodule: MagComp

module Register
    #(parameter WIDTH = 16)
    (input logic en, clear, clock,
    input logic [WIDTH-1:0]D,
    output logic [WIDTH-1:0]Q);

    always_ff @(posedge clock) begin
        if (en) Q <= D;
        else if (clear) Q <= '0;
    end
endmodule: Register

module Counter
    #(parameter WIDTH = 16)
    (input logic en, clear, load, up, clock,
    input logic [WIDTH-1:0]D,
    output logic [WIDTH-1:0]Q);

    always_ff @(posedge clock) begin
        if (clear) Q <= 0;
        else if (load) Q <= D;
        else if (en)
            if (up)
                Q <= Q + 1;
            else if (~up)
                Q <= Q - 1;
    end
endmodule: Counter

module Synchronizer
    (input logic async, clock,
    output logic sync);
    logic temp;

    always_ff @(posedge clock) begin
        temp <= async;
        sync <= temp;
    end

endmodule: Synchronizer

module RangeCheck
    #(parameter WIDTH = 16)
    (input logic [WIDTH-1:0]val, high, low,
    output logic is_between);

    assign is_between = (val <= high) & (val >= low);
endmodule: RangeCheck

module OffsetCheck
    #(parameter WIDTH = 16)
    (input logic [WIDTH-1:0]val, delta, low,
    output logic is_between);

    logic [WIDTH-1:0] high;

    assign high = low + delta;

    RangeCheck #(.WIDTH(WIDTH)) u_RangeCheck (
        .val(val),
        .low(low),
        .high(high),
        .is_between(is_between)
    );

endmodule: OffsetCheck
