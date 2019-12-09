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

      logic [7:0] mem0 [2**mem_adr_width:0];
      logic [7:0] mem1 [2**mem_adr_width:0];
      logic [7:0] mem2 [2**mem_adr_width:0];
      logic [7:0] mem3 [2**mem_adr_width:0];

      always_ff @(posedge wb_s.clk) begin
            if(posedge wb_s.rst) begin
                  wb_s.rty <= 0;
                  wb_s.err <= 0;

                  wb_s.ack <= 0;
                  wb_s.dat_sm <= 32'b0;

                  buf_sel <= 4'b0;
            end
      end

      always_ff @(posedge wb_s.clk) begin
            if(wb_s.cyc and wb_s.stb) begin
                  if(wb_s.we) begin
                        if(wb_s.sel and 4'b0001) begin
                              mem0[wb_s.adr] <= wb_s.dat_ms[7:0];
                        end
                        if(wb_s.sel and 4'b0010) begin
                              mem1[wb_s.adr] <= wb_s.dat_ms[15:8];
                        end
                        if(wb_s.sel and 4'b0100) begin
                              mem2[wb_s.adr] <= wb_s.dat_ms[23:16];
                        end
                        if(wb_s.sel and 4'b1000) begin
                              mem3[wb_s.adr] <= wb_s.dat_ms[31:24];
                        end
                  end
                  else
                        wb_s.dat_sm <= {mem3[wb_s.adr], mem2[wb_s.adr], mem1[wb_s.adr], mem0[wb_s.adr]};
            end
      end


      endmodule

