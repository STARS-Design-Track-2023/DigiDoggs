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

assign logic clk  = hz100;
assign logic nrst = ~pb[0];
logic bs;
logic vert_enable;
logic [8:0]horiz_count;
logic [8:0]vert_count;

assign{left[0],right[7:0]} = horiz_count 

horiz_counter u1 (.clk(clk), .nrst(nrst), .enable(1'b1), .clear(pb[1]), .wrap(1'b1), .max(9'd320), .count(horiz_count), .at_max(bs), .enable_out(vert_enable));

vert_counter u2 (.clk(clk), .nrst(nrst), .enable(vert_enable), .clear(pb[1]), .wrap(1'b1), .max(9'd240), .count(vert_count), .at_max(bs));

endmodule

module vert_counter #

(
    parameter N = 9 // Size of counter
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



module horiz_counter #

(
    parameter N = 9 // Size of counter
)

(
    input logic clk,            // Clock
    input logic nrst,           // Asyncronous active low reset
    input logic enable,         // Enable
    input logic clear,          // Synchronous active high clear
    input logic wrap,           // 0: no wrap at max, 1: wrap to 0 at max
    input logic [N - 1:0] max,      // Max number of count (inclusive)
    output logic [N - 1:0] count,   // Current count
    output logic at_max,        // 1 when counter is at max, otherwise 0
    output logic enable_out           //enable for the vertical counter
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
    if (count == max)begin         //check for max value
        at_max = 1 ;
        enable_out =1;
        end
    else
        begin
        at_max = 0;
        enable_out = 0;
        end


    if(clear)

        next_count = 0;        //if clear enabled, then count = 0

    else

        if(enable)             //if enable engaged, then the counter starts counting

        begin

            if((count == max) && wrap) begin     //if wrap is engaged when count reaches max, then it wraps back to zero

                next_count = 0;                                               //if horizontal count is less than max, then the enable is set to 1

                                enable_out = 1'b1;

                    end

                

            else if (count == max && ~wrap) //if wrap not engaged at max, then count stops

                next_count = count;

            else begin                           //if not at max then count is incremented

                next_count = count + 1;                               //and the vertical count enabler is set to zero

                    end

        end

        else

            next_count = count;             //if enable not on then count remains constant

end

endmodule