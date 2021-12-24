module pwmgen 
#(parameter PERIOD = 10'd259) 
(
    clk, rst, start, reload, enable, mode, pwm, modeA, modeB
);

input clk,reload, enable, mode, rst, start;
output reg pwm;
output reg [31:0] modeA;
output reg [31:0] modeB;
reg [9:0] count;
reg [9:0] startct;
reg [9:0] finishct;

always @(posedge clk or enable)
begin
    if(enable) begin
        if(mode) begin
            startct <=  10'd2;
            finishct <= PERIOD-10'd2;
        end
        else begin
            startct <=  (PERIOD>>1) - 10'd2;
            finishct <= (PERIOD>>1) + 10'd2;
        end
        count <= count + 10'd1;
        if(count == startct) begin
            pwm <= 1'b1;
        end
        if(count == finishct) begin
            pwm <= 1'b0;
            if(mode) begin
                modeB <= modeB+32'b1;
            end
            else begin
                modeA <= modeA+32'b1;
            end
        end
    end
    else begin
        count <= 10'b0;
    end
end

always @(rst) 
begin
    modeA <= 32'b0;
    modeB <= 32'b0;
    count <= 10'b0;
    pwm <= 1'b0;  
end

always @(posedge start)
begin
    modeA <= 32'b0;
    modeB <= 32'b0;
    count <= 10'b0;
    pwm <= 1'b0;
end

always @(posedge reload)
begin
    count <= 10'b0;
end

endmodule