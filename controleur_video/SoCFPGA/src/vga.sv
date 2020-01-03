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

localparam xbits = $clog2(HDISP)-1; // Nombre de bits du compteur px
localparam ybits = $clog2(VDISP)-1; // Nombre de bits du compteur py

assign video_ifm.CLK = pixel_clk;

bit [xbits:0] px; // Compteur de pixels
bit [ybits:0] py; // Compteur de lignes

always_ff @(posedge pixel_clk or posedge pixel_rst) begin
    px <= px + 1'b1;
    
    if(pixel_rst) begin
        px <= 1;
        py <= 1;
    end
    else if(px == HDISP) begin
        px <= 1;
        py <= py + 1'b1;
    end

    if(py == VDISP) py <= 1;
end

always_ff @(posedge pixel_clk) begin
    video_ifm.HS <= 1;
    video_ifm.VS <= 1;

    if(px > HFP	&& px < HFP + HPULSE)
        video_ifm.HS <= 0;

    if(py > VFP	&& py < VFP + VPULSE)
        video_ifm.VS <= 0;
end

always_ff @(posedge pixel_clk) begin
    video_ifm.BLANK <= 1;

    if(px <= HFP + HPULSE + HBP)
        video_ifm.BLANK <= 0;
    if(py <= VFP + VPULSE + VBP)
        video_ifm.BLANK <= 0;
end

endmodule