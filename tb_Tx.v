`timescale 1us/1us 
`include "Tx.v" 

module tb();

wire Tx_signal ;
reg[7:0] data_in ;
reg data_flg , Tx_clk ;

    Tx t1(Tx_clk , data_flg ,data_in ,Tx_signal );

always #25 Tx_clk = ~Tx_clk ; //10ns means 100MHz ;

    initial  begin 
    data_flg <= 0 ;
    Tx_clk <= 0 ;
    data_in <= 0 ;

    $dumpfile("Tx.vcd");
    $dumpvars(0,tb) ;

    #60 data_flg = 1 ; data_in <= 8'b10101010 ;
    #60 data_flg = 0 ;
    #60 data_in <= 8'b0;
    

    #10000 $finish ;

    end

endmodule