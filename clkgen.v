module  clkgen   
    #(parameter DIVWIDTH = 16) 
     (
    clk, rst, div, clkdiv
);

input clk, rst;
input wire [DIVWIDTH-1:0] div;
output reg clkdiv;
reg [DIVWIDTH-1:0] divct;

always @(posedge clk or negedge rst)
begin
    if(!rst)
    begin
       divct <= 1'b0;
       clkdiv <= 1'b0;
    end 
    else begin
       divct <= divct + 1'b1;
       if(divct == div) begin
           divct <= 1'b0;
           clkdiv <= !clkdiv;
       end 
    end    
end

endmodule