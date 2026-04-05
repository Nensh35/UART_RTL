`timescale 1ns/1ns 
`include "Tx.v"
`include "Rx.v"


module tb();

wire Tx_signal , Rx_signal ;
reg[7:0] data_in ;
reg data_flg , Tx_clk , Rx_clk ;

    Tx t1(Tx_clk , data_flg ,data_in ,Tx_signal );
    Rx r1(Tx_signal , Rx_clk , Rx_signal ) ;


always #5 Tx_clk = ~Tx_clk ; 

always #10 Rx_clk = ~Rx_clk ; 

    initial  begin 
    data_flg <= 0 ;
    Tx_clk <= 0 ;
    Rx_clk <= 0 ;
    data_in <= 0 ;

    $dumpfile("Tx_Rx.vcd");
    $dumpvars(0,tb) ;

    #120 data_flg = 1 ; data_in <= 8'b10101010;
    #100 data_flg = 0 ;
    #60 data_in <= 8'b0;
    

    #100000
    $display("value in the sipo finaly 7 to 0 order %d %d %d %d  %d %d %d %d" , r1.s1.mem[7] , r1.s1.mem[6] , r1.s1.mem[5] ,
                 r1.s1.mem[4] , r1.s1.mem[3] , r1.s1.mem[2] , r1.s1.mem[1] , r1.s1.mem[0] ) ;
    $finish ;

    end

endmodule
