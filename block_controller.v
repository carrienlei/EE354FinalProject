`timescale 1ns / 1ps

module block_controller(
	input clk, //this clock must be a slow enough clock to view the changing positions of the objects
	input clk25,
	input bright,
	input rst,
	input up, input down, input left, input right,
	// input up, input down,
	input [9:0] hCount, vCount,
	output reg [11:0] rgb,
	output reg [11:0] background
	// output q_STILL, q_UP, q_DOWN, q_DONE,
	// output reg out
	// output [3:0] bottle_count
	
   );

	/* reg[3:0] state;
	assign{q_STILL, q_UP, q_DOWN, q_DONE} = state; */
	
	parameter IDLE = 3'b000;  // Idle state
	parameter UP = 3'b001;    // Up state
	parameter DN = 3'b010;    // Down state
	parameter DEAD = 3'b011;
	parameter GAME_OVER = 3'b100;
	
	// Define the state register and next state logic
	reg [1:0] state, next_state;
	reg [3:0] bottle_count;

	always @(posedge clk, posedge rst) begin
		if (rst) begin
			state <= IDLE;
		end else begin
			state <= next_state;
		end
	end
	wire [11:0] background_rgb;
	wire block_fill;
	wire sand_zone;
	wire shark1;
	wire shark2;
	wire bottle1;
	wire bottle2;
	reg sharkCollision; // collision occured
	reg sharkCollisionAtClock;
	reg sharkACK;
	reg bottleACK;
	reg bottleCollision;
	reg bottleCollisionAtClock;


	
	always @(posedge clk25, posedge rst) begin
		if(rst) begin
			sharkCollisionAtClock<=0;
			bottleCollisionAtClock<=0;
	 end
		else begin
			if(sharkCollision)
				sharkCollisionAtClock<=1;
			if (bottleCollision)
				bottleCollisionAtClock<=1;
			if(sharkACK)
				sharkCollisionAtClock<=0; 
			if (bottleACK)
				bottleCollisionAtClock<=0;
				end
	end

	
	// parameter bottle_count = 3'b000;
	
	
	//these two values dictate the center of the block, incrementing and decrementing them leads the block to move in certain directions
	reg [9:0] xpos, ypos;
	reg [9:0] shark1xpos, shark1ypos, shark2xpos, shark2ypos, bottle1xpos, bottle1ypos, bottle2xpos, bottle2ypos;
	
	reg [3:0] bottle_count;
	
	parameter RED   = 12'b1111_0000_0000;
	parameter SHARK =  12'b0000_0101_1000; // 058 grey
	parameter BOTTLE = 12'b1010_1110_1111; // AEF blue
	
	/*when outputting the rgb value in an always block like this, make sure to include the if(~bright) statement, as this ensures the monitor 
	will output some data to every pixel and not just the images you are trying to display*/
	always@ (*) begin
    	
		if (block_fill) 
			rgb = RED; 
		else if (sand_zone == 1)
			rgb = 12'b1111_1111_0000;
		else if (shark1)
			rgb = 12'b0000_0101_1000;
		else if (shark2)
			rgb = 12'b0000_0101_1000;
		else if (bottle1)
			rgb = 12'b1010_1110_1111;
		else if (bottle2)
			rgb = 12'b1010_1110_1111;
		else	
			rgb=background_rgb;
		sharkCollision = ((block_fill && shark1) || (block_fill && shark2 )) ? 1 : 0;
		bottleCollision = ((block_fill && bottle1) || (block_fill && bottle2)) ? 1 : 0;
	end

		//the +-5 for the positions give the dimension of the block (i.e. it will be 10x10 pixels)
	assign block_fill=vCount>=(ypos-5) && vCount<=(ypos+5) && hCount>=(xpos-5) && hCount<=(xpos+5);
	// assign block_fill = color_data;
	// assign sand zone
	assign sand_zone = ((hCount >= 10'd144) && (hCount <= 10'd784)) && ((vCount >= 10'd490) && (vCount <= 10'd520)) ? 1 : 0;

	// assign sharks
	assign shark1 = ((hCount >= (shark1xpos-10)) && (hCount <= (shark1xpos+10))) && ((vCount >= (shark1ypos-5)) && (vCount <= (shark1ypos+5))) ? 1 : 0;
	assign shark2 = ((hCount >= (shark2xpos-10)) && (hCount <= (shark2xpos+10))) && ((vCount >= (shark2ypos-5)) && (vCount <= (shark2ypos+5))) ? 1 : 0;

	
	// assign bottles
	assign bottle1 = ((hCount >= (bottle1xpos-2)) && (hCount <= (bottle1xpos+2))) && ((vCount >= (bottle1ypos-4)) && (vCount <= (bottle1ypos+4))) ? 1 : 0;
	assign bottle2 = ((hCount >= (bottle2xpos-2)) && (hCount <= (bottle2xpos+2))) && ((vCount >= (bottle2ypos-4)) && (vCount <= (bottle2ypos+4))) ? 1 : 0;
	
		// Define the state transition logic
	always @(posedge clk, posedge rst) begin
		if (rst) begin
			xpos<=200;
			ypos<=250;
			shark1xpos <= 220;
			shark1ypos <= 135;
			shark2xpos <= 440;
			shark2ypos <= 330;
			bottle1xpos <= 250;
			bottle1ypos <= 440;
			bottle2xpos <= 170;
			bottle2ypos <= 200;
			bottle_count <= 4'b0000;
			next_state <= IDLE;
			end
		
		else 
		begin
		shark1xpos <= shark1xpos - 3;
		shark2xpos <= shark2xpos - 2;
		bottle1xpos <= bottle1xpos -2;
		bottle2xpos <= bottle2xpos - 1;	
				
		
		case (state)
			IDLE: begin
				// out = 1'b0;
				if (up) begin
					next_state <= UP;
				end else if (down) begin
					next_state <= DN;
				
				end else if (bottle_count == 5) begin
					next_state <= GAME_OVER;
				end else begin
					next_state <= IDLE;
				end
				sharkACK<=0;
				bottleACK<=0;
				if(sharkCollisionAtClock) begin
					next_state<=DEAD;
					sharkACK<=1;
				end
				if (bottleCollisionAtClock) begin
				    ypos <= ypos -20;
					bottle_count <= bottle_count +1;
				    bottleACK <= 1;
				end
				
			end
			
			UP: begin
			// out = 1'b1;
				ypos<=ypos-1;
				sharkACK<=0;
				bottleACK<=0;
				if (ypos==40)
					ypos<=42;		
				if (down) begin
					next_state <= DN;
				end else if (up) begin
					next_state <= UP;
				end else if (bottle_count == 5) begin
					next_state <= GAME_OVER;
				
				end else begin
					next_state <= IDLE;
				end
				if(sharkCollisionAtClock) begin
					next_state<=DEAD;
					sharkACK=1;
				end
				if (bottleCollisionAtClock) begin
					bottle_count <= bottle_count +1;
					ypos <= ypos -20;
					bottleACK <= 1;

				end
				
			end
			DN: begin
				// out = 1'b0;
				sharkACK<=0;
				bottleACK<=0;
				ypos<=ypos+1;
				if(ypos==514)
					ypos<=512;
				if (up) begin
					next_state <= UP;
				
				end else if (down) begin
					next_state <= DN;
				end else if (bottle_count == 5) begin
					next_state <= GAME_OVER;	
				end else begin
					next_state <= IDLE;
				end
				if(sharkCollisionAtClock) begin
					next_state<=DEAD;
					sharkACK=1;
				end
				if (bottleCollisionAtClock) begin
					bottle_count <= bottle_count +1;
					ypos <= ypos -20;
					bottleACK <= 1;

				end
			end
			GAME_OVER: begin
                xpos<=40;
                ypos<=450;
                shark1xpos <= 220;
                shark1ypos <= 135;
                shark2xpos <= 440;
                shark2ypos <= 330;
                bottle1xpos <= 250;
                bottle1ypos <= 440;
                bottle2xpos <= 170;
                bottle2ypos <= 200;
                bottle_count <= 4'b0000;
	
			end 
			DEAD: begin
			    xpos<=200;
                ypos<=250;
                shark1xpos <= 220;
                shark1ypos <= 135;
                shark2xpos <= 440;
                shark2ypos <= 330;
                bottle1xpos <= 250;
                bottle1ypos <= 440;
                bottle2xpos <= 170;
                bottle2ypos <= 200;
                bottle_count <= 4'b0000;

			end 
		endcase
		end
	end
	
	always@(posedge clk, posedge rst) begin
		if(rst)
			background <= 12'b0000_0000_0000; //white
		else 
			if(right)
				background <= 12'b0000_1111_1111; //yellow
			else if(left)
				background <= 12'b0000_1111_1111; //turquoise
			else if(down)
				background <= 12'b0000_1111_1111; //green
			else if(up)
				background <= 12'b0000_1111_1111; //blue
	end
endmodule
