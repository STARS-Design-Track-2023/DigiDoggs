module sync #(
  parameter QUANTITY = 1,
  parameter WIDTH = 2
) (

    input logic clk, nrst,
    input logic [QUANTITY-1:0] signal,
    output logic [QUANTITY-1:0] syncro
  );
  
  ////////////
  // SYNCRO //
  ////////////

if (WIDTH == 0) begin
    assign syncro = signal;
end
else begin
    logic [WIDTH*QUANTITY-1:0] shift_reg;

    always_ff @(posedge clk, negedge nrst) begin
        if (!nrst)
            shift_reg <= 0;
        else begin
            shift_reg <= {signal, shift_reg[WIDTH*QUANTITY-1:QUANTITY]};
        end
    end

    assign syncro = shift_reg[QUANTITY-1:0];
end
endmodule