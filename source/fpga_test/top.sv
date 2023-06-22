`default_nettype none
`include "fpga_test/image_controller.sv"
`include "fpga_test/syncro_edgedetector.sv"
`include "fpga_test/basic_counter.sv"

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

  logic [15:0]data_in;
  logic [15:0]data_out;

  image_controller u1 (.clk(hwclk), .nrst(~pb[19]), .enable(pb[2]), .clear(pb[17]), .data_in(data_in), .right(right[3:0]), .left(left[3:0]), .at_end(red), .data_out(data_out));
  syncro_edgedetector u2 (.clk(hwclk), .nrst(~pb[19]), .button_i(pb[0]), .test_strobe(blue));

endmodule




