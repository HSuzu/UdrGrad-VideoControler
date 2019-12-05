module MED #(parameter NBITS = 8, NPIXELS = 9)
            (input [NBITS-1:0] DI,
             input DSI,
             input BYP,
             input CLK,
             output [NBITS-1:0] DO);

wire [NBITS-1:0] A, B, MIN, MAX;
logic [NBITS-1:0] R [NPIXELS-1:0];

assign A = R[NPIXELS-1];
assign B = R[NPIXELS-2];

MCE I_MCE(.A(A), .B(B), .MAX(MAX), .MIN(MIN));

always_ff @(posedge CLK)
begin
    if(DSI)
        R[0] <= DI;
    else
        R[0] <= MIN;

    if(NPIXELS >= 3)
        R[NPIXELS-2:1] <= R[NPIXELS-3:0];

    if(BYP)
        R[NPIXELS-1] <= R[NPIXELS-2];
    else
        R[NPIXELS-1] <= MAX;
end

assign DO = R[NPIXELS-1];

endmodule
