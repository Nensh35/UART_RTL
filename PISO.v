module piso(
    input load, shift , clk , reset ,
    input [7:0] data ,
    output reg serial_out ,
    input parity 
) ; 

    reg [10:0] ff ;
    
always @(posedge clk or posedge load) begin

    if(reset) begin
        serial_out <= 1'b1 ;
        ff<=11'b11111111111;
    end

    if(load) begin

        ff[8:1] <= data ;
        ff[0]   <= 1'b0 ; 
        ff[9]   <= parity ;
        ff[10]  <= 1'b1 ;
    
    end
    else if(shift) begin

        ff[0] <= ff[1] ;
        ff[1] <= ff[2] ;
        ff[2] <= ff[3] ;
        ff[3] <= ff[4] ;
        ff[4] <= ff[5] ;
        ff[5] <= ff[6] ;
        ff[6] <= ff[7] ;
        ff[7] <= ff[8] ;
        ff[8] <= ff[9] ;
        ff[9] <= ff[10];
        ff[10]<= 1'b0 ;
        serial_out <= ff[0] ;
        //// shift can done like this also ff <= {1'b0, ff[10:1]};

    end
end

endmodule

