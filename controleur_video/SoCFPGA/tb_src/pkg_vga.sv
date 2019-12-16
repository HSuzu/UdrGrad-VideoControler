package pkg_vga;


parameter integer vga_modes[14][10]=
'{
  //hz      clk     h      hfp     hp      hbp      v      vfp     vp     vbp
0: '{60,	25175,	640,	16,	    96,	    48 ,	480,	11,	    2,	    31},
1: '{72,	31500,	640,	24,	    40,	    128 ,	480,	9,	    3,	    28},
2: '{75,	31500,	640,	16,	    96,	    48 ,	480,	11,	    2,	    32},
3: '{85,	36000,	640,	32,	    48,	    112 ,	480,	1,	    3,	    25},
4: '{56,	38100,	800,	32,	    128,    128 ,	600,	1,	    4,	    14},
5: '{60,	40000,	800,	40,	    128,    88 ,	600,	1,	    4,	    23},
6: '{72,	50000,	800,	56,	    120,    64 ,	600,	37,	    6,	    23},
7: '{75,	49500,	800,	16,	    80,	    160 ,	600,	1,	    2,	    21},
8: '{85,	56250,	800,	32,	    64,	    152 ,	600,	1,	    3,	    27},
9: '{60,	65000,	1024,	24,	    136,    160 ,	768,	3,	    6,	    29},
10:'{70,    75000,	1024,	24,	    136,    144 ,	768,	3,	    6,	    29},
11:'{75,    78750,	1024,	16,	    96,	    176 ,	768,	1,	    3,	    28},
12:'{85,    94500,	1024,	48,	    96,	    208 ,	768,	1,	    3,	    36},
13:'{66,    32000,	800, 	40,	    48,	    40  ,	480,	13,     3,	    29}
};

endpackage: pkg_vga
