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