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

      // ----------------------- MEMORY ---------------------------
      logic [3:0][7:0] mem [2**(mem_adr_width)-1:0];
      wire [mem_adr_width-1:0] mem_addr;
      assign mem_addr = wb_s.adr[mem_adr_width+1:2];

      // ------------------------ ACK SIGNAL ----------------------
      logic ack_w, ack_r;
      assign wb_s.ack = (ack_w || ack_r);
      assign ack_w = (wb_s.cyc & wb_s.stb & wb_s.we);

      // Pour cette partie, on ne utilise pas les signaux rty et err
      assign wb_s.rty = 0;
      assign wb_s.err = 0;

      // ------------------------ RST et ACK ----------------------
      always_ff @(posedge wb_s.clk) begin
            if(wb_s.rst | ack_r) begin
                  ack_r <= 0;
            end
            else if (wb_s.stb & !wb_s.we)
                  ack_r <= 1;
      end

      // ------------------------ READ et WRITE -------------------
      always_ff @(posedge wb_s.clk) begin
            if(ack_w) begin
                  if(wb_s.sel[0]) mem[mem_addr][0] <= wb_s.dat_ms[7:0];
                  if(wb_s.sel[1]) mem[mem_addr][1] <= wb_s.dat_ms[15:8];
                  if(wb_s.sel[2]) mem[mem_addr][2] <= wb_s.dat_ms[23:16];
                  if(wb_s.sel[3]) mem[mem_addr][3] <= wb_s.dat_ms[31:24];
            end
            wb_s.dat_sm <= mem[mem_addr];
      end

      endmodule
