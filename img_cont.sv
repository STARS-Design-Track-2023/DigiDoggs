`default_nettype none
// Empty top module

module top (
  // I/O ports
  input  logic hz100, reset,
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


logic vert_enable;
logic [2:0]horiz_count;
logic [2:0]vert_count;
logic clk;
logic nrst;
logic clear;


assign  clk  = pb[3];
assign  nrst = ~pb[0];
assign right[2:0] = horiz_count;
assign left[2:0] = vert_count;
assign red = vert_enable;
assign clear = pb[1];

im_cont u1 (.clk(clk), .nrst(nrst), .clear(clear), .horiz_count(horiz_count), .vert_count(vert_count), .vert_enable(vert_enable), .vert_max(green));

endmodule


module im_cont(
input logic clk, nrst, clear,
output logic [2:0]horiz_count, vert_count,
output logic vert_enable, vert_max
);

counter horiz (.clk(clk), .nrst(nrst), .enable(1'b1), .clear(clear), .wrap(1'b1), .max(3'd5), .count(horiz_count), .at_max(vert_enable));
counter vert  (.clk(clk), .nrst(nrst), .enable(vert_enable), .clear(clear), .wrap(1'b1), .max(3'd4), .count(vert_count), .at_max(vert_max));

endmodule



module counter #

(
    parameter N = 3 // Size of counter
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

logic [(N-1):0]next_count;


always_ff @ (posedge clk, negedge nrst) begin
    if(~nrst)
        count <= 0;
    else
        count <= next_count;
end

always_comb begin
    next_count = 0;
    if (count == max)           //check for max value
        at_max = 1 ;
    else
        at_max = 0;

 
    if(clear)

        next_count = 0;        //if clear enabled, then count = 0

    else
        if(enable)             //if enable engaged, then the counter starts counting
        begin
            if((count == max) && wrap)      //if wrap is engaged when count reaches max, then it wraps back to zero

                next_count = 0;
               
            else if (count == max && ~wrap) //if wrap not engaged at max, then count stops
                next_count = count;
            else                            //if not at max then count is incremented
                next_count = count + 1;
        end
        else

            next_count = count;             //if enable not on then count remains constant
end

endmodule