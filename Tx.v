`include "PISO.v"

module Tx(
    input Tx_clk , data_flg , 
    input [7:0] data_in ,
    output  Tx_signal
);

// in this we are using even parity 

parameter IDLE=2'b00  , LOAD = 2'b01 , SEND = 2'b10 ;  // state of FSM :
parameter  boud_rate = 1960 ;   // bit per second we need to transmit  ;
parameter bit_cycle = 9  ;   // 1 bit need this much cycle when Tx_clk is 100MHz ;  for 20KHz it will be 10


reg [1:0] state ;
reg load , shift ; 
reg parity , prty1 ,prty2 ,prty3 ,prty4 ,prty5 ,prty6 ,prty7 ;  //for parity calcualtion
reg[3:0] cnt_bit  ;
reg[15:0] cnt_cycle ; 
reg start_bit , start_cycle;
reg continue ;
reg Tx_signal2 ;
reg bit_tick ;  


wire signal_Tx ; 
reg reset_PISO ; 


// parity calcualtion

always @(data_in) begin

        if(data_flg) begin
        
            prty1  = data_in[0] ^ data_in[1];
            prty3  = data_in[2] ^ prty1;
            prty4  = data_in[3] ^ prty3;
            prty5  = data_in[4] ^ prty4;
            prty6  = data_in[5] ^ prty5;
            prty7  = data_in[6] ^ prty6;
            parity = data_in[7] ^ prty7;
        
        end
end


// cycle counter :

always @(posedge Tx_clk) begin
    if(start_cycle)
        cnt_cycle <= 16'b0;

    if(cnt_cycle == bit_cycle ) 
        cnt_cycle <= 0;
        
    else if(continue)
        cnt_cycle <= cnt_cycle + 16'b1 ;
     
end

// bit counter ;
always @(posedge Tx_clk ) begin
    if(start_bit)  
        cnt_bit <= 0 ;

    else if(cnt_cycle == bit_cycle)  begin
        cnt_bit <= cnt_bit + 1 ;
    end

end

// bit tick generator :

always @(posedge Tx_clk ) begin
    
    if( cnt_cycle == bit_cycle - 1)
        bit_tick <= 1'b1 ;
    else
        bit_tick <=1'b0 ;
end


// state transition 
always @(posedge Tx_clk) begin

    case(state) 

    IDLE : state <= data_flg ? LOAD : IDLE ;
    LOAD  : state <= SEND ; 
    SEND  : begin
            if(cnt_bit == 4'd11) 
                state <= IDLE ;
            else state <= SEND ;
        end

    default : state <= IDLE ;

    endcase
    
end


// controller 

always @(*) begin

    load = 0;
    shift = 0;
    continue = 0;
    start_bit = 0;
    start_cycle = 0;
    Tx_signal2 = 1;
    reset_PISO = 0;

    case(state)

    IDLE :  begin
        Tx_signal2 = 1 ;start_bit = 1 ; start_cycle = 1 ; 
        continue = 0 ; load = 0 ; shift= 0 ;reset_PISO = 1;
    end

    LOAD  : begin  load = 1 ;  reset_PISO = 1'b0 ; end 

    SEND  : begin continue =1 ; start_bit = 0 ; start_cycle = 0 ;
        load = 0 ;    Tx_signal2 = signal_Tx ; 
        if(bit_tick)
            shift =1'b1 ;
        else shift = 1'b0 ;
    end

    default : begin
        Tx_signal2 = 1 ; start_bit = 1 ; start_cycle = 1 ;
        continue = 0 ; load = 0 ; shift = 0 ;
    end
    endcase
end

// piso module

piso P1( load, shift , Tx_clk  ,reset_PISO , data_in  ,  signal_Tx ,parity ) ;

assign Tx_signal = Tx_signal2 ;

endmodule
        
