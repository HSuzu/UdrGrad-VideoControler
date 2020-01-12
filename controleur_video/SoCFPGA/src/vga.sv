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

logic [uxbits-1:0] x; // Coordonnée x du pixel actif
logic [uybits-1:0] y; // Coordonnée y du pixel actif

// Wishbone
assign wshb_ifm.dat_ms = 32'hBABECAFE; // Donnée 32 bits émises
assign wshb_ifm.adr    = '0;           // Adresse d'écriture
assign wshb_ifm.cyc    = 1'b1;         // Le bus est sélectionné
assign wshb_ifm.sel    = 4'b1111;      // Les 4 octets sont à écrire
assign wshb_ifm.stb    = 1'b1;         // Nous demandons une transaction
assign wshb_ifm.we     = 1'b1;         // Transaction en écriture
assign wshb_ifm.cti    = '0;           // Transfert classique
assign wshb_ifm.bte    = '0;           // sans utilité.

// Incrementeur des competeurs
always_ff @(posedge pixel_clk or posedge pixel_rst)
 if(pixel_rst) begin
    px <= '0;
    py <= '0;
 end
 else
 begin
    px <= px + 1'b1;
    if(px >= XLEN-1) begin
        px <= '0;
        py <= py + 1'b1;
        if(py >= YLEN-1) py <= '0;
    end
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

// Controleur du compteur de position du pixel actif
always_comb begin
   x <= px < HDISP ? px :'0;
   y <= py < VDISP ? py :'0;
end

// Generateur d'image
always_comb begin
    if(x[3:0] == 3'd0 || y[3:0] == 3'd0)
        video_ifm.RGB <= {8'hff,8'hff,8'hff};
    else
        video_ifm.RGB <= {8'h0,8'h0,8'h0};
end

endmodule
