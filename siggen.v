module siggen (
    clk1ms, rst, npl, zero, runup, start
);

input clk1ms,clk20ms, rst;
input wire [9:0] npl;
output reg runup;
output reg zero;
output reg start;
reg [9:0] nplDiv;
reg [2:0] status;
reg [4:0] tmpct;

parameter            IDLE   = 3'd0 ;
parameter            RUNUP   = 3'd1 ;
parameter            RUNDOWN  = 3'd2 ;
parameter            ZEROS  = 3'd3 ;

always @(posedge clk1ms or negedge rst)
begin
    if(!rst)
    begin
       zero <= 1'b0;
       runup <= 1'b0;
       status <= IDLE;
       tmpct <= 5'd0;
       start <= 1'b0;
    end 
    else begin
        case(status)
        IDLE:
            begin
                status <= RUNUP;
                tmpct <= 5'd0;
                nplDiv <= 10'b0;
                start <= 1'b1;
            end
        RUNUP:
            begin
                start <= 1'b0;
                tmpct <= tmpct + 5'd1;
                if(tmpct == 5'd19) 
                begin
                    tmpct <= 5'd0;
                    nplDiv <= nplDiv + 10'd1;
                end
                if(nplDiv == npl) begin
                    nplDiv <= 10'b0;
                    runup <= 1'd0;
                    status <= RUNDOWN;
                end
                else
                    runup <= 1'd1;
            end
        RUNDOWN:
            begin
                status <= ZEROS;
                zero <= 1'b1;
                tmpct <= 5'd0;
            end
        ZEROS:
            begin
                tmpct <= tmpct + 5'd1;
                if(tmpct == 5'd4) 
                begin
                    tmpct <= 5'd0;
                    status <= IDLE;
                    zero <= 1'b0;
                end
            end
        endcase
    end    
end
    
endmodule