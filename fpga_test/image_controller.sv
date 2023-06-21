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

  logic [15:0]data_in; //TO BE REPLACED WITH SPI IN 
  logic [15:0]data_out; //TO BE REPLACED WITH SPI OUT

  iamge_controller u2 (.clk(hwclk), .nrst(~pb[19]), .enable(pb[2]), .clear(pb[17]), .data_in(data_in), .right(right[3:0]), .left(left[3:0]), .at_end(red), .data_out(data_out));


endmodule


////////////////////
//Image Controller//
////////////////////
module iamge_controller (
  input logic clk,
  input logic nrst,
  input logic enable,
  input logic clear,
  input logic [15:0]data_in,
  output logic [3:0]left,
  output logic [3:0]right,
  output logic at_end,
  output logic [15:0]data_out
);

  logic [3:0]max = 4'b1111;
  logic horizontal_strobe, vertical_strobe;
  counter horiztonal (.clk(clk), .nrst(nrst), .enable(enable), .clear(clear), .wrap(1), .max(max), .count(left), .at_max(horizontal_strobe));
  counter vertical (.clk(horizontal_strobe), .nrst(nrst), .enable(enable), .clear(clear), .wrap(1), .max(max), .count(right), .at_max(vertical_strobe)); 

  //End state logic where horiztonal has full counted and vertical has fully counted
  always_comb begin 
    if (left == 4'b1111 & right == 4'b0000)
      at_end = 1;
    else
      at_end = 0;
  end
endmodule


