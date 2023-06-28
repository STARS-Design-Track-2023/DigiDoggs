module color_converter(input logic [7:0] iteration, 
input logic ismandelbrot, 
output logic [23:0] RGB);

logic [7:0] R, G, B;

always_comb begin 
    if (ismandelbrot) begin
        R = 8'b0;
        G = 8'b0;
        B = 8'b0;
    end
    else begin
        case (iteration[1:0]) 
            2'h0: R = 0;
            2'h1: R = 255 / 3;
            2'h2: R = 0;
            2'h3: R = 0;
            2'h4: R = 0; 
            2'h5: R = 0; 
            2'h6: R = 0;
            2'h7: R = 0;
        endcase
        R = iteration;
        G = iteration;
        B = iteration; 
    end
end

assign RGB = {R, G, B};

endmodule















