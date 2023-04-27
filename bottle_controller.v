module bottle_controller
(
	input clk, //this clock must be a slow enough clock to view the changing positions of the objects
	input rst,
    input wire [9:0] d_x, d_y,         // diver location
    input wire [9:0] x, y, 
    output bottles_on, 
    output wire [11:0] rgb_out      // output rgb signal for current pixel
     
);

    reg [9:0] bottle_x_reg, bottle_x_next, bottle_y_reg, bottle_y_next;

    always @(posedge clk, posedge rst)
        if(rst)
            begin
            bottle_x_reg    <= 296;
            bottle_y_reg    <= 364;
            end
        else
            begin
            bottle_x_reg    <= bottle_x_next;
            bottle_y_reg    <= bottle_y_next;

            end
    reg [1:0] state_reg, state_next;

    always @(posedge clk, posedge rst)
        if(rst)
            state_reg <= waiting;
        else
            state_reg <= state_next;

    localparam  waiting    = 1'b0, // waiting for diver to get bottle
                respawn    = 1'b1; // diver acquired bottle, respawn new bottle

     always @*
        begin
	// defaults
        state_next = state_reg;
        bottle_x_next = bottle_x_reg;
        bottle_y_next = bottle_y_reg;
	// new_score_next = 0;
       
        case(state_reg)
           
            waiting: // bottle already spawned, waiting for diver to get it
                begin                
                //collision detection
                if((bottle_x_reg + 13 > d_x + 9 && bottle_x_reg < d_x + 16 && bottle_y_reg + 13 > d_y && bottle_y_reg < d_y + 13) ||
                       (bottle_x_reg + 13 > d_x && bottle_x_reg < d_x + 13 && bottle_y_reg + 13 > d_y + 13 && bottle_y_reg < d_y + 18))
                    begin
		    // new_score_next = 1;    // signal new score ready
		    state_next = respawn; // go to respawn state
		    end
                end

            respawn: // respawn new bottle at current platform_select_reg platform,
         	     // and at this platform's location register value
                begin
                // if(platform_select_reg == 0) // 'A'
                //     begin
                    bottle_y_next    = 116;
                    bottle_x_next    = 70;
                //     end
                // else if(platform_select_reg == 1) // 'B'
                //     begin
                //     bottle_y_next    = 116;
                //     bottle_x_next    = B_reg;
                //     end
                // else if(platform_select_reg == 2) // 'C'
                //     begin
                //     bottle_y_next    = 199;
                //     bottle_x_next    = C_reg;
                //     end
               
                state_next = waiting; // go back to waiting state
                end
        endcase
        end    
    bottle_rom bottle_rom_unit(.clk(clk), .bottle_x_reg(bottle_x_reg), .bottle_y_reg(bottle_y_reg), .color_data(rgb_out));
    
    assign bottle_on = (x >= bottle_x_reg && x < bottle_x_reg + 16 && y >= bottle_y_reg && y < bottle_y_reg + 16)
                     && (rgb_out != 12'b011011011110) ? 1 : 0;         

endmodule