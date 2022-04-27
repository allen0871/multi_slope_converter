module main (clk, rst, zeroLevel, mediaLevel, highLevel ,sp512, sn512, sn64, sp8, sn1, sinput, szero,sck,cs,miso,mosi);
    input clk, rst, zeroLevel, mediaLevel, highLevel;
    output wire sp512, sn512, sinput, szero;
    output reg sn64,sp8, sn1;
    input wire sck;
    input wire cs;
    output wire miso;
    input wire mosi;

    parameter            IDLE   = 3'd0 ;
    parameter            RUNUP   = 3'd1 ;
    parameter            RUNDOWN  = 3'd2 ;
    parameter            N64  = 3'd3 ;
    parameter            P8  = 3'd4 ;
    parameter            N1  = 3'd5 ;
    parameter            ERROR  = 3'd6 ;

    wire ms;
    wire clk100k;
    reg [2:0] status;
    reg rundownreg;
    wire start;
    wire isrunup;
    wire modeN;
    wire modeP;
    wire runupw;
    reg preSinput;
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
    reg [2:0]  error;
    wire [9:0]  nplc;
    wire sgrundown;
    wire sgstart;

    assign modeN = mediaLevel ? 1'b0: 1'b1;
    assign modeP = highLevel ? 1'b1: 1'b0;
    assign isrunup = (status == RUNUP);
    assign sp512 = isrunup? runupw: rundownreg;
    assign sgrundown = (preSinput == 1'b1 && sinput == 1'b0);

    clkgen #(.DIVWIDTH(9)) c100k(clk,rst,9'd124, clk100k);
    clkgen #(.DIVWIDTH(9)) cms(clk100k,rst,9'd49,ms);
    siggen gen(.clk1ms(ms),.rst(rst),.npl(nplc),.zero(szero),.runup(sinput),.start(start));
    pwmgen #(.PERIOD(249)) pwmN(.clk(clk), .rst(rst),.start(start), .reload(clk100k), .enable(sinput), .mode(modeN), .pwm(sn512), .modeA(wpwmNA), .modeB(wpwmNB));
    pwmgen #(.PERIOD(249)) pwmP(.clk(clk), .rst(rst),.start(start), .reload(clk100k), .enable(sinput), .mode(modeP), .pwm(runupw), .modeA(wpwmPA), .modeB(wpwmPB)); 
    spi aaa(.stpwmNA(32'd1), .stpwmNB(stpwmNB), .stpwmPA(stpwmPA), .stpwmPB(stpwmPB), .strundown(strundown), 
            .stN64(stN64), .stP8(stP8), .stN1(stN1), .sck(sck), .cs(cs),.mosi(mosi), .miso(miso), .error(error), .nplc(nplc), .msclk(clk), .rst(rst));

    always @(posedge start or negedge rst)
    begin
        if(!rst) begin
            strundown <= 12'b0;
            stN64 <= 8'b0;
            stP8 <= 8'b0;
            stN1 <= 8'b0;
            stpwmNA <= 32'b0;
            stpwmNB <= 32'b0;
            stpwmPA <= 32'b0;
            stpwmPB <= 32'b0;
        end
        else begin
            stpwmNA <= wpwmNA;
            stpwmNB <= wpwmNB;
            stpwmPA <= wpwmPA;
            stpwmPB <= wpwmPB;
            strundown <= trundown;
            stN64 <= tN64;
            stP8 <= tP8;
            stN1 <= tN1;
        end
	 end

    always @(posedge clk or negedge rst)
    begin
        if(!rst) begin
            status <= IDLE;
            sn64 <= 1'b0;
            rundownreg <= 1'b0;
            sp8 <= 1'b0;
            sn1 <= 1'b0;
            preSinput <= 1'b0;
            rundownreg  <= 1'b1;
            trundown <= 12'b0;
            tN64 <= 8'b0;
            tP8 <= 8'b0;
            tN1 <= 8'b0;
            error <= 3'b0;
        end
        else begin
            preSinput <= sinput;
            if(szero) begin
                sn1 <= 1'b0;
                sp8 <= 1'b0;
                sn64 <= 1'b0;
                rundownreg <= 1'b0;
                status <= IDLE;
            end
            else begin  
                case(status)
                    IDLE:
                    begin
                        if(start) begin
                            status <= RUNUP; 
                        end
                    end
                    RUNUP:
                    begin
                        if(sgrundown) begin
                            rundownreg  <= 1'b1;
                            trundown <= 12'b1;
                            tN64 <= 8'b0;
                            tP8 <= 8'b0;
                            tN1 <= 8'b0;
                            if(zeroLevel) begin
                                error <= 3'd0;
                                status <= RUNDOWN;
                            end
                            else begin
                                error <= 3'd1;
                                status <= IDLE;
                            end
                        end
                    end
                    RUNDOWN:
                        begin
                            if(zeroLevel) begin
                                if(trundown == 12'd4095) begin
                                    error <= 3'd2;
                                    status <= IDLE;
                                end
                                else begin
                                    trundown <= trundown + 12'b1;
                                end
                            end
                            else begin
                                rundownreg  <= 1'b0;
                                status <= N64;
                                sn64 <= 1'b1;
                                tN64 <= 8'b1;
                            end
                        end
                    N64:
                        begin
                            if(!zeroLevel) begin
                                if(trundown == 8'd255) begin
                                    error <= 3'd3;
                                    status <= IDLE;
                                end
                                else begin
                                    tN64 <= tN64 + 8'b1;
                                end
                            end
                            else begin
                                sn64  <= 1'b0;
                                status <= P8;
                                sp8 <= 1'b1;
                                tP8 <= 8'b1;
                            end
                        end
                    P8:
                        begin
                            if(zeroLevel) begin
                                if(trundown == 8'd255) begin
                                    error <= 3'd4;
                                    status <= IDLE;
                                end
                                else begin
                                    tP8 <= tP8 + 8'b1;
                                end
                            end
                            else begin
                                sp8  <= 1'b0;
                                status <= N1;
                                sn1 <= 1'b1;
                                tN1 <= 8'b1;
                            end 
                        end
                    N1:
                        begin
                            if(!zeroLevel) begin
                                if(trundown == 8'd255) begin
                                    error <= 3'd5;
                                    status <= IDLE;
                                end
                                else begin
                                    tN1 <= tN1 + 8'b1;
                                end
                            end
                            else begin
                                sn1  <= 1'b0;
                                status <= IDLE;
                            end 
                        end
                endcase
            end
        end
    end

endmodule