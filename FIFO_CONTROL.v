`timescale 1ns / 1ps

module FIFO_CONTROL(
                     input Hclk, Pclk,
                     input Hresetn,
                     input[31:0]  Haddr_temp,
                     input[31:0]  Hwdata_temp,
                     input       valid,
                     input       Hwrite_temp,
                     input       Pready,
                     input       Pint,
                     
                     output [31:0] data_temp,
                     output [32:0] addr_temp,
                     output transfer,
                     output full
    );
    
    wire resetn,empty_data, wr_en,rd_en,full_data,full_addr,empty_addr;
    wire [32:0] addr_in;
    
    FIFO_DATA F1(
  .rst(resetn),                  // input wire rst
  .wr_clk(Hclk),            // input wire wr_clk
  .rd_clk(Pclk),            // input wire rd_clk
  .din(Hwdata_temp),                  // input wire [31 : 0] din
  .wr_en(wr_en),              // input wire wr_en
  .rd_en(rd_en),              // input wire rd_en
  .dout(data_temp),                // output wire [31 : 0] dout
  .full(full_data),                // output wire full
  .empty(empty_data)              // output wire empty
);

FIFO_ADDR F2 (
  .rst(resetn),                  // input wire rst
  .wr_clk(Hclk),            // input wire wr_clk
  .rd_clk(Pclk),            // input wire rd_clk
  .din(addr_in),                  // input wire [32 : 0] din
  .wr_en(wr_en),              // input wire wr_en
  .rd_en(rd_en),              // input wire rd_en
  .dout(addr_temp),                // output wire [32 : 0] dout
  .full(full_addr),                // output wire full
  .empty(empty_addr)              // output wire empty
);

assign full     =  full_data || full_addr;
assign transfer = (!empty_data && !empty_addr);
assign wr_en    =  valid && Hwrite_temp;
assign rd_en    =  transfer && Pready && Pint;
assign addr_in  =  {Hwrite_temp, Haddr_temp};
assign resetn   = !Hresetn;

endmodule