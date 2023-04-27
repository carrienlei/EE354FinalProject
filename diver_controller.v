module diver_controller
    (
        input wire clk, reset,       // clock/reset inputs for synchronous registers 
        input wire btnU, btnL, btnR, // inputs used to move sprite across screen
        input wire video_on,         // input from vga_sync signaling when video signal is on
        input wire [9:0] x, y,       // current pixel coordinates from vga_sync circuit
	input wire collision,        // input signal conveying when yoshi collides with ghost
        output reg [11:0] rgb_out,   // output rgb signal for current yoshi pixel
        output reg diver_on,         // output signal asserted when input x/y are within yoshi sprite in display area
        output wire [9:0] y_x, y_y,  // output signals for yoshi sprite's current location within display area

    );
   
    // constant declarations
    // pixel coordinate boundaries for VGA display area
    localparam MAX_X = 640;
    localparam MAX_Y = 480;
    localparam MIN_Y =  16;
   

   
    /***********************************************************************************/
    /*                           sprite location registers                             */  
    /***********************************************************************************/
    // Yoshi sprite location regs, pixel location with respect to top left corner
    reg [9:0] s_x_reg, s_y_reg;
    reg [9:0] s_x_next, s_y_next;
   
    // infer registers for sprite location
    always @(posedge clk, posedge reset)
        if (reset)
            begin
            s_x_reg     <= 320;                 // initialize to middle of screen,
            s_y_reg     <= MAX_Y - 2*T_H - 16;  // on bottom floor
            end
        else
            begin
            s_x_reg     <= s_x_next;
            s_y_reg     <= s_y_next;
            end
   
  
    /***********************************************************************************/
    /*                                     ROM indexing                                */  
    /***********************************************************************************/  
                   
    // sprite coordinate addreses, from upper left corner
    // used to index ROM data
    wire [3:0] col;
    wire [6:0] row;
   
    // current pixel coordinate minus current sprite coordinate gives ROM index
	// column indexing depends on direction, and whether drawing head or torso to screen 
    assign col = (dir_reg == RIGHT && head_on)  ? (X_D + T_W - 1 - (x - s_x_reg)) :
                 (dir_reg == LEFT  && head_on)  ?                 ((x - s_x_reg)) :
                 (dir_reg == RIGHT && torso_on) ?       (T_W - 1 - (x - s_x_reg)) :
                 (dir_reg == LEFT  && torso_on) ?           ((x - s_x_reg - X_D)) : 0;
    
    // row indexing depends on whether drawing head or torso to screen	
    assign row = head_on  ? (y - s_y_reg):
                 torso_on ? (dy + y - s_y_reg): 0;
				    
    // vector for ROM color_data output
    wire [11:0] color_data_diver;
   
    // diver ROM
    diver_rom diver_rom_unit (.clk(clk), .row(row), .col(col), .color_data(color_data_diver));
		
    // vector to signal when vga_sync pixel is within head or torso tile (see diagram)
    wire head_on, torso_on;
    assign head_on = (dir_reg == RIGHT) && (x >= s_x_reg + X_D) && (x <= s_x_reg + X_MAX - 1) && (y >= s_y_reg) && (y <= s_y_reg + T_H - 1) ? 1
                   : (dir_reg == LEFT) && (x >= s_x_reg) && (x <= s_x_reg + T_W - 1) && (y >= s_y_reg) && (y <= s_y_reg + T_H - 1) ? 1 : 0;
   
    assign torso_on = (dir_reg == RIGHT) && (x >= s_x_reg) && (x <= s_x_reg + T_W - 1) && (y >= s_y_reg + T_H) && (y <= s_y_reg + 2*T_H - 1) ? 1
                    : (dir_reg == LEFT) && (x >= s_x_reg + X_D) && (x <= s_x_reg + X_MAX - 1) && (y >= s_y_reg + T_H) && (y <= s_y_reg + 2*T_H - 1) ? 1 : 0;
   
    // assign module output signals
    assign y_x = s_x_reg;
    assign y_y = s_y_reg;
    assign jumping_up = (state_reg_y == jump_up) ? 1 : 0;
    assign direction = dir_reg;
	
    // if collision occurs, turn yoshi into a ghost for 2 seconds (200000000 clock cycles);
    reg [27:0] collision_time_reg;
    wire [27:0] collision_time_next;
	
    // infer ghost_yoshi_time register
    always @(posedge clk, posedge reset)
	if(reset)
		collision_time_reg <= 0;
	else 
		collision_time_reg <= collision_time_next;
	
    // when collision occurs, set reg to 2 seconds of clk cycles, else decrement until 0
    assign collision_time_next = collision ? 200000000 : 
								 collision_time_reg > 0 ? collision_time_reg - 1 : 0;
       
    // rgb output
    always @*
		begin
		// defaults
		yoshi_on = 0;
		rgb_out = 0;
		
		if(head_on || torso_on && video_on)               // if x/y in head/torso region  
			begin
			if(game_over_yoshi || collision_time_reg > 0) // if game in gameover state or collision occured        
				rgb_out = color_data_yoshi_ghost;         // output rgb data for yoshi_ghost
			else
				rgb_out = color_data_;               // else output rgb data for yoshi
		
			if(rgb_out != 12'b011011011110)               // if rgb data isn't sprite background color
					yoshi_on = 1;                         // assert yoshi_on signal to let display_top draw current pixel   
			end
        end
endmodule