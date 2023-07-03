module counter #(
    parameter N = 4
) ( 
    input logic clk, nrst, en, wrap, clear,
    input logic [N-1:0] max,
    output logic [N-1:0] count,
    output logic at_max

);

logic [N-1:0] next_count;

always_ff @(posedge clk, negedge nrst) begin
    if (!nrst)
        count <= 0;
    else
        count <= next_count;
end

always_comb begin
    casex ({clear, en, wrap})
        3'b1xx: next_count = 0; // Clear condition
        3'b00x: next_count = count; // Unenabled condition
        3'b010: next_count = (count == max) ? count : count + 1; // Unwraped condition
        3'b011: next_count = (count == max) ? 0 : count + 1; // Wrapped condition
        default: next_count = 4'bx; // backup condition
    endcase
end
    
endmodule