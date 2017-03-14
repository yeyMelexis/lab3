//`define FEW_PRODUCTS;
`define FEW_BANCNOTES;

`timescale 1ns / 1ps
module VM_tb;
reg          i_clk, i_rst_n;
reg   [3:0]  i_product;
reg   [15:0] i_money;
reg   [15:0] ar_i_money [0:14];
reg          i_buy;


wire  [3:0]  o_product;
wire  [20:0] o_change;
wire  [20:0] o_future_change;
wire     o_busy;
wire     o_no_change;
wire     o_strobe;
wire     o_need_more_money;
wire     o_empty;

//*******************//
//Amount of banknotes//
//*******************//
`ifdef FEW_BANCNOTES
parameter LIMIT_50000 = 0;
parameter LIMIT_20000 = 0;
parameter LIMIT_10000 = 0;
parameter LIMIT_5000  = 0;
parameter LIMIT_2000  = 0;
parameter LIMIT_1000  = 0;
parameter LIMIT_500   = 0;
parameter LIMIT_200   = 0;
parameter LIMIT_100   = 0;
parameter LIMIT_50    = 0;
parameter LIMIT_25    = 0;
parameter LIMIT_10    = 0;
parameter LIMIT_5     = 0;
parameter LIMIT_2     = 0;
parameter LIMIT_1     = 2;
`else
parameter LIMIT_50000 = 10;
parameter LIMIT_20000 = 10;
parameter LIMIT_10000 = 10;
parameter LIMIT_5000  = 10;
parameter LIMIT_2000  = 10;
parameter LIMIT_1000  = 10;
parameter LIMIT_500   = 10;
parameter LIMIT_200   = 10;
parameter LIMIT_100   = 10;
parameter LIMIT_50    = 10;
parameter LIMIT_25    = 10;
parameter LIMIT_10    = 10;
parameter LIMIT_5     = 10;
parameter LIMIT_2     = 10;
parameter LIMIT_1     = 10;
`endif

//*******************//
//Amount of  products//
//*******************//
`ifdef FEW_PRODUCTS
parameter LIMIT_TEA       = 1;
parameter LIMIT_AMERICANO = 0;
parameter LIMIT_ESPRESSO  = 0;
parameter LIMIT_LATTE     = 0;
parameter LIMIT_CACAO     = 0;
parameter LIMIT_CHOCOLATE = 0;
parameter LIMIT_MILK      = 0;
parameter LIMIT_CAPUCHINO = 0;
parameter LIMIT_JUSE      = 0;
parameter LIMIT_WATER     = 0;
`else
parameter LIMIT_TEA       = 10;
parameter LIMIT_AMERICANO = 10;
parameter LIMIT_ESPRESSO  = 10;
parameter LIMIT_LATTE     = 10;
parameter LIMIT_CACAO     = 10;
parameter LIMIT_CHOCOLATE = 10;
parameter LIMIT_MILK      = 10;
parameter LIMIT_CAPUCHINO = 10;
parameter LIMIT_JUSE      = 10;
parameter LIMIT_WATER     = 10;
`endif
//*******************//
//Prices of  products//
//*******************//
parameter PRICE_TEA       = 100;
parameter PRICE_AMERICANO = 100;
parameter PRICE_ESPRESSO  = 100;
parameter PRICE_LATTE     = 100;
parameter PRICE_CACAO     = 100;
parameter PRICE_CHOCOLATE = 100;
parameter PRICE_MILK      = 100;
parameter PRICE_CAPUCHINO = 100;
parameter PRICE_JUSE      = 100;
parameter PRICE_WATER     = 100; //Max width is 4 bits;



  //Clok generator
  parameter PERIOD = 4;                          
  initial begin
    i_clk = 0;
    forever #(PERIOD/2) i_clk = ~i_clk;  
  end                       
  //
  
  reg [3:0] i,j;
  initial begin
    ar_i_money[0] = 1;
    ar_i_money[1] = 2;
    ar_i_money[2] = 5;
    ar_i_money[3] = 10;
    ar_i_money[4] = 25;
    ar_i_money[5] = 50;
    ar_i_money[6] = 100;
    ar_i_money[7] = 200;
    ar_i_money[8] = 500;
    ar_i_money[9] = 1000;
    ar_i_money[10] = 2000;
    ar_i_money[11] = 5000;
    ar_i_money[12] = 10000;
    ar_i_money[13] = 20000;
    ar_i_money[14] = 50000;
    ar_i_money[15] = 0;
    
    i_rst_n = 1'b1;
    #(2*PERIOD) i_rst_n = 1'b0;
    #(2*PERIOD) i_rst_n = 1'b1;
    
    for(j = 1; j <= 10; j = j+1) begin
      VM_control(j);
      @(negedge o_strobe);
    end
 
    #100 $finish;   
  end
  
  //INITIAL READ BLOCK
  initial begin
    forever begin
      @(posedge o_strobe)
      $display("CHANGE IS %d", o_future_change);
    end
  end
  
  initial begin
      @(posedge o_empty);
      $display("VM IS EMPTY");
      if(o_empty)     $finish;      
  end
  
  initial begin
    forever begin
      @(posedge o_no_change);
      $display("SORRY but money is over");  
      $display("Please call to 044-777-1-555");
    end   
  end
  
           
            
   task VM_control;
     input [3:0] product_ref;
     reg   [16:0] buf_money;
   begin
     @(negedge i_clk);
     //Step 1: Start
      i_buy = 1;
     @(negedge i_clk);
      i_buy = 0;
      
    //Step 2: Choose the product
    case(product_ref)
                          1:    begin
                                  $display("--TEA--");
                                  $display("Price = %d",PRICE_TEA        );
                                end
                          2:    begin
                                  $display("--AMERICANO--");
                                  $display("Price = %d", PRICE_AMERICANO );
                                end
                          3:    begin
                                  $display("--ESPRESSO--");
                                  $display("Price = %d", PRICE_ESPRESSO  );
                                end
                          4:    begin
                                  $display("--LATTE--");
                                  $display("Price = %d", PRICE_LATTE     );
                                end
                          5:    begin
                                  $display("--CACAO--");
                                  $display("Price = %d", PRICE_CACAO     );
                                end
                          6:    begin
                                  $display("--CHOCOLATE--");
                                  $display("Price = %d", PRICE_CHOCOLATE );
                                end
                          7:    begin
                                  $display("--MILK--");
                                  $display("Price = %d", PRICE_MILK      );
                                end
                          8:    begin
                                  $display("--CAPUCHINO--");
                                  $display("Price = %d", PRICE_CAPUCHINO );
                                end
                          9:    begin
                                  $display("--JUSE--");
                                  $display("Price = %d", PRICE_JUSE      );
                                end
                          10:   begin
                                  $display("--WATER--");
                                  $display("Price = %d", PRICE_WATER     );
                                end
                          default: $display("--WRONG PRODUCT--");
    endcase

    i_product = product_ref;
    
    @(negedge i_clk);
    
    //Step 3: Give VM money
    
    if(!o_need_more_money)begin
      i = $random;
      i_money = ar_i_money[i];
    end
    else
    while(o_need_more_money == 1) begin 
      i         = $random;
      i_money   = ar_i_money[i];     
      @(negedge i_clk);
    end
    
    @(negedge i_clk);
    $display("Amount of money = %d", VM1.money);
    end
   endtask
   
   
  VM 
  #(.LIMIT_50000(LIMIT_50000),
  .LIMIT_20000 (LIMIT_20000 ),
  .LIMIT_10000 (LIMIT_10000 ),
  .LIMIT_5000  (LIMIT_5000  ),
  .LIMIT_2000  (LIMIT_2000  ),
  .LIMIT_1000  (LIMIT_1000  ),
  .LIMIT_500   (LIMIT_500   ),
  .LIMIT_200   (LIMIT_200   ),
  .LIMIT_100   (LIMIT_100   ),
  .LIMIT_50    (LIMIT_50    ),
  .LIMIT_25    (LIMIT_25    ),
  .LIMIT_10    (LIMIT_10    ),
  .LIMIT_5     (LIMIT_5     ),
  .LIMIT_2     (LIMIT_2     ),
  .LIMIT_1     (LIMIT_1     ),
  
  .LIMIT_TEA       (LIMIT_TEA       ),
  .LIMIT_AMERICANO (LIMIT_AMERICANO ),
  .LIMIT_ESPRESSO  (LIMIT_ESPRESSO  ),
  .LIMIT_LATTE     (LIMIT_LATTE     ),
  .LIMIT_CACAO     (LIMIT_CACAO     ),
  .LIMIT_CHOCOLATE (LIMIT_CHOCOLATE ),
  .LIMIT_MILK      (LIMIT_MILK      ),
  .LIMIT_CAPUCHINO (LIMIT_CAPUCHINO ),
  .LIMIT_JUSE      (LIMIT_JUSE      ),
  .LIMIT_WATER     (LIMIT_WATER     ),
  
  .PRICE_TEA       (PRICE_TEA       ),
  .PRICE_AMERICANO (PRICE_AMERICANO ),
  .PRICE_ESPRESSO  (PRICE_ESPRESSO  ),
  .PRICE_LATTE     (PRICE_LATTE     ),
  .PRICE_CACAO     (PRICE_CACAO     ),
  .PRICE_CHOCOLATE (PRICE_CHOCOLATE ),
  .PRICE_MILK      (PRICE_MILK      ),
  .PRICE_CAPUCHINO (PRICE_CAPUCHINO ),
  .PRICE_JUSE      (PRICE_JUSE      ),
  .PRICE_WATER     (PRICE_WATER     )
   )
      VM1( i_product,
            i_money,
            i_buy,
            i_clk,
            i_rst_n,
            o_product,
            o_change,
            o_busy,
            o_no_change,
            o_strobe,
            o_need_more_money,
            o_future_change,
            o_empty);
            
endmodule