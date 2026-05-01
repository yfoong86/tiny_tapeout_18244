module horizontal_counter 
(
    input logic clk, rst_n,
    output reg [15:0] col,
    output logic enable_V_counter
);
    initial col = 0;
    always @(posedge clk, negedge rst_n) begin
        if (~rst_n) begin
            col <= 0;
            enable_V_counter <= 1;
        end
        else if (col < 799) begin
            col <= col + 1;
            enable_V_counter <= 0;
        end
        else begin
            col <= 0;
            enable_V_counter <= 1;
        end
    end
endmodule: horizontal_counter

module vertical_counter
(
    input logic clk, rst_n,
    input logic enable_V_counter,
    output reg [15:0] row
);
	initial row = 0;
    always @(posedge clk) begin
        if (~rst_n) row <= 0;
        else if (enable_V_counter == 1'b1) begin
            if (row < 524) begin
                row <= row + 1;
            end
            else begin
                row <= 0;
            end
        end
    end
endmodule: vertical_counter