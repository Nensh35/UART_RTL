`include "SIPO.v" 

module Rx(
    input Tx_signal_in , Rx_clk ,
    output reg Rx_signal
);

parameter IDLE = 3'b00 , START = 3'b001 , DATASTR = 3'b010 , PRTYCHEK = 3'b011 , LAST = 3'b100 ,  bit_cycle=4 ,
          total_bit = 11 ;


// reg needs for counters and sampling

reg [3:0] cnt_cycle ;
reg [4:0] cnt_bit   ;
reg sampling ;
reg start_count ;
reg continue     ;
reg Tx_signal_snq1 , Tx_signal ;

always @(posedge Rx_clk ) begin
    Tx_signal_snq1 <= Tx_signal_in ;
    Tx_signal <= Tx_signal_snq1 ;
end


// controller signal need to send properly 

reg shift , takeout , reset_SIPO , Foult_startbit , Foult_endbit , Foult_prtybit ;
reg input_prty ;
reg [2:0] state ;
reg prty_signal ; 
wire prty_signal_out_SIPO ;
wire Rx_prty ;


//cycle counter ;
always @(posedge Rx_clk) begin
    if(start_count) begin
        cnt_cycle <= 0 ;
    end

    else if(cnt_cycle == bit_cycle)
        cnt_cycle <= 0 ;

    else if(continue)
        cnt_cycle <= cnt_cycle + 1 ;

end

// bit counter
always @(posedge Rx_clk) begin

    if(start_count)
        cnt_bit <= 0;
    
    else if(cnt_bit == total_bit )
        cnt_bit <= 0;
    
    else if(cnt_cycle == bit_cycle-1)
        cnt_bit <= cnt_bit + 1 ;
end

// sampling
always @(posedge Rx_clk ) begin
    if(cnt_cycle == 2)
        sampling <= 1;
    else sampling <= 0;

end

/// FSM state transition 

always @(posedge Rx_clk) begin

    case(state)
        IDLE    : state <= Tx_signal ? IDLE : START ;
   
        START    : begin 
                    if(cnt_bit == 1)
                       state <= DATASTR ;
                    else
                       state <= START ;
                    end
           
        DATASTR  : begin
                    if(cnt_bit == 9)
                        state <= PRTYCHEK ;
                    else
                        state <= DATASTR ;
                    end

        PRTYCHEK : begin

                    if(cnt_bit == 10) 
                        state <= LAST ;
                    else 
                        state <= PRTYCHEK ;
                    end

        LAST     : begin
                    if(cnt_bit == 11)
                        state <= IDLE ;
                    else 
                        state<= LAST ;
                    end
        
        default  : state <= IDLE ;

    endcase
    
end

/// controller 

always @(*) begin

    shift = 0;
    takeout =0 ;
    reset_SIPO =0 ;
    Foult_endbit = 0 ;
    Foult_prtybit = 0 ;
    Foult_startbit = 0 ;
    Rx_signal = 1 ;
    prty_signal = 0;

    case(state)

        IDLE : begin 
                shift = 0;
                takeout =0 ;
                reset_SIPO =0 ;
                Foult_endbit = 0 ;
                Foult_prtybit = 0 ;
                Foult_startbit = 0 ;
                Rx_signal = Tx_signal ;
                prty_signal = 0;  
                start_count = 1 ;
                continue =0;
            end
        
        START : begin
                shift = 0 ;
                takeout = 0 ;
                reset_SIPO = 1 ;
                Foult_endbit = 0 ;
                Foult_prtybit = 0 ;
                prty_signal = 0;
                start_count = 0 ;
                continue = 1 ;

                if(sampling)begin
                    Rx_signal  = Tx_signal ;

                    if(Tx_signal) 
                        Foult_startbit =  1;
                    else Foult_startbit = 0;

                end
                else Rx_signal = Tx_signal ;
            end

        DATASTR : begin
                takeout = 0 ;
                reset_SIPO = 0 ;
                Foult_endbit = 0 ;
                Foult_prtybit = 0 ;
                Foult_startbit = 0 ;
                prty_signal = 0;
                start_count = 0 ;
                continue = 1 ; 

                if(sampling) begin
                    Rx_signal = Tx_signal ;
                    shift = 1 ;
                end
                else begin
                    Rx_signal = Tx_signal ;
                    shift =  0 ; 
                end
        end
        
        PRTYCHEK : begin
                    shift = 0 ;
                    takeout = 0 ;
                    reset_SIPO = 0 ;
                    Foult_endbit = 0 ;
                    start_count = 0 ;
                    continue = 1 ;
                    prty_signal = 1 ;

                    if(sampling) begin
                        Rx_signal = Tx_signal ;
                        if(prty_signal_out_SIPO == Tx_signal ) 
                            Foult_prtybit = 0 ;
                        else Foult_prtybit = 1 ;
                    end
                    else Rx_signal = Tx_signal ;
        end
        
        LAST    : begin
                shift = 0 ;
                takeout = 1 ;
                reset_SIPO = 0 ;
                Foult_prtybit = 0 ;
                Foult_startbit = 0 ;
                prty_signal = 0;
                start_count = 0 ;
                continue = 1 ; 

                if(sampling) begin
                    Rx_signal =Tx_signal ;
                    if(Rx_signal)
                        Foult_endbit = 0 ;
                    else Foult_endbit = 1;
                end
        end

        default : begin
                shift = 0;
                takeout =0 ;
                reset_SIPO =0 ;
                Foult_endbit = 0 ;
                Foult_prtybit = 0;
                Foult_startbit = 0 ;
                Rx_signal = 1 ;
                prty_signal = 0;
        end

    endcase

end

sipo s1 (Rx_clk , shift ,takeout , Rx_signal, reset_SIPO , prty_signal , stroing , outing , prty_signal_out_SIPO ) ;

endmodule