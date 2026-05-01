//Module to draw basic map on the screen
module draw_basic_map (
    input logic clk, rst_n,
    input logic [15:0] row, col,
    input logic en_cond,
    input logic [15:0] nplayer_x, nplayer_y,
    input logic [15:0] nghost_x, nghost_y,
    output logic [1:0] red, green, blue,
    output logic collision, collision_g);

    //variable to keep track of coordinates of tiles

    logic [15:0] row_coords_0, row_coords_1, row_coords_2, row_coords_3, row_coords_4;
    logic [15:0] col_coords_0, col_coords_1, col_coords_2, col_coords_3,
                col_coords_4, col_coords_5, col_coords_6, col_coords_7;

    assign row_coords_0 = 35; 
    assign row_coords_1 = 131; 
    assign row_coords_2 = 227; 
    assign row_coords_3 = 323;
    assign row_coords_4 = 419;

    assign col_coords_0 = 145;
    assign col_coords_1 = 225;
    assign col_coords_2 = 305;
    assign col_coords_3 = 385;
    assign col_coords_4 = 465;
    assign col_coords_5 = 545;
    assign col_coords_6 = 625;
    assign col_coords_7 = 705; 

    logic [15:0] width, player_size;
    logic [15:0] row_size, row_size2, col_size, col_size2, col_size4;
    
    assign player_size = 16'd15;
    assign width = 16'd10;
    assign row_size = 16'd96;
    assign row_size2 = 16'd192;
    assign col_size = 16'd80;
    assign col_size2 = 16'd160;
    assign col_size4 = 16'd320;


    always_comb begin

        //border
        if (row < (16'd35 + width)) {red, green, blue} = {2'b11, 2'b11, 2'b11};

        else if (row > (16'd515 - width)) {red, green, blue} = {2'b11, 2'b11, 2'b11};

        else if (col < (16'd144 + width)) {red, green, blue} = {2'b11, 2'b11, 2'b11};

        else if (col > (16'd785 - width)) {red, green, blue} = {2'b11, 2'b11, 2'b11};

        //line1
        else if (((col < (col_coords_1 + col_size)) && (col > col_coords_1)) && 
                 (row < (row_coords_2 + width)) && (row > row_coords_2)) {red, green, blue} = {2'b11, 2'b11, 2'b11};

        //line2
        else if (((col < (col_coords_2 + width)) && (col > col_coords_2)) && 
                 (row < (row_coords_2 + width)) && (row > row_coords_2 + width - row_size)) {red, green, blue} = {2'b11, 2'b11, 2'b11};

        //line3
        else if (((col < (col_coords_2 + col_size2)) && (col > col_coords_2)) && 
                 (row < (row_coords_1 + width)) && (row > row_coords_1)) {red, green, blue} = {2'b11, 2'b11, 2'b11};

        //line4
        else if (((col < (col_coords_1 + width)) && (col > col_coords_1)) && 
                 (row < (row_coords_4)) && (row > row_coords_4 - row_size)) {red, green, blue} = {2'b11, 2'b11, 2'b11};

        //line5
        else if (((col < (col_coords_1 + col_size2)) && (col > col_coords_1)) && 
                 (row < (row_coords_4 + width)) && (row > row_coords_4)) {red, green, blue} = {2'b11, 2'b11, 2'b11};

        //line6
        else if (((col < (col_coords_4 + width)) && (col > col_coords_4)) && 
                 (row < (row_coords_3)) && (row > row_coords_3 - row_size)) {red, green, blue} = {2'b11, 2'b11, 2'b11};

        //line7
        else if (((col < (col_coords_2 + col_size4)) && (col > col_coords_2)) && 
            (row < (row_coords_3 + width)) && (row > row_coords_3)) {red, green, blue} = {2'b11, 2'b11, 2'b11};

        //line8
        else if (((col < (col_coords_5 + width)) && (col > col_coords_5)) && 
                 (row < (row_coords_4)) && (row > row_coords_4 - row_size)) {red, green, blue} = {2'b11, 2'b11, 2'b11};

        //line9
        else if (((col < (col_coords_5 + col_size2)) && (col > col_coords_5)) && 
            (row < (row_coords_4 + width)) && (row > row_coords_4)) {red, green, blue} = {2'b11, 2'b11, 2'b11};

        //line10
        else if (((col < (col_coords_5 + col_size2)) && (col > col_coords_5)) && 
                 (row < (row_coords_2 + width)) && (row > row_coords_2)) {red, green, blue} = {2'b11, 2'b11, 2'b11};

        //line11
        else if (((col < (col_coords_5 + width)) && (col > col_coords_5)) && 
                 (row < (row_coords_2)) && (row > row_coords_2 - row_size)) {red, green, blue} = {2'b11, 2'b11, 2'b11};

        else {red, green, blue} = {2'b00, 2'b00, 2'b00};
    end

    //collision detection of player with map
    always_comb begin
        collision = 1'b0;

        //line1
        if (((nplayer_x < (col_coords_1 + col_size)) && (nplayer_x > (col_coords_1 - player_size))) && 
             (nplayer_y < (row_coords_2 + width)) && (nplayer_y > (row_coords_2 - player_size))) collision = 1'b1;

        //line2
        else if (((nplayer_x < (col_coords_2 + width)) && (nplayer_x > (col_coords_2 - player_size))) && 
                 (nplayer_y < (row_coords_2 + width)) && (nplayer_y > (row_coords_2 + width - row_size - player_size))) collision = 1'b1;

        //line3
        else if (((nplayer_x < (col_coords_2 + col_size2)) && (nplayer_x > (col_coords_2 - player_size))) && 
                 (nplayer_y < (row_coords_1 + width)) && (nplayer_y > (row_coords_1 - player_size))) collision = 1'b1;

        //line4
        else if (((nplayer_x < (col_coords_1 + width)) && (nplayer_x > (col_coords_1 - player_size))) && 
                 (nplayer_y < (row_coords_4)) && (nplayer_y > (row_coords_4 - row_size - player_size))) collision = 1'b1;

        //line5
        else if (((nplayer_x < (col_coords_1 + col_size2)) && (nplayer_x > (col_coords_1 - player_size))) && 
                 (nplayer_y < (row_coords_4 + width)) && (nplayer_y > (row_coords_4 - player_size))) collision = 1'b1;

        //line6
        else if (((nplayer_x < (col_coords_4 + width)) && (nplayer_x > (col_coords_4 - player_size))) && 
                 (nplayer_y < (row_coords_3)) && (nplayer_y > (row_coords_3 - row_size - player_size))) collision = 1'b1;

        //line7
        else if (((nplayer_x < (col_coords_2 + col_size4)) && (nplayer_x > (col_coords_2 - player_size))) && 
                 (nplayer_y < (row_coords_3 + width)) && (nplayer_y > (row_coords_3 - player_size))) collision = 1'b1;

        //line8
        else if (((nplayer_x < (col_coords_5 + width)) && (nplayer_x > (col_coords_5 - player_size))) && 
                 (nplayer_y < (row_coords_4)) && (nplayer_y > (row_coords_4 - row_size - player_size))) collision = 1'b1;

        //line9
        else if (((nplayer_x < (col_coords_5 + col_size2)) && (nplayer_x > (col_coords_5 - player_size))) && 
                 (nplayer_y < (row_coords_4 + width)) && (nplayer_y > (row_coords_4 - player_size))) collision = 1'b1;

        //line10
        else if (((nplayer_x < (col_coords_5 + col_size2)) && (nplayer_x > (col_coords_5 - player_size))) && 
                 (nplayer_y < (row_coords_2 + width)) && (nplayer_y > (row_coords_2 - player_size))) collision = 1'b1;

        //line11
        else if (((nplayer_x < (col_coords_5 + width)) && (nplayer_x > (col_coords_5 - player_size))) && 
                 (nplayer_y < (row_coords_2)) && (nplayer_y > (row_coords_2 - row_size - player_size))) collision = 1'b1;

    end

    //collision detection of ghost with map
    always_comb begin
        collision_g = 1'b0;

        //line1
        if (((nghost_x < (col_coords_1 + col_size)) && (nghost_x > (col_coords_1 - player_size))) && 
             (nghost_y < (row_coords_2 + width)) && (nghost_y > (row_coords_2 - player_size))) collision_g = 1'b1;

        //line2
        else if (((nghost_x < (col_coords_2 + width)) && (nghost_x > (col_coords_2 - player_size))) && 
                 (nghost_y < (row_coords_2 + width)) && (nghost_y > (row_coords_2 + width - row_size - player_size))) collision_g = 1'b1;

        //line3
        else if (((nghost_x < (col_coords_2 + col_size2)) && (nghost_x > (col_coords_2 - player_size))) && 
                 (nghost_y < (row_coords_1 + width)) && (nghost_y > (row_coords_1 - player_size))) collision_g = 1'b1;

        //line4
        else if (((nghost_x < (col_coords_1 + width)) && (nghost_x > (col_coords_1 - player_size))) && 
                 (nghost_y < (row_coords_4)) && (nghost_y > (row_coords_4 - row_size - player_size))) collision_g = 1'b1;

        //line5
        else if (((nghost_x < (col_coords_1 + col_size2)) && (nghost_x > (col_coords_1 - player_size))) && 
                 (nghost_y < (row_coords_4 + width)) && (nghost_y > (row_coords_4 - player_size))) collision_g = 1'b1;

        //line6
        else if (((nghost_x < (col_coords_4 + width)) && (nghost_x > (col_coords_4 - player_size))) && 
                 (nghost_y < (row_coords_3)) && (nghost_y > (row_coords_3 - row_size - player_size))) collision_g = 1'b1;

        //line7
        else if (((nghost_x < (col_coords_2 + col_size4)) && (nghost_x > (col_coords_2 - player_size))) && 
                 (nghost_y < (row_coords_3 + width)) && (nghost_y > (row_coords_3 - player_size))) collision_g = 1'b1;

        //line8
        else if (((nghost_x < (col_coords_5 + width)) && (nghost_x > (col_coords_5 - player_size))) && 
                 (nghost_y < (row_coords_4)) && (nghost_y > (row_coords_4 - row_size - player_size))) collision_g = 1'b1;

        //line9
        else if (((nghost_x < (col_coords_5 + col_size2)) && (nghost_x > (col_coords_5 - player_size))) && 
                 (nghost_y < (row_coords_4 + width)) && (nghost_y > (row_coords_4 - player_size))) collision_g = 1'b1;

        //line10
        else if (((nghost_x < (col_coords_5 + col_size2)) && (nghost_x > (col_coords_5 - player_size))) && 
                 (nghost_y < (row_coords_2 + width)) && (nghost_y > (row_coords_2 - player_size))) collision_g = 1'b1;

        //line11
        else if (((nghost_x < (col_coords_5 + width)) && (nghost_x > (col_coords_5 - player_size))) && 
                 (nghost_y < (row_coords_2)) && (nghost_y > (row_coords_2 - row_size - player_size))) collision_g = 1'b1;

    end

endmodule: draw_basic_map