`timescale 1ns / 1ps

//`include "siggen.v"

module test_tb;

reg clk;
reg reset;
wire ms;
//test pwmgen
reg pwmrst;
reg mode;
reg reload;
reg enable;
wire pwm;
integer      i ;


wire ms20;
wire clk100k;
wire zero;
wire runup;
wire start;

clkgen #(.DIVWIDTH(9)) c100k(clk,reset,9'd124, clk100k);
clkgen #(.DIVWIDTH(9)) cms(clk100k,reset,9'd49,ms);
//clkgen #(.DIVWIDTH(5)) cms20(ms,reset,5'd9,ms20);
siggen gen(.clk1ms(ms),.rst(reset),.npl(10'd2),.zero(zero),.runup(runup),.start(start));
pwmgen #(.PERIOD(249)) pwmg(.clk(clk), .rst(start), .reload(clk100k), .enable(runup), .mode(mode));

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
  enable=1;
  clk=1;
  //ms = 0;
  pwmrst = 0;
  mode = 1;
  reload = 0;
  enable = 1;
  #40;
  reset=1;
//  pwmrst = 1;
//   #20
//   pwmrst = 0;
//   //test pwm
//   for(i=0;i<10;i=i+1)
//   begin
//     reload = 1;
//     #40;
//     reload = 0;
//     #12000;
//     if(i == 5) 
//         mode = 0;
//   end
//   pwmrst = 0;
//   #40;
//   pwmrst = 1;
//   #20;
//   pwmrst = 0;
  
end

// always
//     #50 ms=~ms;

always
#20 clk=~clk;


initial
  #100000000 $finish;

endmodule

