module ChipInterface (
    input logic clk, btn_rst,
    input logic btn_left, btn_right, btn_up, btn_down,
    output logic vga_r0, vga_r1,
    output logic vga_g0, vga_g1,
    output logic vga_b0, vga_b1,
    output logic vga_hs, vga_vs);

    //logic for positions
    logic [15:0] player_x, player_y;
    logic [15:0] nplayer_x, nplayer_y;
    logic [15:0] ghost_x, ghost_y;
    logic [15:0] nghost_x, nghost_y;

    //logic for vga
    logic [15:0] col, row;
    logic enable_V_counter;
    logic en_cond;

    logic [1:0] red_m, green_m, blue_m;
    logic [1:0] red_p, green_p, blue_p;
    logic [1:0] red_g, green_g, blue_g;
    logic [1:0] red, green, blue;

    //logic for collisions
    logic collision, collision_g;
    logic rst_n;
    logic pg_collision;

    logic left, right, up, down;

    Synchronizer s0 (.clock(clk), .async(btn_rst), .sync(rst_n)),
                 s1 (.clock(clk), .async(btn_left), .sync(left)),
                 s2 (.clock(clk), .async(btn_right), .sync(right)),
                 s3 (.clock(clk), .async(btn_up), .sync(up)),
                 s4 (.clock(clk), .async(btn_down), .sync(down));

    assign en_cond = ((row == 16'd524) && (col == 16'd799));

    //Player position logic
    draw_player dp(.clk, .rst_n,
                   .row, .col,
                   .left, .right, .up, .down,
                   .red(red_p), .green(green_p), .blue(blue_p),
                   .en_cond,
                   .collision,
                   .player_x, .player_y,
                   .nplayer_x, .nplayer_y);

    draw_basic_map dm0 (.clk, .rst_n,
                        .row, .col,
                        .red(red_m), .green(green_m), .blue(blue_m),
                        .en_cond,
                        .nghost_x, .nghost_y,
                        .nplayer_x, .nplayer_y,
                        .collision,
                        .collision_g);

    // Ghost position logic
    draw_ghost dg(.clk, .rst_n,
                  .row, .col,
                  .red(red_g), .green(green_g), .blue(blue_g),
                  .en_cond,
                  .collision_g,
                  .player_x, .player_y,
                  .nghost_x, .nghost_y,
                  .ghost_x, .ghost_y);

    //logic for player and ghost collision
    logic [15:0] player_size;
    assign player_size = 15;
    assign pg_collision = (((ghost_x < (player_x + player_size)) && (ghost_x > (player_x - player_size))) && 
                           ((ghost_y < (player_y + player_size)) && (ghost_y > (player_y - player_size))));

    assign red = (red_p || red_m || red_g);
    assign green = (green_p || green_m || green_g);
    assign blue = (blue_p || blue_m || blue_g);

    horizontal_counter h_counter(.*);
    vertical_counter v_counter(.*);

    assign vga_hs = (col < 96) ? 1'b1:1'b0;
    assign vga_vs = (row < 2) ? 1'b1:1'b0;

    assign {vga_r1, vga_r0} = (((col < 784) && (col > 143)) && ((row < 515) && (row > 34))) ? red: 2'b00;
    assign {vga_g1, vga_g0} = (((col < 784) && (col > 143)) && ((row < 515) && (row > 34))) ? green: 2'b00;
    assign {vga_b1, vga_b0} = (((col < 784) && (col > 143)) && ((row < 515) && (row > 34))) ? blue: 2'b00;

endmodule: ChipInterface