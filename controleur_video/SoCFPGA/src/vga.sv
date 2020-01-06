module vga #(
    parameter HDISP = 800, // Largeur de l'image affichée
    parameter VDISP = 480  // Hauteur de l'image affichée
) (
    input wire      pixel_clk,
    input wire      pixel_rst,
    video_if.master video_ifm
);

localparam HFP      = 40; // Horizontal Front Porch
localparam HPULSE   = 48; // Largeur de la synchro ligne
localparam HBP      = 40; // Horizontal Back Porch
localparam VFP      = 13; // Vertical Front Porch
localparam VPULSE	= 3;  // Largeur de la sync image
localparam VBP      = 29; // Vertical Back Porch

localparam xmargin = HFP + HPULSE + HBP;
localparam ymargin = VFP + VPULSE + VBP;
localparam xlen = HDISP + xmargin;
localparam ylen = VDISP + ymargin;

localparam xbits = $clog2(xlen)-1; // Nombre de bits du compteur px
localparam ybits = $clog2(ylen)-1; // Nombre de bits du compteur py

localparam uxbits = $clog2(HDISP)-1; // Nombre de bits du compteur x
localparam uybits = $clog2(VDISP)-1; // Nombre de bits du compteur y

assign video_ifm.CLK = pixel_clk;

bit [xbits:0] px; // Compteur de pixels
bit [ybits:0] py; // Compteur de lignes

bit [uybits:0] x; // Coordonnée x du pixel actif
bit [uybits:0] y; // Coordonnée y du pixel actif

assign x = px > (HFP + HPULSE + HBP) ? px - (HFP + HPULSE + HBP):'0;
assign y = py > (VFP + VPULSE + VBP) ? py - (VFP + VPULSE + VBP):'0;

// Incrementeur des competeurs
always_ff @(posedge pixel_clk or posedge pixel_rst) 
 if(pixel_rst) begin
    px <= 1;
    py <= 1;
 end
 else 
 begin
    px <= px + 1'b1;
    if(px == xlen) begin
        px <= 1;
        py <= py + 1'b1;
        if(py == ylen) py <= 1;
    end
end

// Controleur des signals HS et VS
always_ff @(posedge pixel_clk) begin
    video_ifm.HS <= !(px > HFP && px <= HFP + HPULSE) ;
    video_ifm.VS <= !(py > VFP && py <= VFP + VPULSE) ;
end

// Controleur du signal BLANK
always_ff @(posedge pixel_clk) begin
    video_ifm.BLANK <= ! (px <= xmargin || py <= ymargin) ;
end

always_ff @(posedge pixel_clk) begin
    video_ifm.RGB <= {8'b0,8'b0,8'b0};

    if(video_ifm.BLANK && (x[3:0] == 3'd0 || y[3:0] == 3'd0))
        video_ifm.RGB <= {8'hff,8'hff,8'hff};
end

endmodule