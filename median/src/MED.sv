module MED #(parameter NBITS = 8, NPIXELS = 9)
            (input [NBITS-1:0] DI,
             input DSI,
             input BYP,
             input CLK,
             output [NBITS-1:0] DO);

wire [NBITS-1:0] A, B, MIN, MAX;

genvar i;
generate
	for(i = 0; i <= NPIXELS-1; i++)
	begin: ff
		wire [NBITS-1:0] D, Q;
		wire RST = 1'b0;
		FF #(.NBITS(NBITS)) R(.CLK(CLK), .RST(RST), .D(D), .Q(Q));
	end
endgenerate

for(i = 0; i <= NPIXELS-3; i++)
begin
	assign ff[i+1].D = ff[i].Q;
end

assign ff[0].D = (DSI)? DI : MIN;
assign ff[NPIXELS-1].D = (BYP)? ff[NPIXELS-2].Q : MAX;

assign A = ff[NPIXELS-1].Q;
assign B = ff[NPIXELS-2].Q;
assign DO = ff[NPIXELS-1].Q;

MCE #(.NBITS(NBITS)) I_MCE(.A(A), .B(B), .MAX(MAX), .MIN(MIN));

endmodule
