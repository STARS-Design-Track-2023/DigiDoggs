`timescale 1ns/100ps
`define CLOCK_PERIOD 100
`define RESET_INACTIVE 1
`define RESET_ACTIVE 0

`define SPI_MESSAGE_WIDTH 2
`define SPI_MESSAGE_DEPTH 24

module tb_top (

);
    


endmodule

/************************************************************************

IF YOU ARE PART OF MY GROUP, THERE IS NOTHING BELOW THIS COMMENT BLOCK :)

    - Spencer B

************************************************************************/

module ref_top (
    input wire clk, nrst, spi_clk, spi_en,
    input wire [`SPI_MESSAGE_WIDTH-1:0] spi_data,
    output reg [`SPI_MESSAGE_DEPTH-1:0] color 
);

    wire valid_data;
    wire [`SPI_MESSAGE_WIDTH * `SPI_MESSAGE_DEPTH - 1:0] spi_data_out;

    ref_spi #(
        .DATA_WIDTH(`SPI_MESSAGE_WIDTH),
        .DATA_DEPTH(`SPI_MESSAGE_DEPTH)
    ) input_spi (
        .clk(clk), .nrst(nrst),
        .spi_clk(spi_clk),
        .spi_en(spi_en),
        .spi_data(spi_data),
        .valid_data(valid_data),
        .data_out(spi_data_out)
    );

    // ref_mandelbrotetron 

endmodule

module ref_mandelbrotetron #(
    parameter FIXED_POINT_WIDTH = 16,
    parameter MAX_ITER = 256
) (
    input wire clk, nrst, start, 
    input wire signed [FIXED_POINT_WIDTH-1:0] c_real_in, c_imaginary_in,
    output reg valid,
    output reg is_mandelbrot,
    output reg [$clog2(MAX_ITER)-1:0] iterations 
);

    //////////////////////////////
    // MANDELBROT-IFICATION!!!! //
    //////////////////////////////

    reg signed [FIXED_POINT_WIDTH-1:0] c_real, c_imaginary, z_real, z_imaginary;
    wire signed [FIXED_POINT_WIDTH-1:0] next_c_real, next_c_imaginary, next_z_real, next_z_imaginary;
    wire signed [FIXED_POINT_WIDTH-1:0] computed_z_real, computed_z_imaginary;

    always @(posedge clk, negedge nrst) begin
        if (~nrst) begin
            c_real <= 0;
            c_imaginary <= 0; 
            z_real <= 0; 
            z_imaginary <= 0;
        end
        else begin
            c_real <= next_c_real;
            c_imaginary <= next_c_imaginary; 
            z_real <= next_z_real; 
            z_imaginary <= next_z_imaginary;
        end
    end

    ref_new_z #(
        .FIXED_POINT_WIDTH(FIXED_POINT_WIDTH)
    ) z_function (
        .z_real(z_real),
        .z_imaginary(z_imaginary),
        .c_real(c_real),
        .c_imaginary(c_imaginary),
        .new_z_real(computed_z_real),
        .new_z_imaginary(computed_z_imaginary)
    );

    ///////////////////////
    // ITERATION COUNTER //
    ///////////////////////

    wire max_iter_reached;

    ref_counter #(
        .N($clog2(MAX_ITER))
    ) iteration_counter (
        .clk(clk), .nrst(nrst),
        .clear(start),
        .wrap(1'b0),
        .en(/* TODO */),
        .max(MAX_ITER[$clog2(MAX_ITER)-1:0]),
        .count(/* TODO */),
        .at_max(max_iter_reached)
    );

    /////////////////////////////////////
    // Start and valid signal handling //
    /////////////////////////////////////

    // always @(posedge clk, negedge nrst) begin
    //     if (~nrst)
    //         valid <= 0;
    //     else 
    //         valid <= next_valid;
    // end

endmodule

// This module may totally not work!
// Inputs: One sign, one integral, the rest are fractional (e.g. SI.FFFF...)
module ref_new_z #(
    parameter FIXED_POINT_WIDTH = 16 
) (
    input wire signed [FIXED_POINT_WIDTH-1:0] z_real, z_imaginary, c_real, c_imaginary,
    output wire signed [FIXED_POINT_WIDTH-1:0] new_z_real, new_z_imaginary
);

    wire signed [2*FIXED_POINT_WIDTH-1:0] intermediate_real, intermediate_imaginary;

    assign intermediate_real = (z_real * z_real - z_imaginary * z_imaginary);
    assign intermediate_imaginary = (2 * z_real * z_imaginary);

    assign new_z_real = $signed(intermediate_real[2*FIXED_POINT_WIDTH-1:FIXED_POINT_WIDTH]) + c_real;
    assign new_z_imaginary = $signed(intermediate_imaginary[2*FIXED_POINT_WIDTH-1:FIXED_POINT_WIDTH]) + c_imaginary;
endmodule

module ref_spi #(
    parameter DATA_WIDTH = 2,
    parameter DATA_DEPTH = 16
) (
    input wire clk, nrst, spi_clk, spi_en, 
    input wire [DATA_WIDTH-1:0] spi_data, 
    output wire valid_data, // Output of edge detector, valid for 1 clock cylce
    output reg [DATA_WIDTH * DATA_DEPTH - 1:0] data_out // Valid when valid_data is high
);
    ///////////////////////////////////////
    // SYNCRONIZATION AND EDGE DETECTION //
    ///////////////////////////////////////

    wire spi_clk_sync;
    wire spi_clk_edge;
    wire spi_en_sync;
    wire spi_en_edge_sync;
    wire spi_en_edge;
    wire [DATA_WIDTH-1:0] spi_data_sync;

    // SPI Clock Input  
    ref_syncronizer #(.DEPTH(2)) spi_clk_syncronizer (
        .clk(clk), .nrst(nrst),
        .async_in(spi_clk),
        .sync_out(spi_clk_sync)
    );

    ref_posedge_detector spi_clk_posedge_detector (
        .clk(clk), .nrst(nrst),
        .signal(spi_clk_sync),
        .posedge_detected(spi_clk_edge)
    );

    // SPI Enable Input
    ref_syncronizer #(.DEPTH(3)) spi_en_syncronizer (
        .clk(clk), .nrst(nrst),
        .async_in(spi_en),
        .sync_out(spi_en_sync)
    );

    ref_syncronizer #(.DEPTH(2)) spi_en_edge_syncronizer (
        .clk(clk), .nrst(nrst),
        .async_in(spi_en),
        .sync_out(spi_en_edge_sync)
    );

    ref_posedge_detector spi_en_posedge_detector (
        .clk(clk), .nrst(nrst),
        .signal(spi_en_edge_sync),
        .posedge_detected(spi_en_edge)
    );

    // SPI Data Input
    ref_syncronizer #(.DEPTH(3), .WIDTH(DATA_WIDTH)) 
    spi_data_syncronizer (
        .clk(clk), .nrst(nrst),
        .async_in(spi_data),
        .sync_out(spi_data_sync)
    );

    ////////////////////////////////
    // SHIFT REGISTER SHENANIGANS //
    ////////////////////////////////

    wire [DATA_WIDTH * DATA_DEPTH - 1:0] next_data_out;

    always @(posedge clk, negedge nrst) begin
        if (~nrst)
            data_out <= 0;
        else
            data_out <= next_data_out; 
    end

    generate
        for (genvar i = 0; i < DATA_WIDTH; i = i + 1) begin
            ref_shift_reg #(.DEPTH(DATA_DEPTH)) spi_shift_reg (
                .clk(clk), .nrst(nrst),
                .en(spi_clk_edge),
                .q(spi_data_sync[i]),
                .p_out(next_data_out[DATA_DEPTH*(i+1) - 1:DATA_DEPTH*i])
            );
        end
    endgenerate

    /////////////////////////////////////////
    // CRAZY COUNTER CARNIVAL (I AM SANE!) //
    /////////////////////////////////////////

    wire all_data_received;

    ref_counter #(.N($clog2(DATA_DEPTH))) spi_data_counter (
        .clk(clk), .nrst(nrst),
        .clear(spi_en_edge), 
        .en(spi_clk_edge),
        .wrap(1'b0),
        .max(DATA_DEPTH[$clog2(DATA_DEPTH)-1:0]),
        .count(),
        .at_max(all_data_received)
    );

    ref_posedge_detector data_valid_pulser (
        .clk(clk), .nrst(nrst),
        .signal(all_data_received),
        .posedge_detected(valid_data)
    );
    
endmodule

module ref_syncronizer #(
    parameter WIDTH = 1,
    parameter DEPTH = 2
) (
    input wire clk, nrst, 
    input wire [WIDTH-1:0] async_in,
    output wire [WIDTH-1:0] sync_out
);
    generate
        if (DEPTH == 0) begin
            assign sync_out = async_in;
        end
        else begin
            reg [DEPTH*WIDTH-1:0] internal_shift_reg;

            always @(posedge clk, negedge nrst) begin
                if (~nrst)
                    internal_shift_reg <= 0;
                else begin
                    internal_shift_reg <= {async_in, internal_shift_reg[DEPTH*WIDTH-1:WIDTH]};
                end
            end
            
            assign sync_out = internal_shift_reg[WIDTH-1:0];
        end
    endgenerate
    
endmodule

module ref_posedge_detector (
    input wire clk, nrst, 
    input wire signal,
    output wire posedge_detected
);
    reg q;

    always @(posedge clk, negedge nrst) begin
        if (~nrst)
            q <= 0;
        else
            q <= signal;
    end

    assign posedge_detected = ~q & signal;
endmodule

// Only supports 1 wide b/c yosys shits itself at 2D module i/o
module ref_shift_reg #( 
    parameter DEPTH = 24,
    parameter ENTERS_AT_LSB = 1
) (
    input wire clk, nrst, en, q,
    output reg [DEPTH-1:0] p_out
);
    
    wire [DEPTH-1:0] next_p_out, p_shifted;

    always @(posedge clk, negedge nrst) begin
        if (~nrst) 
            p_out <= 0;
        else
            p_out = {p_out[DEPTH-2:0], q};
    end

    assign next_p_out = en ? p_shifted : p_out;

    generate
        if (ENTERS_AT_LSB) begin
            assign p_shifted = {p_out[DEPTH-2:0], q};
        end
        else begin
            assign p_shifted = {q, p_out[DEPTH-1:1]};
        end
    endgenerate

endmodule

module ref_counter #(
    parameter N = 4
) (
    input wire clk, nrst, clear, wrap, en, 
    input wire [N-1:0] max,
    output reg [N-1:0] count,
    output wire at_max
);

    // IS REG OKAY???
    reg [N-1:0] next_count;

    always @(posedge clk, negedge nrst) begin
        if (~nrst)
            count <= 0;
        else
            count <= next_count;
    end

    always @(*) begin
        casex ({clear, en, wrap})
            3'b1xx: next_count = 0; // Clear condition
            3'b00x: next_count = count; // Unenabled condition
            3'b010: next_count = (count == max) ? count : count + 1; // Unwraped condition
            3'b011: next_count = (count == max) ? 0 : count + 1; // Wrapped condition
            default: next_count = 'bx; // "Oh shit something went wrong" condition
        endcase
    end
    
endmodule
