module turn_on_pix (
    input logic [2:0] 1_pix,
    input logic [2:0] 2_pix,
    input logic [8:0] horiz_count,
    input logic at_max_horiz,
    input logic nrst,
    input logic clk,

    output logic pixel
);

1_pix_det u1(.clk(clk), .nrst(nrst), .at_max_horiz(at_max_horiz), .1_pix(1_pix));
2_pix_det u2(.clk(clk), .nrst(nrst), .at_max_horiz(at_max_horiz), .2_pix(2_pix));


always_ff(posedge clk, negedge nrst)begin

    if(horiz_count[2:0] == 1_pix || horiz_count [2:0] == 2_pix)
        pixel = 1'b1;
    else
        pixel = 1'b0;

end

endmodule


module 1_pix_det(
    input logic clk,
    input logic nrst,
    input logic at_max_horiz,
    
    output logic [2:0]1_pix,

);
    
    logic [2:0 next_1_pix];

    typedef enum logic [2:0] {seven = 3'b111, five = 3'b011, three = 3'b011, one = 3'b001}

        always_ff(posedge clk, negedge nrst) begin
            if(~nrst)
                1_pix <= 3'b111;
            else
                1_pix <= next_1_pix;
        end 

    always_comb begin
        if(at_max_horiz)begin
            case(mode)
            seven: next_1_pix = five;
            five:  next_1_pix = three;
            three: next_1_pix = one;
            one:   next_1_pix = seven;
            default : next_1_pix = seven;
            endcase
        else

        next_mode = mode;

        end 
    end

endmodule

module 2_pix_det(
    input logic clk,
    input logic nrst,
    input logic at_max_horiz,
    
    output logic [2:0]2_pix,

);
    
    logic [2:0 next_2_pix];

    typedef enum logic [2:0] {zero = 3'b000, six = 3'b011, four = 3'b100, two = 3'b010}

        always_ff(posedge clk, negedge nrst) begin
            if(~nrst)
                2_pix <= 3'b000;
            else
                2_pix <= next_2_pix;
        end 

    always_comb begin
        if(at_max_horiz)begin
            case(mode)
            zero: next_2_pix = five;
            six:  next_2_pix = three;
            four: next_2_pix = one;
            two:   next_2_pix = seven;
            default : next_2_pix = seven;
            endcase
        else

        next_mode = mode;

        end 
    end

endmodule