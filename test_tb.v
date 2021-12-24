`timescale 1ns / 1ps

//`include "siggen.v"

module test_tb;

reg clk;
reg reset;
reg zeroLevel, mediaLevel, highLevel;

main mmm(.clk(clk), .rst(reset), .zeroLevel(zeroLevel), .mediaLevel(mediaLevel), .highLevel(highLevel));

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
  
  #10;
  reset=1;
  #21495435
  mediaLevel = 1;
  highLevel = 0;
  #10000000
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
  
end

always
#20 clk=~clk;


initial
  #200000000 $finish;

endmodule

