`timescale 1ns / 1ps

module APB_MASTER(
//global signals
input Presetn,
input Pclk,

//controller input
input [32:0] addr_temp,
input [31:0] data_temp,
input [31:0] Prdata,
input transfer,
input Pready,

//output signals
output reg    Psel,
output reg [31:0] Paddr,
output reg [31:0] Pdata,
output reg [31:0] rdata_temp,
output reg Pwrite,
output reg Penable,
output reg Pint
);

reg [2:0] present_state, next_state;

parameter idle  = 2'b01;
parameter setup  = 2'b10;
parameter enable = 2'b11;

always@(posedge Pclk, negedge Presetn)
begin
  if(!Presetn)
     present_state <= idle;
  else
     present_state <= next_state;
end

always@(*)
begin
case(present_state)
idle:
   begin
     if(!transfer)
        next_state = idle;
     else
        next_state = setup;
   end
setup:
    begin      
     if(Psel)
     next_state = enable;
     else
     next_state = idle;
    end
    
enable:
    begin
     if(Psel)
       if(transfer)
         begin
           if(Pready)
             begin
             next_state = setup;
             end
           else 
             next_state = enable;
         end
     else
       next_state = idle;
   end    
endcase
end

always @(posedge Pclk)
begin
case(present_state)
idle:
begin
 Pint = 1'b0;
 Psel    = 1'b1;
 Penable = 1'b0;
end 
setup: begin
 Pint = 1'b0;
 Penable = 1'b0;
 end
enable:
     begin
     if(Psel)
       Penable = 1'b1;
       if(transfer)
         begin
           if(Pready)
             begin
             Pint = 1'b1;
             Paddr = addr_temp[31:0];
             Pwrite = addr_temp[32];
              if(addr_temp[32])
               begin
                 Pdata  = data_temp;
                 rdata_temp  = 'b0;
               end
               else
               begin
                 Pdata  = Pdata;
                 rdata_temp  = Prdata;
               end  
             end 
             end
end
endcase
end
endmodule
