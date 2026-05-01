module draw_ghost
   (input logic clk, rst_n,
    input logic [15:0] row, col,
    input logic en_cond,
    input logic collision_g,
    input logic [15:0] player_x, player_y,
    output logic [1:0] red, green, blue,
    output logic [15:0] nghost_x, nghost_y,
    output logic [15:0] ghost_x, ghost_y);
      
   logic [15:0] ghost_size; // player size

   logic left, right, up, down;
   logic reg_collision_g;
   logic [31:0] count, inter_count;


   enum logic [1:0] {LEFT, RIGHT, UP, DOWN} currState, nextState;


   always_ff @(posedge clk, negedge rst_n) begin
       if (~rst_n) inter_count <= 'd0;
       else inter_count <= inter_count + 1;
   end


   always_ff @(posedge clk, negedge rst_n) begin
       if (~rst_n) count <= 'd0;
       else if (collision_g) count <= 'd0;
       else if (inter_count == 32'hFFFFFFF) count <= count + 1;
   end


   always_ff @(posedge clk, negedge rst_n) begin
       if (~rst_n) reg_collision_g <= 1'b0;
       else if (collision_g) reg_collision_g <= 1'b1;
       else if (inter_count >= 32'hFFFFFFF) reg_collision_g <= 1'b0;
   end


   assign ghost_size = 16'd15;


   logic en_left, en_right, en_up, en_down;


   always_comb begin
       nextState = currState;
       en_left = 1'b0;
       en_right = 1'b0;
       en_up = 1'b0;
       en_down = 1'b0;
       case (currState)
           LEFT: begin
               if (collision_g && ~reg_collision_g) begin
                   nextState = RIGHT;
                   en_right = 1'b1;
               end
               else if (player_x < ghost_x) begin
                   nextState = LEFT;
                   en_left = 1'b1;
               end
               else if (~reg_collision_g) begin
                   nextState = RIGHT;
                   en_up = 1'b1;
               end
           end
           RIGHT: begin
               if (collision_g && ~reg_collision_g) begin
                   nextState = DOWN;
                   en_down = 1'b1;
               end
               else if (player_x > ghost_x) begin
                   nextState = RIGHT;
                   en_right = 1'b1;
               end
               else if (~reg_collision_g) begin
                   nextState = DOWN;
                   en_down = 1'b1;
               end
           end
           DOWN: begin
               if (collision_g && ~reg_collision_g) begin
                   nextState = UP;
                   en_up = 1'b1;
               end
               else if (player_y > ghost_y) begin
                   nextState = DOWN;
                   en_down = 1'b1;
               end
               else if (~reg_collision_g) begin
                   nextState = UP;
                   en_up = 1'b1;
               end
           end
           UP: begin
               if (collision_g && ~reg_collision_g) begin
                   nextState = LEFT;
                   en_left = 1'b1;
               end
               else if (player_y < ghost_y) begin
                   nextState = UP;
                   en_up = 1'b1;
               end
               else if (~reg_collision_g) begin
                   nextState = LEFT;
                   en_left = 1'b1;
               end
           end
       endcase
   end


   always_ff @(posedge clk, negedge rst_n) begin
       if (~rst_n) currState <= LEFT;
       else currState <= nextState;
   end


   always_ff @(posedge clk, negedge rst_n) begin
       if (~rst_n) begin
           left <= 1'b0;
       end
       else if (en_left) left <= 1'b1;
       else left <= 1'b0;
   end


   always_ff @(posedge clk, negedge rst_n) begin
       if (~rst_n) begin
           right <= 1'b0;
       end
       else if (en_right) right <= 1'b1;
       else right <= 1'b0;
   end


   always_ff @(posedge clk, negedge rst_n) begin
       if (~rst_n) begin
           up <= 1'b0;
       end
       else if (en_up) up <= 1'b1;
       else up <= 1'b0;
   end


   always_ff @(posedge clk, negedge rst_n) begin
       if (~rst_n) begin
           down <= 1'b0;
       end
       else if (en_down) down <= 1'b1;
       else down <= 1'b0;
   end

   always_comb begin
       nghost_x = ghost_x;
       nghost_y = ghost_y;


       if (left) begin
           nghost_x = ghost_x - 16'd3;
       end
       else if (right) begin
           nghost_x = ghost_x + 16'd3;
       end
      
       //y dir
       else if (up) begin
           nghost_y = ghost_y - 16'd3;
       end
       else if (down) begin
           nghost_y = ghost_y + 16'd3;
       end
   end


   always_ff @(posedge clk, negedge rst_n) begin
       if (~rst_n) begin
           ghost_x <= 16'd750;
           ghost_y <= 16'd480;
       end
       else if (en_cond && ~collision_g) begin
           if ((nghost_x > (141 + ghost_size)) && (nghost_x < (774 - ghost_size))) begin
               ghost_x <= nghost_x;
           end
           if ((nghost_y > (30 + ghost_size)) && (nghost_y < (504 - ghost_size))) begin
               ghost_y <= nghost_y;
           end
       end
   end


   always_comb begin
       if (((col < (ghost_x + ghost_size)) && (col > ghost_x)) &&
           (row < (ghost_y + ghost_size)) && (row > ghost_y)) {red, green, blue} = {2'b11, 2'b00, 2'b00};
       else {red, green, blue} = {2'b00, 2'b00, 2'b00};
   end
  


endmodule: draw_ghost

