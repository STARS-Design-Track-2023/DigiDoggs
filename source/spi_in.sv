`include "edge_detector.sv"
`include "sync.sv"
`include "shift_register.sv"
`include "buffer_register.sv"
`include "counter.sv"


module spi_in #(
    parameter DATA_WIDTH = 16,
    parameter DATA_QUANTITY = 2
) (
    input logic clk, nrst, spi_clock, en,
    input logic [DATA_QUANTITY - 1:0] data_in,   
    output logic [DATA_WIDTH * DATA_QUANTITY - 1:0] data_out, 
    output logic done_signal
);

// internal signals
logic syncro_spi_clock;
logic syncro_enable;
logic syncro_enable_2;
logic edge_spi_clock; 
logic edge_spi_en;
logic all_data_received;
logic valid_data;
logic [DATA_QUANTITY-1:0] sync_data;
logic [DATA_QUANTITY * DATA_WIDTH - 1:0] next_data_out;


////////////
// SYNCRO //   
////////////

sync #(.WIDTH(2)) sync_clk (.clk(clk), .nrst(nrst), .signal(spi_clock), .syncro(syncro_spi_clock));
sync #(.WIDTH(3), .QUANTITY(DATA_QUANTITY)) sync_mosi (.clk(clk), .nrst(nrst), .signal(data_in), .syncro(sync_data));
sync #(.WIDTH(3)) sync_en (.clk(clk), .nrst(nrst), .signal(en), .syncro(syncro_enable));
sync #(.WIDTH(2)) sync_en2 (.clk(clk), .nrst(nrst), .signal(en), .syncro(syncro_enable_2));

///////////////////
// EDGE DETECTOR //
///////////////////

edge_detector spi_clk(.clk(clk), .nrst(nrst), .signal(syncro_spi_clock), .posedge_detected(edge_spi_clock));
edge_detector spi_en(.clk(clk), .nrst(nrst), .signal(syncro_enable_2), .posedge_detected(edge_spi_en)); 


/////////////////////
////// COUNTER //////
/////////////////////

counter #(.N($clog2(DATA_WIDTH))) spi_data_counter (.clk(clk), .nrst(nrst), .clear(edge_spi_en), .en(edge_spi_clock), .wrap(1'b0), .max(DATA_WIDTH[$clog2(DATA_WIDTH)-1:0]), .count(), .at_max(all_data_received));
edge_detector edge_counter(.clk(clk), .nrst(nrst), .signal(all_data_received), .posedge_detected(valid_data));


/////////////////////
/// SHIFT REGISTER //
/////////////////////

always_ff @(posedge clk, negedge nrst) begin
    if (!nrst)
        data_out <= 0;
    else
        data_out <= next_data_out; 
end

generate
    for(genvar i = 0; i < DATA_QUANTITY; i = i + 1)begin
        shift_reg #(.WIDTH(DATA_WIDTH)) data_shift (.clk(clk), .nrst(nrst), .en(edge_spi_clock), .data_in_serial(sync_data[i]), .data_out_parallel(next_data_out[DATA_WIDTH*(i+1)-1:DATA_WIDTH*i]));
    end
endgenerate

endmodule 





