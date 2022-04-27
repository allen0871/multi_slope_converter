module spi (
    stpwmNA,stpwmNB,stpwmPA,stpwmPB,strundown,stN64,stP8,stN1,sck,cs,miso,mosi,error,msclk,nplc,rst
);

    input wire [31:0] stpwmNA;
    input wire [31:0] stpwmNB;
    input wire [31:0] stpwmPA;
    input wire [31:0] stpwmPB;
    input wire [11:0] strundown;
    input wire [7:0]  stN64;
    input wire [7:0]  stP8;
    input wire [7:0]  stN1;
    input wire [2:0]  error;
    input wire sck;
    input wire cs;
    input wire msclk;
    input wire rst;
    output reg miso;
    output reg [9:0] nplc;
    input wire mosi;
    reg sck1,sck2, cs1, cs2;
    wire sckPosedge;
    wire csLow;
    
    reg [2:0] status;
    reg [4:0] counter;
    reg [31:0] tmp;

    parameter            IDLE   = 3'd0 ;
    parameter            NA   = 3'd1 ;
    parameter            NB  = 3'd2 ;
    parameter            PA  = 3'd3 ;
    parameter            PB  = 3'd4 ;
    parameter            RD  = 3'd5 ;
    parameter            OTHER  = 3'd6 ;

    assign sckPosedge = ((sck1 == 1'b1)  && (sck2 == 1'b0));
    assign csEdge = ((cs1 == 1'b0) && (cs2 == 1'b1));

    always @(posedge msclk) begin
        sck1 <= sck;
        sck2 <= sck1;
        cs1 <= cs;
        cs2 <= cs1;
        if(!rst) begin
            nplc <= 10'd2;
            counter <= 5'b0;
            status <= IDLE;
            tmp <= stpwmNA;
            miso <= 1'b0;
        end
        else begin 
            if(cs) begin
                counter <= 5'b0;
                status <= IDLE;
                tmp <= stpwmNA;
                miso <= 1'b0;
            end
            else begin
                if(csEdge) begin
                    status <= NA;
                    tmp <= stpwmNA;
                    miso <= 1'b0;
                end
                else if (sckPosedge) begin
                    counter <= counter + 5'b1;
                    miso <= tmp[31];
                    case(status)
                        NA:
                        begin
                            if(counter == 5'd31) begin
                                status <= NB;
                                tmp <= stpwmNB;
                            end
                            else begin
                                tmp <= {tmp[30:0],mosi};
                                if((counter == 5'd16) && (tmp[15:10] == 6'b101010)) begin
                                    nplc <= tmp[9:0];
                                end
                            end
                        end
                        NB:
                        begin
                            if(counter == 5'd31) begin
                                status <= PA;
                                tmp <= stpwmPA;
                            end
                            else begin
                                tmp <= {tmp[30:0],1'b0};
                            end
                        end
                        PA:
                        begin
                            if(counter == 5'd31) begin
                                status <= PB;
                                tmp <= stpwmPB;
                            end
                            else begin
                                tmp <= {tmp[30:0],1'b0};
                            end
                        end
                        PB:
                        begin
                            if(counter == 5'd31) begin
                                status <= RD;
                                tmp <= {1'b0,error,strundown,stN64,stP8};
                            end
                            else begin
                                tmp <= {tmp[30:0],1'b0};
                            end
                        end
                        RD:
                        begin
                            if(counter == 5'd31) begin
                                status <= OTHER;
                                tmp <= {stN1,24'b0};
                            end
                            else begin
                                tmp <= {tmp[30:0],1'b0};
                            end
                        end
                        OTHER:
                        begin
                            if(counter == 5'd31) begin
                                status <= NA;
                                tmp <= stpwmNA;
                            end
                            else begin
                                tmp <= {tmp[30:0],1'b0};
                            end
                        end
                        default:
                        begin
                            counter <= 5'b0;
                            status <= NA;
                            tmp <= stpwmNA;
                            miso <= 1'b0;
                        end
                    endcase
                end
            end
        end
    end

endmodule