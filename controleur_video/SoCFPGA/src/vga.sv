module vga #(
    parameter HDISP = 800, // Largeur de l'image affichée
    parameter VDISP = 480  // Hauteur de l'image affichée
) (
    input wire      pixel_clk,
    input wire      pixel_rst,
    video_if.master video_ifm,
    wshb_if.master  wshb_ifm
);

localparam HFP      = 40; // Horizontal Front Porch
localparam HPULSE   = 48; // Largeur de la synchro ligne
localparam HBP      = 40; // Horizontal Back Porch
localparam VFP      = 13; // Vertical Front Porch
localparam VPULSE	= 3;  // Largeur de la sync image
localparam VBP      = 29; // Vertical Back Porch

localparam XMARGIN = HFP + HPULSE + HBP;
localparam YMARGIN = VFP + VPULSE + VBP;
localparam XLEN    = HDISP + XMARGIN;
localparam YLEN    = VDISP + YMARGIN;

localparam xbits = $clog2(XLEN); // Nombre de bits du compteur px
localparam ybits = $clog2(YLEN); // Nombre de bits du compteur py

localparam uxbits = $clog2(HDISP); // Nombre de bits du compteur x
localparam uybits = $clog2(VDISP); // Nombre de bits du compteur y

assign video_ifm.CLK = pixel_clk;

logic [xbits-1:0] px; // Compteur de pixels
logic [ybits-1:0] py; // Compteur de lignes

// Wishbone
assign wshb_ifm.dat_ms = '0; // Donnée 32 bits émises
//assign wshb_ifm.adr    = '0;           // Adresse d'écriture
//assign wshb_ifm.cyc    = 1'b1;         // Le bus est sélectionné
assign wshb_ifm.sel    = 4'b0111;      // Les 4 octets sont à écrire
// assign wshb_ifm.stb    = 1'b1;         // Nous demandons une transaction
assign wshb_ifm.we     = 1'b0;         // Transaction en lecture
assign wshb_ifm.cti    = '0;           // Transfert classique
assign wshb_ifm.bte    = '0;           // sans utilité.


always_ff @(posedge wshb_ifm.clk or posedge wshb_ifm.rst)
if(wshb_ifm.rst)
    wshb_ifm.adr <= '0;
else
    if(wshb_ifm.ack)
        if(wshb_ifm.adr == 4*(HDISP*VDISP-1))
            wshb_ifm.adr <= '0;
        else
            wshb_ifm.adr <= wshb_ifm.adr + 4;

// Async FIFO
logic        fifo_read;
logic [31:0] fifo_rdata;
logic        fifo_rempty;
logic [31:0] fifo_wdata;
logic        fifo_write;
logic        fifo_wfull;
logic        fifo_walmost_full;

async_fifo #(
    .DATA_WIDTH(32),
    .DEPTH_WIDTH(8),
    .ALMOST_FULL_THRESHOLD(2**8-32)
    ) fifo (
        .rst(wshb_ifm.rst),
        .rclk(pixel_clk),
        .read(fifo_read),
        .rdata(fifo_rdata),
        .rempty(fifo_rempty),
        .wclk(wshb_ifm.clk),
        .wdata(fifo_wdata),
        .write(fifo_write),
        .wfull(fifo_wfull),
        .walmost_full(fifo_walmost_full)
    );

assign fifo_wdata = wshb_ifm.dat_sm;
assign fifo_write = wshb_ifm.ack;
assign wshb_ifm.stb = wshb_ifm.cyc;

// logic cyc_en;
// assign wshb_ifm.cyc = cyc_en & !fifo_wfull;
assign wshb_ifm.cyc = !fifo_wfull;

// always_ff @(posedge wshb_ifm.clk or posedge wshb_ifm.rst)
// if(wshb_ifm.rst)
//     cyc_en <= 1'b1;
// else
// begin
//     if(!fifo_walmost_full) cyc_en <= 1'b1;
//     if(fifo_wfull) cyc_en <= 1'b0;
// end

logic vga_wfull_int, vga_wfull;
always_ff @(posedge pixel_clk or posedge pixel_rst)
if(pixel_rst)
begin
    vga_wfull_int <= 1'b0;
    vga_wfull <= 1'b0;
end
else
begin
    vga_wfull_int <= fifo_wfull;
    if(px >= HDISP && py >= VDISP)
        vga_wfull <= vga_wfull_int;
end

//assign video_ifm.RGB = {fifo_rdata[7:0], fifo_rdata[15:8], fifo_rdata[23:16]};
assign video_ifm.RGB = fifo_rdata[23:0];
assign fifo_read = !fifo_rempty && vga_wfull && video_ifm.BLANK;

// Incrementeur des compteurs
always_ff @(posedge pixel_clk or posedge pixel_rst)
 if(pixel_rst) begin
    px <= '0;
    py <= '0;
 end
 else
 begin
    if(px >= XLEN-1) begin
        px <= '0;
        py <= py + 1'b1;
        if(py >= YLEN-1) py <= '0;
    end
    else
        px <= px + 1'b1;
end

// Controleur des signals HS, VS et BLANK
always_ff @(posedge pixel_clk) begin
    video_ifm.HS <= (px < HDISP+HFP || px >= HDISP+HFP+HPULSE) ;
    video_ifm.VS <= (py < VDISP+VFP || py >= VDISP+VFP+VPULSE) ;
end

// Controleur du signal BLANK
always_ff @(posedge pixel_clk) begin
    video_ifm.BLANK <= (px < HDISP && py < VDISP) ;
end

endmodule
