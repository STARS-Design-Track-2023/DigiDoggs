`default_nettype none

module new_z #(
    parameter FIXED_POINT_WIDTH = 16 
) (
    input logic signed [FIXED_POINT_WIDTH-1:0] z_real, z_imaginary, c_real, c_imaginary,
    output logic signed [FIXED_POINT_WIDTH-1:0] new_z_real, new_z_imaginary
);

logic signed [2*FIXED_POINT_WIDTH-1:0] z_real_squared, z_imaginary_squared;
logic signed [2*FIXED_POINT_WIDTH-1:0] intermediate_real, intermediate_imaginary;

assign z_real_squared = ((z_real * z_real) << 3) >> FIXED_POINT_WIDTH;
assign z_imaginary_squared = ((z_imaginary * z_imaginary) << 3) >> FIXED_POINT_WIDTH;

assign intermediate_real = (z_real_squared - z_imaginary_squared);
assign intermediate_imaginary = ((2 * z_real * z_imaginary) << 3) >> (FIXED_POINT_WIDTH + 1);

assign new_z_real = intermediate_real[FIXED_POINT_WIDTH-1:0] + c_real;
assign new_z_imaginary = intermediate_imaginary[FIXED_POINT_WIDTH-1:0] + c_imaginary;

endmodule