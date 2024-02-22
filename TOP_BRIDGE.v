`timescale 1ns / 1ps

module TOP_BRIDGE(
   input Hclk, Pclk, Hresetn, Presetn,
                     input [1:0]       Htrans,
                     input [31:0]       Haddr,
                     input [31:0]       Hwdata,
                     input [1:0]       Hburst,
                     input             Hwrite,
                     input             Hsel,
                     input             Pready,
                     input [31:0]      Prdata,
                     
                     output Psel,
                     output Hreadyout,
                     output [31:0] Paddr,
                     output [31:0] Pdata,
                     output [31:0] rdata_temp,
                     output Pwrite,
                     output Penable
                    
 
    );
                    wire [31:0]  Haddr_temp;
                    wire [31:0]  Hwdata_temp;
                    wire         valid;
                    wire         Hwrite_temp;
                    wire [31:0]  data_temp;
                    wire [32:0]  addr_temp;
                    wire         transfer;
                    wire         full;
                    wire         Hready;
                    wire            Pint;
                    assign Hready = !full;
                    AHB_SLAVE AS (
                      .Hclk(Hclk),
                      .Hresetn(Hresetn),
                      .Htrans(Htrans),
                      .Haddr(Haddr),
                      .Hwdata(Hwdata),
                      .Hburst(Hburst),
                      .Hwrite(Hwrite), 
                      .Hsel(Hsel), 
                      .Hready(Hready),
   
                      .Haddr_temp(Haddr_temp),
                      .Hwdata_temp(Hwdata_temp),
                      .valid(valid),
                      .Hwrite_temp(Hwrite_temp)
                    );  
                    
                    FIFO_CONTROL FC (
                      .Hclk(Hclk), 
                      .Pclk(Pclk),
                      .Hresetn(Hresetn),
                      .Haddr_temp(Haddr_temp),
                      .Hwdata_temp(Hwdata_temp),
                      .valid(valid),
                      .Hwrite_temp(Hwrite_temp),
                      .Pready(Pready),
                     
                     .data_temp(data_temp),
                     .addr_temp(addr_temp),
                     .transfer(transfer),
                     .full(full),
                     .Pint(Pint)
                    );
                    
                    APB_MASTER AM (
                    .Presetn(Presetn),
                    .Pclk(Pclk),
                    .addr_temp(addr_temp),
                    .data_temp(data_temp),
                    .Prdata(Prdata),
                    .transfer(transfer),
                    .Pready(Pready),
                   
                    .Psel(Psel),
                    .Paddr(Paddr),
                    .Pdata(Pdata),
                    .rdata_temp(rdata_temp),
                    .Pwrite(Pwrite),
                    .Penable(Penable),
                    .Pint(Pint)
                    );
                    
                    assign Hreadyout = !full;
endmodule
