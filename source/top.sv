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

  ////////////////////
  //Image Controller//
  ////////////////////
  ic u1 (.clk(pb[3]), .nrst(~pb[19]), .enable(pb[2]), .clear(pb[17]), .right(right[3:0]), .left(left[3:0]), .at_end(red));


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
module ic (
  input logic clk,
  input logic nrst,
  input logic enable,
  input logic clear,
  output logic [3:0]left,
  output logic [3:0]right,
  output logic at_end
);

  logic horizontal_strobe, vertical_strobe;
  counter horiztonal (.clk(clk), .nrst(nrst), .enable(enable), .clear(clear), .wrap(1), .max(4'b111), .count(left), .at_max(horizontal_strobe));
  counter vertical (.clk(horizontal_strobe), .nrst(nrst), .enable(enable), .clear(clear), .wrap(1), .max(4'b111), .count(right), .at_max(vertical_strobe));  
  assign at_end = horizontal_strobe & vertical_strobe;

endmodule