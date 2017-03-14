module VM ( i_product,
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
            
input          i_clk, i_rst_n;
input   [3:0]  i_product;
input   [15:0] i_money;
input          i_buy;

output reg  [3:0]  o_product;
output reg  [20:0] o_change;
output reg  [20:0] o_future_change;
output reg     o_busy;
output reg     o_no_change;
output reg     o_strobe;
output reg     o_need_more_money;
output reg     o_empty;


//*******************//
//Amount of banknotes//
//*******************//
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

//*******************//
//Amount of  products//
//*******************//
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

//*******************//
//States of  products//
//*******************//
localparam TEA       = 1;
localparam AMERICANO = 2;
localparam ESPRESSO  = 3;
localparam LATTE     = 4;
localparam CACAO     = 5;
localparam CHOCOLATE = 6;
localparam MILK      = 7;
localparam CAPUCHINO = 8;
localparam JUSE      = 9;
localparam WATER     = 10; //Max width is 4 bits;

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


//*******************//
//***States of VM****//
//*******************//
localparam EMPTY              = 0;
localparam START              = 1;
localparam CHOOSE_PRODUCT     = 2;
localparam WAIT_MONEY         = 3;
localparam CALC_CHANGE        = 4;
localparam CALK_AMOUNT_CHANGE = 5;
localparam NO_CHANGE          = 6;
localparam EMPTY_VM           = 7; //Max width is 3 bits;

//*********************//
//***Local variables***//
//*********************//
reg [2:0] state_VM, next_state_VM;

reg [clog2(LIMIT_TEA)-1:0]        lim_tea_r, next_lim_tea;
reg [clog2(LIMIT_AMERICANO)-1:0]  lim_americano_r, next_lim_americano;
reg [clog2(LIMIT_ESPRESSO)-1:0]   lim_espresso_r, next_lim_espresso;
reg [clog2(LIMIT_LATTE)-1:0]      lim_latte_r, next_lim_latte;
reg [clog2(LIMIT_CACAO)-1:0]      lim_cacao_r, next_lim_cacao;
reg [clog2(LIMIT_CHOCOLATE)-1:0]  lim_chocolate_r, next_lim_chocolate;
reg [clog2(LIMIT_MILK)-1:0]       lim_milk_r, next_lim_milk;
reg [clog2(LIMIT_CAPUCHINO)-1:0]  lim_capuchino_r, next_lim_capuchino;
reg [clog2(LIMIT_JUSE)-1:0]       lim_juse_r, next_lim_juse;
reg [clog2(LIMIT_WATER)-1:0]      lim_water_r, next_lim_water;
integer product_limit;
                              
reg [clog2(LIMIT_50000):0]     limit_50000, next_limit_50000;
reg [clog2(LIMIT_20000):0]     limit_20000, next_limit_20000;
reg [clog2(LIMIT_10000):0]     limit_10000, next_limit_10000;
reg [clog2(LIMIT_5000):0]      limit_5000, next_limit_5000;
reg [clog2(LIMIT_2000):0]      limit_2000, next_limit_2000;
reg [clog2(LIMIT_1000):0]      limit_1000, next_limit_1000;
reg [clog2(LIMIT_500):0]       limit_500, next_limit_500;
reg [clog2(LIMIT_200):0]       limit_200, next_limit_200;
reg [clog2(LIMIT_100):0]       limit_100, next_limit_100;
reg [clog2(LIMIT_50):0]        limit_50, next_limit_50;
reg [clog2(LIMIT_25):0]        limit_25, next_limit_25;
reg [clog2(LIMIT_10):0]        limit_10, next_limit_10;
reg [clog2(LIMIT_5):0]         limit_5, next_limit_5;
reg [clog2(LIMIT_2):0]         limit_2, next_limit_2;
reg [clog2(LIMIT_1):0]         limit_1, next_limit_1;
integer limit_money;

reg [20:0] money, next_money, change, next_change;
reg [20:0] future_change, next_future_change;
reg [15:0] price, next_price;

reg strobe, take_other_product;
reg [3:0] code_product, next_code_product;

wire empty;
assign empty =  !(|lim_tea_r || |lim_americano_r || 
                  |lim_espresso_r || |lim_latte_r || |lim_cacao_r ||
                  |lim_chocolate_r || |lim_milk_r || |lim_capuchino_r || 
                  |lim_juse_r || |lim_water_r);
                

////////////////////////////////////////////////////////
always @(posedge i_clk or negedge i_rst_n) begin
  if (!i_rst_n) begin
    state_VM <= START;
    
    lim_tea_r       <= LIMIT_TEA       ;
    lim_americano_r <= LIMIT_AMERICANO ;
    lim_espresso_r  <= LIMIT_ESPRESSO  ;
    lim_latte_r     <= LIMIT_LATTE     ;
    lim_cacao_r     <= LIMIT_CACAO     ;
    lim_chocolate_r <= LIMIT_CHOCOLATE ;
    lim_milk_r      <= LIMIT_MILK      ;
    lim_capuchino_r <= LIMIT_CAPUCHINO ;
    lim_juse_r      <= LIMIT_JUSE      ;
    lim_water_r     <= LIMIT_WATER     ;
    
    limit_50000  <= LIMIT_50000 ;
    limit_20000  <= LIMIT_20000 ;
    limit_10000  <= LIMIT_10000 ;
    limit_5000   <= LIMIT_5000  ;
    limit_2000   <= LIMIT_2000  ;
    limit_1000   <= LIMIT_1000  ;
    limit_500    <= LIMIT_500   ;
    limit_200    <= LIMIT_200   ;
    limit_100    <= LIMIT_100   ;
    limit_50     <= LIMIT_50    ;
    limit_25     <= LIMIT_25    ;
    limit_10     <= LIMIT_10    ;
    limit_5      <= LIMIT_5     ;
    limit_2      <= LIMIT_2     ;
    limit_1      <= LIMIT_1     ;
    
    price  <= 0;
    money  <= 0;
    change <= 0;
    
    code_product  <= 0; 
    future_change <= 0;  
  end 
  else begin
    state_VM        <= next_state_VM;
    
    lim_tea_r       <= next_lim_tea;
    lim_americano_r <= next_lim_americano;
    lim_espresso_r  <= next_lim_espresso;
    lim_latte_r     <= next_lim_latte;
    lim_cacao_r     <= next_lim_cacao;
    lim_chocolate_r <= next_lim_chocolate;
    lim_milk_r      <= next_lim_milk;
    lim_capuchino_r <= next_lim_capuchino;
    lim_juse_r      <= next_lim_juse;
    lim_water_r     <= next_lim_water;
    
    limit_50000  <= next_limit_50000;
    limit_20000  <= next_limit_20000;
    limit_10000  <= next_limit_10000;
    limit_5000   <= next_limit_5000;
    limit_2000   <= next_limit_2000;
    limit_1000   <= next_limit_1000;
    limit_500    <= next_limit_500;
    limit_200    <= next_limit_200;
    limit_100    <= next_limit_100;
    limit_50     <= next_limit_50;
    limit_25     <= next_limit_25;
    limit_10     <= next_limit_10;
    limit_5      <= next_limit_5;
    limit_2      <= next_limit_2;
    limit_1      <= next_limit_1;
    
    price  <= next_price;
    money  <= next_money;
    change <= next_change;
    
    future_change <= next_future_change;
    
    code_product  <= next_code_product;
    
  end
    
end

always @* begin
  next_state_VM = state_VM;
  
  next_lim_tea        = lim_tea_r       ;
  next_lim_americano  = lim_americano_r ;
  next_lim_espresso   = lim_espresso_r  ;
  next_lim_latte      = lim_latte_r     ;
  next_lim_cacao      = lim_cacao_r     ;
  next_lim_chocolate  = lim_chocolate_r ;
  next_lim_milk       = lim_milk_r      ;
  next_lim_capuchino  = lim_capuchino_r ;
  next_lim_juse       = lim_juse_r      ;
  next_lim_water      = lim_water_r     ;
    
  next_limit_50000 = limit_50000  ;
  next_limit_20000 = limit_20000  ;
  next_limit_10000 = limit_10000  ;
  next_limit_5000  = limit_5000   ;
  next_limit_2000  = limit_2000   ;
  next_limit_1000  = limit_1000   ;
  next_limit_500   = limit_500    ;
  next_limit_200   = limit_200    ;
  next_limit_100   = limit_100    ;
  next_limit_50    = limit_50     ;
  next_limit_25    = limit_25     ;
  next_limit_10    = limit_10     ;
  next_limit_5     = limit_5      ;
  next_limit_2     = limit_2      ;
  next_limit_1     = limit_1      ;
    
  next_price  = price  ;
  next_money  = money  ;
  next_change = 0 ;
  
  next_future_change = future_change;
    
  next_code_product  = code_product ;
  
  
  o_strobe = 1'b0;
  o_no_change = 1'b0;
  o_busy = 1'b0;
  o_empty = 1'b0;
  o_need_more_money = 1'b0;
  case(state_VM) //synopsys full_case parallel_case
    START             : if(empty)       next_state_VM = EMPTY;
                        else
                        if(i_buy)       next_state_VM = CHOOSE_PRODUCT;
    
    CHOOSE_PRODUCT    : begin
                        next_code_product = i_product;
                        o_busy = 1'b1;
                        case(next_code_product)
                          TEA:          product_limit = lim_tea_r;
                          AMERICANO:    product_limit = lim_americano_r;
                          ESPRESSO:     product_limit = lim_espresso_r;
                          LATTE:        product_limit = lim_latte_r;
                          CACAO:        product_limit = lim_cacao_r;
                          CHOCOLATE:    product_limit = lim_chocolate_r;
                          MILK:         product_limit = lim_milk_r;
                          CAPUCHINO:    product_limit = lim_capuchino_r;
                          JUSE:         product_limit = lim_juse_r;
                          WATER:        product_limit = lim_water_r;
                          default:      product_limit = 0;
                        endcase
                        
                        if(product_limit != 0) begin
                          product_limit = product_limit - 1'b1;
                          
                          case(next_code_product)
                            TEA:          begin
                                            next_lim_tea        = product_limit;
                                            next_price          = PRICE_TEA; 
                                          end
                            AMERICANO:    begin
                                            next_lim_americano  = product_limit;
                                            next_price          = PRICE_AMERICANO;
                                          end
                            ESPRESSO:     begin
                                            next_lim_espresso   = product_limit;
                                            next_price          = PRICE_ESPRESSO;
                                          end
                            LATTE:        begin
                                            next_lim_latte      = product_limit;
                                            next_price          = PRICE_LATTE;
                                          end
                            CACAO:        begin
                                            next_lim_cacao      = product_limit;
                                            next_price          = PRICE_CACAO;
                                          end
                            CHOCOLATE:    begin
                                            next_lim_chocolate  = product_limit;
                                            next_price          = PRICE_CHOCOLATE; 
                                          end
                            MILK:         begin
                                            next_lim_milk       = product_limit;
                                            next_price          = PRICE_MILK; 
                                          end
                            CAPUCHINO:    begin
                                            next_lim_capuchino  = product_limit;
                                            next_price          = PRICE_CAPUCHINO; 
                                          end
                            JUSE:         begin
                                            next_lim_juse       = product_limit;
                                            next_price          = PRICE_JUSE; 
                                          end
                            WATER:        begin
                                            next_lim_water      = product_limit;
                                            next_price          = PRICE_WATER; 
                                          end
                            default:      ;
                          endcase
                          
                          take_other_product = 1'b0;
                          next_state_VM = WAIT_MONEY;
                        end
                        else begin
                          take_other_product = 1'b1;
                        end
                      end 
                                         
    WAIT_MONEY        : begin
                        o_busy = 1'b1;
                        next_money = money + i_money;
                        case(i_money)
                          50000: limit_money = limit_50000;
                          20000: limit_money = limit_20000;
                          10000: limit_money = limit_10000;
                          5000 : limit_money = limit_5000;
                          2000 : limit_money = limit_2000;
                          1000 : limit_money = limit_1000;
                          500  : limit_money = limit_500;
                          200  : limit_money = limit_200;
                          100  : limit_money = limit_100;
                          50   : limit_money = limit_50;
                          25   : limit_money = limit_25;
                          10   : limit_money = limit_10;
                          5    : limit_money = limit_5;
                          2    : limit_money = limit_2;
                          1    : limit_money = limit_1;
                          default: limit_money = 0;
                        endcase
                         
                        limit_money = limit_money + 1'b1;
                        
                        case(i_money)
                          50000:   next_limit_50000 = limit_money;
                          20000:   next_limit_20000 = limit_money;
                          10000:   next_limit_10000 = limit_money;
                          5000 :   next_limit_5000  = limit_money;
                          2000 :   next_limit_2000  = limit_money;
                          1000 :   next_limit_1000  = limit_money;
                          500  :   next_limit_500   = limit_money;
                          200  :   next_limit_200   = limit_money;
                          100  :   next_limit_100   = limit_money;
                          50   :   next_limit_50    = limit_money;
                          25   :   next_limit_25    = limit_money;
                          10   :   next_limit_10    = limit_money;
                          5    :   next_limit_5     = limit_money;
                          2    :   next_limit_2     = limit_money;
                          1    :   next_limit_1     = limit_money;
                          default:   ;
                        endcase
                        
                        if(next_money >= price) begin
                          next_state_VM = CALC_CHANGE;
                          o_need_more_money = 0;
                        end
                        else o_need_more_money = 1;
                        end
                          
    CALC_CHANGE       : begin
                          next_future_change   = money - price;
                          next_money           = money - price;
                          next_state_VM        = CALK_AMOUNT_CHANGE;
                          o_busy = 1'b1;
                        end
                        
    CALK_AMOUNT_CHANGE: begin
                         case(1'b1) //synopsys full_case
                          (money >= 50000)&&(limit_50000 != 0): begin
                                                                  next_change = 50000;
                                                                  next_money = money - 50000;
                                                                  next_limit_50000 = limit_50000 - 1'b1;
                                                                 end
                                            
                          (money >= 20000)&&(limit_20000 != 0): begin
                                                                  next_change = 20000;
                                                                  next_money = money - 20000;
                                                                  next_limit_20000 = limit_20000 - 1'b1;
                                                                 end
                                            
                          (money >= 10000)&&(limit_10000 != 0) :begin
                                                                  next_change = 10000;
                                                                  next_money = money - 10000;
                                                                  next_limit_10000 = limit_10000 - 1'b1;
                                                                 end
                                            
                          (money >= 5000)&&(limit_5000 != 0) :begin
                                                                  next_change = 5000;
                                                                  next_money = money - 5000;
                                                                  next_limit_5000 = limit_5000 - 1'b1;
                                                                 end
                                            
                          (money >= 2000)&&(limit_2000 != 0) :begin
                                                                  next_change = 2000;
                                                                  next_money = money - 2000;
                                                                  next_limit_2000 = limit_2000 - 1'b1;
                                                                 end
                                            
                          (money >= 1000)&&(limit_1000 != 0): begin
                                                                  next_change = 1000;
                                                                  next_money = money - 1000;
                                                                  next_limit_1000 = limit_1000 - 1'b1;
                                                                 end
                                            
                          (money >= 500)&&(limit_500 != 0) :begin
                                                                  next_change = 500;
                                                                  next_money = money - 500;
                                                                  next_limit_500 = limit_500 - 1'b1;
                                                                 end
                                            
                          (money >= 200)&&(limit_200 != 0): begin
                                                                  next_change = 200;
                                                                  next_money = money - 200;
                                                                  next_limit_200 = limit_200 - 1'b1;
                                                                 end
                                            
                          (money >= 100)&&(limit_100 != 0)     : begin
                                                                  next_change = 100;
                                                                  next_money = money - 100;
                                                                  next_limit_100 = limit_100 - 1'b1;
                                                                 end
                                            
                          (money >= 50)&&(limit_50 != 0)        : begin
                                                                  next_change = 50;
                                                                  next_money = money - 50;
                                                                  next_limit_50 = limit_50 - 1'b1;
                                                                 end
                                            
                          (money >= 25)&&(limit_25 != 0)       : begin
                                                                  next_change = 25;
                                                                  next_money = money - 25;
                                                                  next_limit_25 = limit_25 - 1'b1;
                                                                 end
                                            
                          (money >= 10)&&(limit_10 != 0)       : begin
                                                                  next_change = 10;
                                                                  next_money = money - 10;
                                                                  next_limit_10 = limit_10 - 1'b1;
                                                                 end
                                            
                          (money >= 5)&&(limit_5 != 0)         : begin
                                                                  next_change = 5;
                                                                  next_money = money - 5;
                                                                  next_limit_5 = limit_5 - 1'b1;
                                                                 end
                                            
                          (money >= 2)&&(limit_2 != 0)         : begin
                                                                  next_change = 2;
                                                                  next_money = money - 2;
                                                                  next_limit_2 = limit_2 - 1'b1;
                                                                 end
                                            
                          (money >= 1)&&(limit_1 != 0)         : begin
                                                                  next_change = 1;
                                                                  next_money = money - 1;
                                                                  next_limit_1 = limit_1 - 1'b1;
                                                                 end
                                                                
                        endcase
                        
                        
                                    
                        o_busy = 1'b1;
                        if(next_money == 0) begin
                          next_state_VM = START;
                          o_strobe = 1'b1; 
                        end
                        else begin
                          if(limit_1 == 0) next_state_VM = NO_CHANGE;
                        end
                      end
                      
   NO_CHANGE          : begin
                          next_state_VM = START;
                          o_no_change = 1;
                          o_strobe = 1'b1; 
                        end
                        
   EMPTY              : o_empty = 1;
  endcase
end// always end

always @* begin
  o_change = change;
  o_product = code_product;
  o_future_change = future_change;
end



//Logarifm function//
function integer clog2; 
   input integer value; 
   begin 
     value = value-1; 
     for (clog2=0; value>0; clog2=clog2+1) 
       value = value>>1; 
   end 
endfunction

endmodule

