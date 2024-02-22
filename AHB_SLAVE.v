`timescale 1ns / 1ps


module AHB_SLAVE(
                     input             Hclk,
                     input             Hresetn,
                     input [1:0]       Htrans,
                     input [31:0]       Haddr,
                     input [31:0]       Hwdata,
                     input [1:0]       Hburst,
                     input             Hwrite, Hsel, Hready,
                    
                     output reg [31:0]  Haddr_temp,
                     output reg [31:0]  Hwdata_temp,
                     output reg        valid,
                     output reg        Hwrite_temp
                 );

// State definitions
parameter [1:0] IDLE     = 2'b00;
parameter [1:0] BUSY     = 2'b01;
parameter [1:0] ADDRESS  = 2'b10;
parameter [1:0] TRANSFER = 2'b11;

// State registers
reg [1:0] present_state;
reg [1:0] next_state;

// Registers for data and address
reg [31:0] addr;
reg [31:0] data;
integer count = 0;



// Pipeline registers for data and address
always @(posedge Hclk) begin
    if (Hresetn == 1'b0) begin
        addr <= 'b0;
        data <= 'b0;
    end else begin
        addr <= Haddr;
        data <= Hwdata;
    end
end

// State transition logic
always @(posedge Hclk) begin
    if (Hresetn == 1'b0) begin
        present_state <= IDLE;
    end else begin
        present_state <= next_state;
    end
end

always @* begin
    case(present_state)
        // Idle state
        IDLE: begin
            if (Hsel && Htrans == 2'b01) begin
                next_state = BUSY;
            end else if (Hsel && (Htrans == 2'b10 || Htrans == 2'b11) && Hready) begin
                next_state = ADDRESS;
            end else begin
                next_state = IDLE;
            end
        end
        // Busy state
        BUSY: begin
            if (Hsel && Htrans == 2'b10 && Hready) begin
                next_state = ADDRESS;
            end else if ((Hsel && (Htrans == 2'b01)) || (!Hready)) begin
                next_state = BUSY;
            end else begin
                next_state = IDLE;
            end
        end
        // Address state
        ADDRESS: begin
            if (Hsel && (Htrans == 2'b10 || Htrans == 2'b11) && Hready) begin
                next_state = TRANSFER;
            end else if ((Hsel && (Htrans == 2'b01)) || (!Hready)) begin
                next_state = BUSY;
            end else begin
                next_state = IDLE;   
            end
        end
        // Transfer state
        TRANSFER: begin
            if (!Hsel || Htrans == 2'b00) begin
                next_state = IDLE;
            end else if ((Htrans == 2'b01) || (!Hready)) begin
                next_state = BUSY;
            end else begin
                case (Hburst)
                    // Single transfer
                    2'b00: next_state = ADDRESS;
                    // Incremental transfer
                    2'b01: next_state = TRANSFER;
                    // Increment 4 transfer
                    2'b10:
                    begin
                        //next_state = TRANSFER;
                        if(count<=3)
                        begin
                            next_state = TRANSFER;
                            count = count+1;
                        end
                        else begin
                            count = 0;
                            next_state = ADDRESS;
                        end
                    end 
                    

                    // Increment 4 transfer
                    2'b11: 
                    if (Haddr_temp < (Haddr + 8)) begin
                        next_state = TRANSFER;
                    end else begin
                       next_state = ADDRESS;
                    end
                    default: next_state = IDLE; // Default to IDLE state for safety
                endcase
            end
        end
        default: begin
            next_state = IDLE; // Default to IDLE state for safety
        end
    endcase
end

// Output data and address
always @(posedge Hclk) begin
    case(present_state)
        // Idle state
        IDLE: begin
            valid <= 1'b0;
            Haddr_temp  <= 'b0;
            Hwdata_temp <= 'b0;
            Hwrite_temp <= 1'b0; 
        end
        // Busy state
        BUSY: begin
            valid <= valid;
            Haddr_temp  <= Haddr_temp;
            Hwdata_temp <= Hwdata_temp;
            Hwrite_temp <= Hwrite_temp; 
        end
        // Address state
        ADDRESS: begin
            valid <= valid;
            Haddr_temp  <= addr;
            if(Hburst == 2'b00)
            begin
                Hwdata_temp <= data;
                Hwrite_temp <= Hwrite;
            end
            else
            begin
                Hwdata_temp <= Hwdata_temp;
                Hwrite_temp <= Hwrite_temp; 
           end
        end
        // Transfer state
        TRANSFER: begin
            case (Hburst)
                // Single transfer
                2'b00: begin
                    valid <= 1'b1;
                    Haddr_temp <= Haddr_temp;
                    Hwdata_temp <= data;
                    Hwrite_temp <= Hwrite; 
                end
                // Incremental transfer
                2'b01: begin
                    valid <= 1'b1;
                    Haddr_temp <= Haddr_temp + 1'b1; // Increment address properly
                    Hwdata_temp <= data; // Assign new data to new address
                    Hwrite_temp <= Hwrite;
                end
                // Increment 4 transfer
                2'b10: begin
                
                    valid <= 1'b1;
                    Haddr_temp <= Haddr_temp + 1'b1; // Increment address properly
                    Hwdata_temp <= data; // Assign new data to new address
                    Hwrite_temp <= Hwrite;
//                    if (Haddr_temp < (Haddr + 4)) begin
//                        valid <= 1'b1;
//                        Hwdata_temp <= data;
//                        Haddr_temp <=  Haddr_temp + 1'b1;
//                        Hwrite_temp <= Hwrite;
//                    end else begin
//                        valid <= 1'b1;
//                        Hwdata_temp <= data;
//                        Haddr_temp <=  addr;
//                        Hwrite_temp <= Hwrite;
//                    end
                end
                // Increment 8 transfer
                2'b11: begin
                    if (Haddr_temp < (Haddr + 4'd8)) begin
                        valid <= 1'b1;
                        Hwdata_temp <= data;
                        Haddr_temp <= Haddr_temp + 1'b1; // Increment address properly
                        Hwrite_temp <= Hwrite;
                    end else begin
                        valid <= 1'b1;
                        Hwdata_temp <= data;
                        Haddr_temp <= addr;                
                        Hwrite_temp <= Hwrite;
                    end
                end
                default: begin
                    valid <= 1'b0;
                    Haddr_temp  <= 'b0;
                    Hwdata_temp <= 'b0;
                    Hwrite_temp <= 1'b0; 
                end
            endcase
        end
    endcase
end
endmodule

