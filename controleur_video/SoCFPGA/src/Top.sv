`default_nettype none

module Top #(
    parameter HDISP = 800,
    parameter VDISP = 480
) (
    // Les signaux externes de la partie FPGA
	input  wire         FPGA_CLK1_50,
	input  wire  [1:0]	KEY,
	output logic [7:0]	LED,
	input  wire	 [3:0]	SW,
    // Les signaux du support matériel son regroupés dans une interface
    hws_if.master       hws_ifm,
    video_if.master       video_ifm
);

//====================================
//  Déclarations des signaux internes
//====================================
  wire        sys_rst;   // Le signal de reset du système
  wire        sys_clk;   // L'horloge système a 100Mhz
  wire        pixel_clk; // L'horloge de la video 32 Mhz
  logic       pixel_rst; // Le signal de reset du video

//=======================================================
//  La PLL pour la génération des horloges
//=======================================================

sys_pll  sys_pll_inst(
		   .refclk(FPGA_CLK1_50),   // refclk.clk
		   .rst(1'b0),              // pas de reset
		   .outclk_0(pixel_clk),    // horloge pixels a 32 Mhz
		   .outclk_1(sys_clk)       // horloge systeme a 100MHz
);

//=============================
//  Les bus Wishbone internes
//=============================
wshb_if #( .DATA_BYTES(4)) wshb_if_sdram  (sys_clk, sys_rst);
wshb_if #( .DATA_BYTES(4)) wshb_if_stream (sys_clk, sys_rst);

//=============================
//  Le support matériel
//=============================
hw_support hw_support_inst (
    .wshb_ifs (wshb_if_sdram),
    .wshb_ifm (wshb_if_stream),
    .hws_ifm  (hws_ifm),
	.sys_rst  (sys_rst), // output
    .SW_0     ( SW[0] ),
    .KEY      ( KEY )
 );

//=============================
// On neutralise l'interface
// du flux video pour l'instant
// A SUPPRIMER PLUS TARD
//=============================
assign wshb_if_stream.ack = 1'b1;
assign wshb_if_stream.dat_sm = '0 ;
assign wshb_if_stream.err =  1'b0 ;
assign wshb_if_stream.rty =  1'b0 ;

//=============================
// On neutralise l'interface SDRAM
// pour l'instant
// A SUPPRIMER PLUS TARD
//=============================
assign wshb_if_sdram.stb  = 1'b0;
assign wshb_if_sdram.cyc  = 1'b0;
assign wshb_if_sdram.we   = 1'b0;
assign wshb_if_sdram.adr  = '0  ;
assign wshb_if_sdram.dat_ms = '0 ;
assign wshb_if_sdram.sel = '0 ;
assign wshb_if_sdram.cti = '0 ;
assign wshb_if_sdram.bte = '0 ;

//--------------------------
//------- Code Eleves ------
//--------------------------

`ifdef SIMULATION
    localparam led1cmpt = 99;
	localparam led2cmpt = 31;
`else
    localparam led1cmpt = 50000000;
	localparam led2cmpt = 16000000;
`endif

vga #(.HDISP(HDISP), .VDISP(VDISP))
      vga_inst (
          .pixel_clk(pixel_clk),
          .pixel_rst(pixel_rst),
          .video_ifm(video_ifm)
          );


assign LED[0] = KEY[0];
assign LED[7:3] = 5'b0;

//=============================
// Declaration du schéma de reset
//=============================

// Intermédiaire valeur du signal pixel_rst
logic pixel_rst_int;

always_ff @(posedge pixel_clk or posedge sys_rst)
    if(sys_rst) begin
        pixel_rst <= 1;
        pixel_rst_int <= 1;
    end
    else begin
        pixel_rst_int <= 0;
        pixel_rst <= pixel_rst_int;
    end

//===================================
//  LED clignote - sys_clk
//===================================

localparam cnt1_size = $clog2(led1cmpt)-1;
logic [cnt1_size:0] led1_cnt;
always_ff @(posedge sys_clk or posedge sys_rst)
    if(sys_rst) begin
        led1_cnt <= 1;
        LED[1] <= 0;
    end
    else
    begin
    led1_cnt <= led1_cnt + 1'b1;

    if(led1_cnt == led1cmpt) begin
        led1_cnt <= 1;
        LED[1] <= ~LED[1];
    end
end

//===================================
//  LED clignote - pixel_clk
//===================================

localparam cnt2_size = $clog2(led2cmpt)-1;
logic [cnt2_size:0] led2_cnt;
always_ff @(posedge pixel_clk or posedge pixel_rst)
    if(pixel_rst) begin
        led2_cnt <= 1;
        LED[2] <= 0;
    end
    else
    begin
    led2_cnt <= led2_cnt + 1'b1;

    if(led2_cnt == led2cmpt) begin
        led2_cnt <= 1;
        LED[2] <= ~LED[2];
    end
end


endmodule
