module shark
    (
        input wire clk, reset,
        input wire [9:0] y_x, y_y,         // current pixel location of yoshi
	    input wire [9:0] x, y,             // current pixel coordinates from vga_sync circuit
	    output wire [9:0] shark_x, shark_y,    // output vector for ghost_crazy's x/y position
        output shark_on,             // on signal: vga pixel within sprite location
        output wire [11:0] rgb_out
    );
   
    // constant declarations
    // max pixel coordinates for VGA display area
    localparam MAX_X = 640;
    localparam MAX_Y = 480;
   
    // Yoshi sprite location regs, pixel location for top left corner
    reg [9:0] s_x_reg, s_y_reg;
    reg [9:0] s_x_next, s_y_next;
   
    // infer registers for sprite location
    always @(posedge clk)
	begin
        s_x_reg     <= s_x_next;
        s_y_reg     <= s_y_next;
        end
   
    // on positive edge of tick signal, or reset, update ghost location 
    always @(posedge tick, posedge reset)
		begin
		//defaults
		s_x_next = s_x_reg;
		s_x_next = s_x_reg;
		
		if(reset)
			s_x_next = 150;  
		else  
			s_x_next <= s_x_next - 2;
		end
				   
    sharkSprite shark (.clk, .row(row), .col(col), .color_data(color_data));
    assign rgb_out = color_data;

    
    wire shark_on;
    assign shark_on = (x >= s_x_reg && x < s_x_reg + 16 
		       && y >= s_y_reg && y < s_y_reg + 16)? 1 : 0;
	
    // route x/y location out
    assign shark_x = s_x_reg;
    assign shark_y = s_y_reg;
	
endmodule