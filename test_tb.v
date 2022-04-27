`timescale 1ns / 1ps

//`include "siggen.v"

module test_tb;

reg clk;
reg reset;
reg zeroLevel, mediaLevel, highLevel;
reg rsck, mosi,mcs;
wire miso;
reg [31:0] tmp;
integer      i ;
integer j;
integer cf;

main mmm(.clk(clk), .rst(reset), .zeroLevel(zeroLevel), .mediaLevel(mediaLevel), .highLevel(highLevel), .sck(rsck), .cs(mcs), .miso(miso), .mosi(mosi));

/*iverilog */
initial
begin            
    $dumpfile("wave.vcd");        //生成的vcd文件名称
    $dumpvars(2, test_tb);     //tb模块名称
end
/*iverilog */

initial
begin
  clk=0;
  reset=0;
  zeroLevel = 1;
  mediaLevel = 1;
  highLevel = 1;
  mcs = 1;
  tmp = 16'd1;
  i=0;
  j=0;
  cf = 42<<10;
  #10
  cf = cf + 1;
  #10
  cf = cf<<16;
  
  #1000;
  reset=1;
  #21495435
  mediaLevel = 1;
  highLevel = 0;
  #5000000
  mediaLevel = 0;
  highLevel = 0;
  #5000000
  mediaLevel = 0;
  highLevel = 0;
  #10000000
  zeroLevel = 0;
  #1000
  zeroLevel = 1;
  #1000
  zeroLevel = 0;
  #1000
  zeroLevel = 1;
  #10000000
  mcs = 0;
  mosi = 0;
  #100
  for (i=0; i<=6; i=i+1) begin
    tmp = 0;
    rsck = 0;
    for(j=0;j<32;j=j+1) begin
      mosi = cf[31];
       #100
       rsck = 1;
       #100
       cf = cf << 1;
       tmp = {tmp[30:0], miso};
       rsck = 0;
    end
    #1000;
  end
  mcs = 1;

  #100000000
  mcs = 0;
  #100
  for (i=0; i<=6; i=i+1) begin
    tmp = 0;
    rsck = 0;
    for(j=0;j<32;j=j+1) begin
       #100
       rsck = 1;
       #100
       tmp = {tmp[30:0], miso};
       rsck = 0;
    end
    #1000;
  end
  mcs = 1;

end

always
#20 clk=~clk;


//initial
//  #200000000 $finish;

endmodule

