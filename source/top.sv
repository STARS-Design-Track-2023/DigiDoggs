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
  iamge_controller u2 (.clk(hwclk), .nrst(~pb[19]), .enable(pb[2]), .clear(pb[17]), .right(right[3:0]), .left(left[3:0]), .at_end(red));


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

/////////////////
//Basic Counter//
/////////////////
module counter
    #(
        parameter N = 4 // Size of counter (i.e. number of bits at the output). Maximum count is 2^N - 1
    )
    (
        input logic clk,            // Clock
        input logic nrst,           // Asyncronous active low reset
        input logic enable,         // Enable
        input logic clear,          // Synchronous active high clear 
        input logic wrap,           // 0: no wrap at max, 1: wrap to 0 at max
        input logic [N - 1:0] max,      // Max number of count (inclusive)
        output logic [N - 1:0] count,   // Current count
        output logic at_max         // 1 when counter is at max, otherwise 0
    );
        logic [3:0]next_count;   
        always_ff @ (posedge clk, negedge nrst)
        begin
            if (~nrst)
                count <= 0;
            else
                count <= next_count;
        end

        always_comb
        begin
            at_max = 0;
            if(count == max)
                at_max = 1;
            if (enable)
            begin
                if(clear)
                    next_count = 0;
                else if(wrap&count == max)
                    next_count = 0;
                else if(~wrap&count == max)
                    next_count = count;
                else
                    next_count = count + 1;
            end
            else
                next_count = count;
        end
endmodule

////////////////////
//Image Controller//
////////////////////
module iamge_controller (
  input logic clk,
  input logic nrst,
  input logic enable,
  input logic clear,
  output logic [3:0]left,
  output logic [3:0]right,
  output logic at_end
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