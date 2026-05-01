module draw_player
    (input logic clk, rst_n,
     input logic [15:0] row, col,
     input logic left, right, up, down,
     input logic en_cond,
     input logic collision,
     output logic [1:0] red, green, blue,
     output logic [15:0] player_x, player_y,
     output logic [15:0] nplayer_x, nplayer_y);
        
    logic [15:0] player_size; // player size

    assign player_size = 16'd15;

    always_comb begin
        nplayer_x = player_x;
        nplayer_y = player_y;

        if (left) begin
            nplayer_x = player_x - 16'd3;
        end
        else if (right) begin
            nplayer_x = player_x + 16'd3;
        end
        
        //y dir
        else if (up) begin
            nplayer_y = player_y - 16'd3;
        end
        else if (down) begin
            nplayer_y = player_y + 16'd3;
        end
    end

    always_ff @(posedge clk, negedge rst_n) begin
        if (~rst_n) begin
            player_x <= 16'd160;
            player_y <= 16'd55;
        end
        else if (en_cond && ~collision) begin
            if ((nplayer_x > (141 + player_size)) && (nplayer_x < (774 - player_size))) begin
                player_x <= nplayer_x;
            end
            if ((nplayer_y > (30 + player_size)) && (nplayer_y < (504 - player_size))) begin
                player_y <= nplayer_y;
            end
        end
    end

    always_comb begin
        if (((col < (player_x + player_size)) && (col > player_x)) && 
            (row < (player_y + player_size)) && (row > player_y)) {red, green, blue} = {2'b11, 2'b11, 2'b00};
        else {red, green, blue} = {2'b00, 2'b00, 2'b00};
    end
    

endmodule: draw_player