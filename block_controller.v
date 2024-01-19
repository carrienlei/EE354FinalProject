`timescale 1ns / 1ps

module block_controller(
	input clk, //this clock must be a slow enough clock to view the changing positions of the objects
	input bright,
	input rst,
	input up, input down, input left, input right,
	input [9:0] hCount, vCount,
	output reg [11:0] rgb,
	output reg [11:0] background
	output q_STILL, q_UP, q_DOWN;
   );

	reg[2:0] state;
	assign{q_STILL, q_UP, q_DOWN} = state;

	localparam
		q_STILL		    =   3'b001,
	    q_UP	        =   3'b010,
	    q_DOWN          =   3'b100,
		UNK 	        =   3'bXXX;

	wire block_fill;
	wire sand_zone;
	wire shark1;
	wire shark2;
	wire bottle1;
	wire bottle2;
	
	//these two values dictate the center of the block, incrementing and decrementing them leads the block to move in certain directions
	reg [9:0] xpos, ypos;
	reg [9:0] shark1xpos, shark1ypos, shark2xpos, shark2ypos, bottle1xpos, bottle1ypos, bottle2xpos, bottle2ypos;
	
	parameter RED   = 12'b1111_0000_0000;
	parameter SHARK =  12'b0000_0101_1000; // 058 grey
	parameter BOTTLE = 12'b1010_1110_1111; // AEF blue
	
	/*when outputting the rgb value in an always block like this, make sure to include the if(~bright) statement, as this ensures the monitor 
	will output some data to every pixel and not just the images you are trying to display*/
	always@ (*) begin
    	if(~bright )	//force black if not inside the display area
			rgb = 12'b0000_0000_0000;
		else if (block_fill) 
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
			rgb=background;
	end
		//the +-5 for the positions give the dimension of the block (i.e. it will be 10x10 pixels)
	assign block_fill=vCount>=(ypos-5) && vCount<=(ypos+5) && hCount>=(xpos-5) && hCount<=(xpos+5);
	
	// assign sand zone
	assign sand_zone = ((hCount >= 10'd144) && (hCount <= 10'd784)) && ((vCount >= 10'd420) && (vCount <= 10'd490)) ? 1 : 0;

	// assign sharks
	assign shark1 = ((hCount >= (shark1xpos-10)) && (hCount <= (shark1xpos+10))) && ((vCount >= (shark1ypos-5)) && (vCount <= (shark1ypos+5))) ? 1 : 0;
	assign shark2 = ((hCount >= (shark2xpos-10)) && (hCount <= (shark2xpos+10))) && ((vCount >= (shark2ypos-5)) && (vCount <= (shark2ypos+5))) ? 1 : 0;

	// assign bottles
	assign bottle1 = ((hCount >= (bottle1xpos-2)) && (hCount <= (bottle1xpos+2))) && ((vCount >= (bottle1ypos-4)) && (vCount <= (bottle1ypos+4))) ? 1 : 0;
	assign bottle2 = ((hCount >= (bottle2xpos-2)) && (hCount <= (bottle2xpos+2))) && ((vCount >= (bottle2ypos-4)) && (vCount <= (bottle2ypos+4))) ? 1 : 0;

	always@(posedge clk, posedge rst) 
	begin
		if(rst)
			xpos<=450;
			ypos<=250;
			shark1xpos <= 220;
			shark1ypos <= 135;
			shark2xpos <= 440;
			shark2ypos <= 330;
			bottle1xpos <= 250;
			bottle1ypos <= 440;
			bottle2xpos <= 570;
			bottle2ypos <= 190;
			state <= q_STILL;
		else
		begin 
			case(state)
				q_STILL:
				shark1xpos <= shark1xpos -3;
				shark2xpos <= shark2xpos -2;
				bottle2xpos <= bottle2xpos - 1;
				if (down)
					state <= q_DOWN;
				if (up)
					state <= q_UP;
				if (!(up) && !(down))
					state <= q_STILL;
				
				if ( ((xpos <= shark1xpos+10)&& (xpos >= shark1xpos-10) && (ypos <= shark1ypos+10) && (ypos >= shark1ypos-10)) || ((xpos <= shark2xpos+10)&& (xpos >= shark2xpos-10) && (ypos <= shark2ypos+10) && (ypos >= shark2ypos-10))) 
					state <= rst;

				q_UP:
				ypos<=ypos-2;
				if(ypos==34)
					ypos<=36;
				shark1xpos <= shark1xpos -3;
				shark2xpos <= shark2xpos -2;
				bottle2xpos <= bottle2xpos - 1;
				if (down)
					state <= q_DOWN;
				if (up)
					state <= q_UP;
				if (!(up) && !(down))
					state <= q_STILL;
				if ( ((xpos <= shark1xpos+10)&& (xpos >= shark1xpos-10) && (ypos <= shark1ypos+10) && (ypos >= shark1ypos-10)) || ((xpos <= shark2xpos+10)&& (xpos >= shark2xpos-10) && (ypos <= shark2ypos+10) && (ypos >= shark2ypos-10))) 
					state <= rst;
				
				q_DOWN:
				ypos<=ypos+2;
				if(ypos==514)
					ypos<=512;
				shark1xpos <= shark1xpos -3;
				shark2xpos <= shark2xpos -2;
				bottle2xpos <= bottle2xpos - 1;
				if (up)
					state <= q_UP;
				if (down)
					state <= q_DOWN;
				if (!(up) && !(down))
					state <= q_STILL;
				if ( ((xpos <= shark1xpos+10)&& (xpos >= shark1xpos-10) && (ypos <= shark1ypos+10) && (ypos >= shark1ypos-10)) || ((xpos <= shark2xpos+10)&& (xpos >= shark2xpos-10) && (ypos <= shark2ypos+10) && (ypos >= shark2ypos-10))) 
					state <= rst;
				
				default:
					state <= UNK;
			endcase
		end
	end
			

	// 	end
	// 	else if (clk) begin
		
	// 	/* Note that the top left of the screen does NOT correlate to vCount=0 and hCount=0. The display_controller.v file has the 
	// 		synchronizing pulses for both the horizontal sync and the vertical sync begin at vcount=0 and hcount=0. Recall that after 
	// 		the length of the pulse, there is also a short period called the back porch before the display area begins. So effectively, 
	// 		the top left corner corresponds to (hcount,vcount)~(144,35). Which means with a 640x480 resolution, the bottom right corner 
	// 		corresponds to ~(783,515).  
	// 	*/
			

	// 		if(right) begin
	// 			xpos<=xpos+2; //change the amount you increment to make the speed faster 
	// 			if(xpos==800) //these are rough values to attempt looping around, you can fine-tune them to make it more accurate- refer to the block comment above
	// 				xpos<=150;
	// 		end
	// 		else if(left) begin
	// 			xpos<=xpos-2;
	// 			if(xpos==150)
	// 				xpos<=800;
	// 		end
	// 		else if(up) begin
	// 			ypos<=ypos-2;
	// 			if(ypos==34)
	// 				ypos<=514;
	// 		end
	// 		else if(down) begin
	// 			ypos<=ypos+2;
	// 			if(ypos==514)
	// 				ypos<=34;
	// 		end
			
	// 		if ( ((xpos <= shark1xpos+10)&& (xpos >= shark1xpos-10) && (ypos <= shark1ypos+10) && (ypos >= shark1ypos-10)) || ((xpos <= shark2xpos+10)&& (xpos >= shark2xpos-10) && (ypos <= shark2ypos+10) && (ypos >= shark2ypos-10))) 
	// 			begin
	// 				xpos<=450;
	// 				ypos<=250;
	// 				shark1xpos <= 220;
	// 				shark1ypos <= 135;
	// 				shark2xpos <= 440;
	// 				shark2ypos <= 330;
	// 				bottle1xpos <= 250;
	// 				bottle1ypos <= 440;
	// 				bottle2xpos <= 570;
	// 				bottle2ypos <= 190;
	// 			end
	// 	end
	// end
	
	//the background color reflects the most recent button press
	always@(posedge clk, posedge rst) begin
		if(rst)
			background <= 12'b0000_1111_1111; //white
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
