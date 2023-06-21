`include "fpga_test/basic_counter.sv"
////////////////////
//Image Controller//
////////////////////
module image_controller (
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


