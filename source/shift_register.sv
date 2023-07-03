module shift_reg #(
    parameter WIDTH = 24,
    parameter ENTERS_AT_LSB = 1
) (
    input logic clk, nrst, en, data_in_serial,
    output logic [WIDTH-1:0] data_out_parallel
);

logic [WIDTH-1:0] shift_reg;
logic [WIDTH-1:0] next_shift_reg;

always_ff @(posedge clk, negedge nrst) begin
    if (!nrst)
        data_out_parallel <= '0;
    else
        data_out_parallel <= {data_out_parallel[WIDTH-2:0], data_in_serial};
end

assign shift_reg = en ? next_shift_reg : data_out_parallel;

always_comb begin
    if (ENTERS_AT_LSB)
        next_shift_reg = {data_out_parallel[WIDTH-2:0], data_in_serial};
    else
        next_shift_reg = {data_in_serial, data_out_parallel[WIDTH-1:1]};
end

endmodule