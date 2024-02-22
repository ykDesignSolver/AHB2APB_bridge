`timescale 1ns / 1ps

module WRAP_TOP(
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
                     output [31:0] Paddr,
                     output [31:0] Pdata,
                     output [31:0] rdata_temp,
                     output Pwrite,
                     output Hreadyout,
                     output Penable
    );
    
    TOP_BRIDGE TB (
                     .Hclk(Hclk), 
                     .Pclk(Pclk), 
                     .Hresetn(Hresetn), 
                     .Presetn(Presetn),
                     .Htrans(Htrans),
                     .Haddr(Haddr),
                     .Hwdata(Hwdata),
                     .Hburst(Hburst),
                     .Hwrite(Hwrite),
                     .Hsel(Hsel),
                     .Pready(Pready),
                     .Prdata(Prdata),
   
                     .Psel(Psel),
                     .Paddr(Paddr),
                     .Pdata(Pdata),
                     .rdata_temp(rdata_temp),
                     .Pwrite(Pwrite),
                     .Penable(Penable),
                     .Hreadyout(Hreadyout)
                    
    );
endmodule
