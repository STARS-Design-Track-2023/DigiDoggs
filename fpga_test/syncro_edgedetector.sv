`default_nettype none

module top 
(
  // I/O ports
  input  logic hwclk, reset,
  input  logic [20:0] pb,
  output logic [7:0] left, right,
         ss7, ss6, ss5, ss4, ss3, ss2, ss1, ss0,
  output logic red, green, blue,

  // UART ports
  output logic [7:0] txdata,
  input  logic [7:0] rxdata,
  output logic txclk, rxclk,
  input  logic txready, rxready
);

  syncro_edgedetector u1 (.clk(hwclk), .nrst(~pb[19]), .button_i(pb[0]), .test_strobe(blue));


endmodule


////////////    /////////////////
// SYNCRO // &  //Edge Detector//
////////////    /////////////////
module syncro_edgedetector(
    input logic clk,
    input logic nrst,
    input logic button_i,
    output logic test_strobe //This is just for testing. Will be the circut input in future commits
  );
  
  ////////////
  // SYNCRO //
  ////////////
  logic desync, sync;
  always_ff @ (posedge clk, negedge nrst) begin 
    if(~nrst)
    begin
        desync <= 0;
        sync <= 0;
    end
    else
    begin
        desync <= button_i;
        sync <= desync;
    end
  end

  ///////////////////
  // EDGE DETECTOR //
  ///////////////////
  logic strobe;
  always_comb begin 
    if(desync & ~sync)
      strobe = 1;
    else
      strobe = 0;
  end 

  assign test_strobe = strobe;   //This is just an FPGA output to test ed/syncro
endmodule