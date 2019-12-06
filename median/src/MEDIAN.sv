module MEDIAN #(parameter NBITS = 8)
	(input [NBITS-1:0]  DI,
	 input DSI,
	 input nRST,
	 input CLK,
	 output logic [NBITS-1:0] DO,
	 output logic DSO);

localparam NPIXELS = 9;
localparam NPXBITS = $clog2(NPIXELS);

logic BYP;
MED #(.NBITS(NBITS), .NPIXELS(NPIXELS)) I_MED (.DI(DI), .DSI(DSI), .BYP(BYP), .CLK(CLK), .DO(DO));

/* There are 6 states:
INIT: set all variables to the default value change immediately le state to LOADPX.
LOADPX: load NPIXELS into I_MED, when the counter (a.k.a. px) reaches NPIXELS, the state changes to BBL_INIT.
BBL_INIT: initalises all variables of this section ans immediatly change the state to BBL_RISE.
BBL_RISE: calculates the maximum of the variables inside I_MED until  */
enum {INIT, LOAD, BBL_INIT, BBL_RISE, BBL_TOP, WB} state;

logic [NPXBITS-1:0] px, nz;

always_comb
if(!nRST)
	state <= INIT;
else if(state == INIT)
	state <= LOAD;
else if(state == LOAD)
	if(px == NPIXELS)
		state <= BBL_INIT;
	else
		state <= LOAD;
else if(state == BBL_INIT)
	state <= BBL_RISE;
else if(state == BBL_RISE)
	if(px >= nz)
		if(nz == NPIXELS/2)
			state <= WB;
		else
			state <= BBL_TOP;
	else
		state <= BBL_RISE;
else if(state == BBL_TOP)
	if(px == NPIXELS)
		state <= BBL_INIT;
	else
		state <= BBL_TOP;
else if(state == WB)
	state <= LOAD;
else
	state <= INIT;

always_ff @(posedge CLK)
if(state == INIT) begin
	DSO <= 1'b0;
	BYP <= 1'b1;
	px <= 0;
	nz <= 9;
end
else if(state == LOAD) begin
	if(DSI) begin
		DSO <= 1'b0;
		px <= px + 1;
	end
	if(px == 8) BYP <= 1'b0;
end
else if(state == BBL_INIT) begin
	BYP <= 1'b0;
	px <= 1;
	nz <= nz - 1;
end
else if(state == BBL_RISE) begin
	px <= px + 1;
end
else if(state == BBL_TOP) begin
	BYP <= 1;
	px <= px + 1;
end
else if(state == WB) begin
	DSO <= 1'b1;
	BYP <= 1'b1;
	px <= 0;
	nz <= 9;
end
endmodule
