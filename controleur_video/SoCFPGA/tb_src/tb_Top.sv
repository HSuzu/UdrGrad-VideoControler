`timescale 1ns/1ps

`default_nettype none

module tb_Top;

// Entrées sorties extérieures
bit   FPGA_CLK1_50;
logic [1:0]	KEY;
wire  [7:0]	LED;
logic [3:0]	SW;

// Interface vers le support matériel
hws_if      hws_ifm();

// Instance du module Top
Top Top0(.*) ;

///////////////////////////////
//  Code élèves
//////////////////////////////

// Horloge 50MHz
always #10ns FPGA_CLK1_50 = ~FPGA_CLK1_50;

initial begin
    KEY[0] = 1;
    #128ns KEY[0] = 0;
    #128ns KEY[0] = 1;
end

always begin
    #4ms;
    $stop();
end

endmodule