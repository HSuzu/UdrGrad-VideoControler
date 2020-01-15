module mire #(
    parameter HDISP = 800, // Largeur de l'image affichée
    parameter VDISP = 480  // Hauteur de l'image affichée
) (wshb_if.master  wshb_ifm);

localparam XBITS = $clog2(HDISP);
localparam YBITS = $clog2(VDISP);
localparam NBITS = $clog2(64);


assign wshb_ifm.sel    = 4'b0111;      // Les 4 octets sont à écrire
assign wshb_ifm.we     = 1'b1;         // Transaction en lecture
assign wshb_ifm.cti    = '0;           // Transfert classique
assign wshb_ifm.bte    = '0;           // sans utilité.

logic [NBITS-1:0] n;
logic [XBITS-1:0] x;
logic [YBITS-1:0] y;

assign wshb_ifm.cyc = (n != 0);         // Le bus est sélectionné
assign wshb_ifm.stb = (n != 0);         // Nous demandons une transaction

assign wshb_ifm.dat_ms = (x[3:0] == 0 || y[3:0] == 0) ? 32'h00ffffff : 32'h00000000; // Donnée 32 bits émises


always_ff @(posedge wshb_ifm.clk or posedge wshb_ifm.rst)
if(wshb_ifm.rst)
    n <= '0;
else
    if(n != 0)
        n <= n + wshb_ifm.ack;
    else
        n <= n + 1'b1;


always_ff @(posedge wshb_ifm.clk or posedge wshb_ifm.rst)
if(wshb_ifm.rst)
begin
    x <= '0;
    y <= '0;
end
else if (wshb_ifm.ack)
    if(x == HDISP-1 )
    begin
        x <= '0;
        
        if(y == VDISP-1)
            y <= '0;
        else
            y <= y + 1;
    end
    else
        x <= x + 1;

always_ff @(posedge wshb_ifm.clk or posedge wshb_ifm.rst)
if(wshb_ifm.rst)
    wshb_ifm.adr <= '0;
else if (wshb_ifm.ack)
    if(wshb_ifm.adr == 4*(HDISP*VDISP-1))
        wshb_ifm.adr <= '0;
    else
        wshb_ifm.adr <= wshb_ifm.adr + 4;

endmodule