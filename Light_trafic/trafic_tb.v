`timescale 1ns / 1ps
module trafic_tb;
  reg   clk, n_rst;
  wire  o_red, o_yellow, o_green;
  
  parameter PERIOD = 4;
  
  parameter RED_TIME     = 5;
  parameter GREEN_TIME   = 5;
  parameter YELLOW1_TIME = 1;
  parameter YELLOW2_TIME = 2;
  
  //FSM_lights FSM_lights1
    trafic #(.RED_TIME(RED_TIME),
             .GREEN_TIME(GREEN_TIME),
             .YELLOW1_TIME(YELLOW1_TIME),
             .YELLOW2_TIME(YELLOW2_TIME)
             )
    
          trafic1       ( .clk(clk), 
                          .rst_n(n_rst), 
                          .o_red(o_red), 
                          .o_yellow(o_yellow), 
                          .o_green(o_green)
                          );
                          
  initial begin
    clk = 0;
    forever #(PERIOD/2) clk = ~clk;  
  end                       
  
  initial begin
    n_rst = 1'b1;
    #(2*PERIOD) n_rst = 1'b0;
    #(2*PERIOD) n_rst = 1'b1;
    
    #100 $finish;    
  end
  
  initial begin
    forever
    @(posedge o_green) $display("GREEN");
  end
  
  initial begin
    forever
    @(posedge o_red) $display("RED");
  end
  
  initial begin
    forever
    @(posedge o_yellow) $display("YELLOW");
  end
  
endmodule
