module sipo(
    input clk,shift,takeout , Rx_signal,reset ,prtychek_signal ,
    output reg stroing , outing , prty_signal_out
);

    reg mem[7:0] ;
    reg prty1 ,prty2 ,prty3 ,prty4 ,prty5 ,prty6 ,prty7 ;
    always @(posedge clk ) begin 

        if(reset) begin

            stroing <= 0 ;
            outing <= 0;
           // mem <= 8'b0 ;

        end
        if(prtychek_signal) begin

            prty1  <= mem[0] ^ mem[1];
            prty3  <= mem[2] ^ prty1;
            prty4  <= mem[3] ^ prty3;
            prty5  <= mem[4] ^ prty4;
            prty6  <= mem[5] ^ prty5;
            prty7  <= mem[6] ^ prty6;
            prty_signal_out <= mem[7] ^ prty7;
            
        end
        else if (takeout) begin
            outing  <= 1 ;
            stroing <= 0 ;
        end

        else if(shift) begin
            mem[7] <= Rx_signal ;
            mem[6] <= mem[7] ;
            mem[5] <= mem[6] ;
            mem[4] <= mem[5] ;
            mem[3] <= mem[4] ;
            mem[2] <= mem[3] ;
            mem[1] <= mem[2] ;
            mem[0] <= mem[1] ;
            stroing <= 1'b1 ;
        end
    end
endmodule
