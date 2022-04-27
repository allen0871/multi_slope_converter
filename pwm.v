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
reg modest;

always @(posedge clk or negedge rst)
begin
	if(!rst) begin
		count <= 10'b0;
	end
	else begin
		if(enable) begin
			if(count == PERIOD) begin
				count <= 10'b0;
			end
			else begin
				count <= count + 10'd1;
			end
		end
		else begin
			count <= 10'b0;
		end
	 end
end

always @(posedge clk or negedge rst)
begin
	if(!rst) begin
		startct <= 10'b0;
		finishct <= 10'b0;
		modest <= 1'b0;
	end
	else begin
		if(count == 10'b0) begin
			modest <= mode;
			if(mode) begin
				startct <=  10'd2;
				finishct <= PERIOD-10'd2;
			end
			else begin
				startct <=  (PERIOD>>1) - 10'd2;
				finishct <= (PERIOD>>1) + 10'd2;
			end	
		end
		else begin
			startct <= startct;
			finishct <= finishct;
			modest <= modest;
		end
	 end
end

always @(posedge clk or negedge rst)
begin
	if(!rst) begin
		pwm <= 1'b0; 
	end
	else begin
		if(enable) begin
			if(count == startct) begin
				pwm <= 1'b1;
			end
			else if(count == finishct) begin
				pwm <= 1'b0;
			end	
		end
		else begin
			pwm <= pwm;
		end
	 end
end

always @(posedge clk or negedge rst)
begin
	 if(!rst) begin
		modeA <= 32'b0;
		modeB <= 32'b0;
	 end
	 else  begin
		if(start) begin
			modeA <= 32'b0;
			modeB <= 32'b0;
		 end
		 else if(count == 10'b1) begin
			if(modest) begin
				modeB <= modeB+32'b1;
			end
			else begin
				modeA <= modeA+32'b1;
			end
		 end
		 else begin
			 modeB <= modeB;
			 modeA <= modeA;
		 end
	 end
end

endmodule