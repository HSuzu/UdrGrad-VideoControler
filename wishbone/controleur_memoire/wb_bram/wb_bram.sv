//-----------------------------------------------------------------
// Wishbone BlockRAM
//-----------------------------------------------------------------
//
// Le paramètre mem_adr_width doit permettre de déterminer le nombre
// de mots de la mémoire : (2048 pour mem_adr_width=11)

module wb_bram #(parameter mem_adr_width = 11) (
      // Wishbone interface
      wshb_if.slave wb_s
      );
      // a vous de jouer a partir d'ici

      logic [mem_adr_width-1:0] mem_addr;
//      logic [31:0] mask;
      logic [31:0] mem [2**(mem_adr_width)-1:0];
//      logic [7:0] mem1 [2**mem_adr_width-1:0];
//      logic [7:0] mem2 [2**mem_adr_width-1:0];
//      logic [7:0] mem3 [2**mem_adr_width-1:0];

      logic ack_w, ack_r;

      assign mem_addr = wb_s.adr[mem_adr_width+1:2];
      assign wb_s.ack = (ack_w || ack_r);
      assign act_b = wb_s.cyc & wb_s.stb;
      assign ack_w = (act_b & wb_s.we);
      // assign mask[7:0] = {8{wb_s.sel[0]}};
      // assign mask[15:8] = {8{wb_s.sel[1]}};
      // assign mask[23:16] = {8{wb_s.sel[2]}};
      // assign mask[31:24] = {8{wb_s.sel[3]}};

      always_ff @(posedge wb_s.clk) begin
            ack_r <= 0;
            if(wb_s.rst) begin
                  wb_s.rty <= 0;
                  wb_s.err <= 0;

                  ack_r <= 0;
            end
            else if (act_b && !wb_s.we)
                  ack_r <= 1'b1;
      end

      always_ff @(posedge wb_s.clk) begin
            if(ack_w) begin
                  if(wb_s.sel[0])
                        mem[mem_addr][7:0] <= wb_s.dat_ms[7:0];
                  if(wb_s.sel[1])
                        mem[mem_addr][15:8] <= wb_s.dat_ms[15:8];
                  if(wb_s.sel[2])
                        mem[mem_addr][23:16] <= wb_s.dat_ms[23:16];
                  if(wb_s.sel[3])
                        mem[mem_addr][31:24] <= wb_s.dat_ms[31:24];
                  //  mem[mem_addr] <= (mem[mem_addr] & ~mask) | (wb_s.dat_ms & mask); 
            end
      end

      always_ff @(negedge wb_s.clk) begin
            if(ack_r) begin
//                  wb_s.dat_sm <= {mem[mem_addr+3], mem[mem_addr+2], mem[mem_addr+1], mem[mem_addr]};
                  wb_s.dat_sm <= mem[mem_addr];
            end
      end


      endmodule
