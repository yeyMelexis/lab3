module trafic(clk, rst_n, o_red, o_yellow, o_green);
  input   clk, rst_n;
  output reg  o_red, o_yellow, o_green;
  
  parameter RED_TIME     = 5;
  parameter GREEN_TIME   = 5;
  parameter YELLOW1_TIME = 1;
  parameter YELLOW2_TIME = 2;

  
  localparam RED     = 2'b00;
  localparam GREEN   = 2'b11;
  localparam YELLOW1 = 2'b01;
  localparam YELLOW2 = 2'b10;
  
  reg   end_green, end_red, end_yellow1, end_yellow2;
  reg   [1:0] state, next_state;
  
  reg   count_rst_n;
  reg   [10:0] count;
  
  
  // Counter //
  always @(posedge clk or negedge rst_n) begin
    if(!rst_n) count <= 0;
    else if(!count_rst_n)  count <= 0;
         else count = count + 1'b1;
  end
  
  // FSM //
  always @(state or count) begin
    next_state  = state;
    count_rst_n = 1'b1;
    case(state)
        RED:      if(count == RED_TIME) begin
                    next_state = YELLOW1;
                    count_rst_n = 1'b0;
                  end
                    
        YELLOW1:  if(count == YELLOW1_TIME) begin
                    next_state = GREEN;
                    count_rst_n = 1'b0;
                  end
                    
        GREEN:    if(count == GREEN_TIME) begin
                    next_state = YELLOW2;
                    count_rst_n = 1'b0;
                  end
                    
        YELLOW2:  if(count == YELLOW2_TIME) begin
                    next_state = RED;
                    count_rst_n = 1'b0;
                  end
    endcase    
  end
  
  //   //
  always @(posedge clk or negedge rst_n) begin
    if(!rst_n) state <= RED;
    else state <= next_state;
  end
  
    always @(state) begin
	     o_red = 0;
	     o_green = 0;
	     o_yellow = 0;
	   case(state)
		  RED: o_red = 1;
		  YELLOW1: o_yellow = 1;
		  GREEN: o_green = 1;
		  YELLOW2: o_yellow = 1;	
	   endcase
    end
  
  
endmodule
