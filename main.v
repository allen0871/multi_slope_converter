module main (clk, rst, zeroLevel, mediaLevel, highLevel ,sp512, sn512, sn64, sp8, sn1, sinput, szero);
    input clk, rst, zeroLevel, mediaLevel, highLevel;
    output wire sp512, sn512, sinput, szero;
    output reg sn64,sp8, sn1;

    parameter            IDLE   = 3'd0 ;
    parameter            RUNUP   = 3'd1 ;
    parameter            RUNDOWN  = 3'd2 ;
    parameter            N64  = 3'd3 ;
    parameter            P8  = 3'd4 ;
    parameter            N1  = 3'd5 ;

    wire ms;
    wire clk100k;
    reg [2:0] status;
    reg rundownreg;
    wire start;
    wire isrunup;
    wire modeN;
    wire modeP;
    wire runupw;
    wire [31:0] wpwmNA;
    wire [31:0] wpwmNB;
    wire [31:0] wpwmPA;
    wire [31:0] wpwmPB;
    reg [31:0] stpwmNA;
    reg [31:0] stpwmNB;
    reg [31:0] stpwmPA;
    reg [31:0] stpwmPB;
    reg [11:0] strundown;
    reg [7:0]  stN64;
    reg [7:0]  stP8;
    reg [7:0]  stN1;
    reg [11:0] trundown;
    reg [7:0]  tN64;
    reg [7:0]  tP8;
    reg [7:0]  tN1;

    assign modeN = mediaLevel ? 1'b0: 1'b1;
    assign modeP = highLevel ? 1'b1: 1'b0;
    assign isrunup = (status == RUNUP);
    assign sp512 = isrunup? runupw: rundownreg;

    clkgen #(.DIVWIDTH(9)) c100k(clk,rst,9'd124, clk100k);
    clkgen #(.DIVWIDTH(9)) cms(clk100k,rst,9'd49,ms);
    siggen gen(.clk1ms(ms),.rst(rst),.npl(10'd2),.zero(szero),.runup(sinput),.start(start));
    pwmgen #(.PERIOD(249)) pwmN(.clk(clk), .rst(start), .reload(clk100k), .enable(sinput), .mode(modeN), .pwm(sn512), .modeA(wpwmNA), .modeB(wpwmNB));
    pwmgen #(.PERIOD(249)) pwmP(.clk(clk), .rst(start), .reload(clk100k), .enable(sinput), .mode(modeP), .pwm(runupw), .modeA(wpwmPA), .modeB(wpwmPB)); 

    always @(posedge clk or negedge rst)
    begin
        if(!rst) begin
            status <= IDLE;
        end
        else begin
            case(status)
                RUNDOWN:
                    begin
                        if(zeroLevel) begin
                            trundown <= trundown + 12'b1;
                        end
                        else begin
                            rundownreg  <= 1'b0;
                            status <= N64;
                            sn64 <= 1'b1;
                        end
                    end
                N64:
                    begin
                        if(!zeroLevel) begin
                            tN64 <= tN64 + 8'b1;
                        end
                        else begin
                            sn64  <= 1'b0;
                            status <= P8;
                            sp8 <= 1'b1;
                        end
                    end
                P8:
                    begin
                        if(zeroLevel) begin
                            tP8 <= tP8 + 8'b1;
                        end
                        else begin
                            sp8  <= 1'b0;
                            status <= N1;
                            sn1 <= 1'b1;
                        end 
                    end
                N1:
                    begin
                        if(!zeroLevel) begin
                            tN1 <= tN1 + 8'b1;
                        end
                        else begin
                            sn1  <= 1'b0;
                            status <= IDLE;
                        end 
                    end
            endcase
        end
    end

    always @(posedge szero)
    begin
        if(rst) begin
            sn1 <= 1'b0;
            sp8 <= 1'b0;
            sn64 <= 1'b0;
            rundownreg <= 1'b0;
        end
    end

    always @(posedge start)
    begin
        if(rst) begin
           status <= RUNUP; 
           stpwmNA <= wpwmNA;
           stpwmNB <= wpwmNB;
           stpwmPA <= wpwmPA;
           stpwmPB <= wpwmPB;
           strundown <= trundown;
           stN64 <= tN64;
           stP8 <= tP8;
           stN1 <= tN1;
           trundown <= 12'b0;
           tN64 <= 8'b0;
           tP8 <= 8'b0;
           tN1 <= 8'b0;
        end 
    end

    always @(negedge sinput)
    begin
        if(rst) begin
           status <= RUNDOWN;
           rundownreg  <= 1'b1;
        end 
    end

endmodule