module FF #(parameter NBITS = 8)
	(input CLK, RST,
	 input [NBITS-1:0] D,
	 output logic [NBITS-1:0] Q);

always_ff @(posedge CLK)
	if(RST)
		Q <= {NBITS{1'b0}};
	else
		Q <= D;

endmodule
