module MCE #(parameter NBITS = 8)
    (input [NBITS-1:0] A,
     input [NBITS-1:0] B,
     output [NBITS-1:0] MAX,
     output [NBITS-1:0] MIN );

assign MAX = (A < B) ? B : A;
assign MIN = (A < B) ? A : B;

endmodule