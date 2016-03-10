/*
Copyright (C) 2009 SysWip

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

// YM / TPT added 1 bit selection to packet bit8 packet

package PACKET;

typedef bit [7:0]  bit8;
typedef bit8       packet[$];
typedef bit        sel_packet[$];
// Flag types
typedef enum {random_selection, full_selection, random_burst_selection} selection_mode ;
typedef enum {with_burst_tags, without_burst_tags} burst_tags ;


///////////////////////////////////////////////////////////////////////////////
// Class Packet:
///////////////////////////////////////////////////////////////////////////////
class Packet;
  /////////////////////////////////////////////////////////////////////////////
  //************************ Class Variables ********************************//
  /////////////////////////////////////////////////////////////////////////////
  rand int unsigned      rndNum;
  int unsigned           rndNumMin;
  int unsigned           rndNumMax;
  int unsigned           rndNumMult;
  // Constraints for "preadyDelay" random variable
  constraint c_rundNum {
                             rndNum inside {[rndNumMin:rndNumMax]};
                             rndNum%rndNumMult == 0;
                       }
  /////////////////////////////////////////////////////////////////////////////
  //************************* Class Methods *********************************//
  /////////////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////
  //- genRndPkt(): Generates random packet with the given length.
  // added random selection bit / or all selected bits  
  /////////////////////////////////////////////////////////////////////////////
  task genRndPkt(input int length, input selection_mode selMode, input int data_bytes, output packet pkt, output sel_packet selpkt);
    bit [7:0] selpattern ;
    pkt = {};
    selpkt = {};
    // in random_burst_selection mode, selection bits have a pattern of length data_bytes in order 
    // to have a constant selection partern on with data_byte  words busses.
    for (int i = 0; i < data_bytes; i++) begin
      selpattern[i] = $urandom_range(0,1) ;
    end

    for (int i = 0; i < length; i++) begin
      pkt.push_back($urandom_range(0, 255)); // random byte 
      if(selMode == random_selection)
        selpkt.push_back($urandom_range(0, 1)); // random selection bit
      if(selMode == random_burst_selection) begin
        selpkt.push_back(selpattern[i%data_bytes]); // random selection bit
      end
      else // all bytes are selected
        selpkt.push_back(1'b1) ; 
    end
  endtask
  /////////////////////////////////////////////////////////////////////////////
  //- genCntPkt(): Generates packet with the given length where the first byte
  // is 0 the second is 1 the third is 2 etc.
  // no mask selection in this mode (selection is always 1)
  /////////////////////////////////////////////////////////////////////////////
  task genCntPkt(input int length, output packet pkt, output sel_packet selpkt);
    bit8 pktElement = 8'b0; // data=0
    pkt = {};
    selpkt = {} ;
    for (int i = 0; i < length; i++) begin
      pkt.push_back(pktElement);
      selpkt.push_back(1'b1);
      pktElement++;
    end
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- genRndNum(): Generates random number with a given range and then rounds
  // up to be multiple to "mult" value.*/
  /////////////////////////////////////////////////////////////////////////////
  function int genRndNum(int unsigned min, max, mult=1);
    this.rndNumMin = min;
    this.rndNumMax = max;
    this.rndNumMult= mult;
    assert (this.randomize())
    else $fatal(0, "Gen Randon Number: Randomize failed");
    genRndNum = this.rndNum;
  endfunction
  /////////////////////////////////////////////////////////////////////////////
  /*- genRndPkt(): Generates random packet. The packet length will be generated
  // randomly in the given range and will be multiple to "mult" value.*/
  // added selection packet
  /////////////////////////////////////////////////////////////////////////////
  task genFullRndPkt(input int min, max, mult, input selection_mode selMode, input int data_bytes, output packet pkt, output sel_packet selpkt );
    int length = this.genRndNum(min, max, mult);
    this.genRndPkt(length, selMode, data_bytes, pkt, selpkt);
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- PrintPkt(): Prints given "str" string and then packet containt.*/
  // added selection packet
  // YM added padding for a clear display of word / bytes
  /////////////////////////////////////////////////////////////////////////////
  function void PrintPkt(string str, packet pkt, sel_packet selpkt, int addr, int data_bytes, int length=0);
    int mask ;
    int naddr ;
    int pos ;
    string results[$] ;
    string sr ;

    if(length==0)begin
      length = pkt.size();
    end
    //$write("%s: Packet size is %d bytes\n", str, pkt.size());
    $write("%s\n", str);
    // Padding in order to obtain an aligned word
    mask = addr & ((1 << $clog2(data_bytes)) - 1) ;
    naddr = (addr >> $clog2(data_bytes)) << $clog2(data_bytes) ;
    if(mask > 0) begin
      for (int i=0;i<(mask & addr);i++) begin
        results.push_front("(0,xx)");
      end
    end

    for (int i = 1; i <= length; i++) begin
      if (results.size() == data_bytes)  
      begin
        $write("address == %h ", naddr) ;
        for(int i = 0; i < data_bytes;i++) 
          $write(results.pop_front()) ;
        $write("\n");
        naddr = naddr + data_bytes ;
      end
      if(selpkt[i-1]) 
         $swrite(sr,"(%b,%h)",selpkt[i-1],pkt[i-1]);
      else
         $swrite(sr,"(%b,xx)",selpkt[i-1]);
      results.push_front(sr) ;
    end
    pos = results.size() ;
    if(pos == data_bytes) 
        $write("address == %h ", naddr) ;
    while (results.size() != 0) 
            $write(results.pop_front()) ;
    if(pos != 0) 
    while (pos != data_bytes) 
    begin
         $write("(0,xx)");
         pos++ ;
    end
    $write("\n");
  endfunction
  //
endclass // Packet
///////////////////////////////////////////////////////////////////////////////
// Class Checker:
///////////////////////////////////////////////////////////////////////////////
class Checker;
  /////////////////////////////////////////////////////////////////////////////
  //************************ Class Variables ********************************//
  /////////////////////////////////////////////////////////////////////////////
  static int AllChecks     = 0;
  static int AllChecksFail = 0;
  local  int Checks        = 0;
  local  int ChecksFail    = 0;
  local Packet pkt;
  /////////////////////////////////////////////////////////////////////////////
  //************************* Class Methods *********************************//
  /////////////////////////////////////////////////////////////////////////////
  function new();
    pkt = new();
  endfunction
  /////////////////////////////////////////////////////////////////////////////
  /*- CheckPkt(): Compares 2 given packets and returns '0' if they are equal.
  // Otherwise returns '-1'.*/
  // added selection packet to take into account real selected bytes in the packet
  /////////////////////////////////////////////////////////////////////////////
  function int CheckPkt(packet resPkt, expPkt, sel_packet selPkt, int addr, int data_bytes, int length = 0);
    int dataError = 0;
    if(length == 0)begin
      length = expPkt.size();
    end
    this.Checks++;
    this.AllChecks++;
    if((expPkt.size()==0) || (resPkt.size()==0))begin
      $write("#-----Check %0d",this.Checks);
      $write("   Failed. Empty packet detected \n");
      $write("           Expected packet length is %d \n", expPkt.size());
      $write("           Result   packet length is %d \n", resPkt.size());
      CheckPkt = -1;
      this.ChecksFail++;
      this.AllChecksFail++;
    end else begin
      for (int i = 0; i < length; i++) begin
        if ((resPkt[i] != expPkt[i]) && selPkt[i]) begin
          dataError++;
        end
      end
      if (dataError == 0) begin
        //$write("   Passed!!! \n");
        CheckPkt = 0;
      end else begin
        $write("#-----Check %0d",this.Checks);
        $write("   Failed. Current Check has %0d errors\n", dataError);
        pkt.PrintPkt("Expected Packet", expPkt, selPkt,addr,data_bytes,length);
        pkt.PrintPkt("Result Packet", resPkt, selPkt,addr,data_bytes,length);
        CheckPkt = -1;
        this.ChecksFail++;
        this.AllChecksFail++;
      end
    end
  endfunction
  /////////////////////////////////////////////////////////////////////////////
  /*- printStatus(): Print checks and failed checks information.*/
  /////////////////////////////////////////////////////////////////////////////
  function void printStatus();
    $write("---Number of Checks        %0d \n", this.Checks);
    $write("---Number of failed Checks %0d \n", this.ChecksFail);
  endfunction
  /////////////////////////////////////////////////////////////////////////////
  /*- printFullStatus(): Print checks and failed checks information.*/
  /////////////////////////////////////////////////////////////////////////////
  function void printFullStatus();
    $write("---Number of Checks        %0d \n", this.AllChecks);
    $write("---Number of failed Checks %0d \n", this.AllChecksFail);
  endfunction
endclass // Checker
//
endpackage
