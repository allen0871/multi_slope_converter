module spi (
    stpwmNA,stpwmNB,stpwmPA,stpwmPB,strundown,stN64,stP8,stN1,sck,cs,miso,mosi
);

    input wire [31:0] stpwmNA;
    input wire [31:0] stpwmNB;
    input wire [31:0] stpwmPA;
    input wire [31:0] stpwmPB;
    input wire [11:0] strundown;
    input wire [7:0]  stN64;
    input wire [7:0]  stP8;
    input wire [7:0]  stN1;
    input wire sck;
    input wire cs;
    output reg miso;
    input wire mosi;
    
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

    always @(posedge sck) begin
        if(cs) begin
            counter <= 5'b0;
            status <= NA;
            tmp <= stpwmNA;
            miso <= 1'b0;
        end
        else begin
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
                        tmp <= {tmp[30:0],1'b0};
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
                        tmp <= {4'b0,strundown,stN64,stP8};
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
            endcase
        end
    end

endmodule