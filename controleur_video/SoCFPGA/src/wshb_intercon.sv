module wshb_intercon (
    wshb_if.slave  wshb_ifs_mire,
    wshb_if.slave  wshb_ifs_vga,
    wshb_if.master  wshb_ifm
);

// jeton = 1 ==> VGA
// jeton = 0 ==> mire
logic jeton;

assign wshb_ifm.cyc    = (jeton) ? wshb_ifs_vga.cyc    : wshb_ifs_mire.cyc    ;
assign wshb_ifm.stb    = (jeton) ? wshb_ifs_vga.stb    : wshb_ifs_mire.stb    ;
assign wshb_ifm.adr    = (jeton) ? wshb_ifs_vga.adr    : wshb_ifs_mire.adr    ;
assign wshb_ifm.we     = (jeton) ? wshb_ifs_vga.we     : wshb_ifs_mire.we     ;
assign wshb_ifm.dat_ms = (jeton) ? wshb_ifs_vga.dat_ms : wshb_ifs_mire.dat_ms ;
assign wshb_ifm.sel    = (jeton) ? wshb_ifs_vga.sel    : wshb_ifs_mire.sel    ;
assign wshb_ifm.cti    = (jeton) ? wshb_ifs_vga.cti    : wshb_ifs_mire.cti    ;
assign wshb_ifm.bte    = (jeton) ? wshb_ifs_vga.bte    : wshb_ifs_mire.bte    ;


assign wshb_ifs_vga.ack    = (jeton) ? wshb_ifm.ack    : 1'b0 ;
assign wshb_ifs_vga.dat_sm = (jeton) ? wshb_ifm.dat_sm :'0 ;
assign wshb_ifs_vga.err    = (jeton) ? wshb_ifm.err    : 1'b0 ;
assign wshb_ifs_vga.rty    = (jeton) ? wshb_ifm.rty    : 1'b0 ;

assign wshb_ifs_mire.ack    = (!jeton) ? wshb_ifm.ack    : 1'b0 ;
assign wshb_ifs_mire.dat_sm = (!jeton) ? wshb_ifm.dat_sm :'0 ;
assign wshb_ifs_mire.err    = (!jeton) ? wshb_ifm.err    : 1'b0 ;
assign wshb_ifs_mire.rty    = (!jeton) ? wshb_ifm.rty    : 1'b0 ;


always_ff @(posedge wshb_ifm.clk or posedge wshb_ifm.rst)
if(wshb_ifm.rst)
    jeton <= 1'b0;
else
    jeton <= (jeton) ? wshb_ifs_vga.cyc : !wshb_ifs_mire.cyc;

endmodule