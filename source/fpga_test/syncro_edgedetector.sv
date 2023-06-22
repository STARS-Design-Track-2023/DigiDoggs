////////////    /////////////////
// SYNCRO // &  //Edge Detector//
////////////    /////////////////
module syncro_edgedetector(
    input logic clk,
    input logic nrst,
    input logic button_i,
    output logic test_strobe //This is just for testing. Will be the circut input in future commits
  );
  
  ////////////
  // SYNCRO //
  ////////////
  logic desync, sync;
  always_ff @ (posedge clk, negedge nrst) begin 
    if(~nrst)
    begin
        desync <= 0;
        sync <= 0;
    end
    else
    begin
        desync <= button_i;
        sync <= desync;
    end
  end

  ///////////////////
  // EDGE DETECTOR //
  ///////////////////
  logic strobe;
  always_comb begin 
    if(desync & ~sync)
      strobe = 1;
    else
      strobe = 0;
  end 

  assign test_strobe = strobe;   //This is just an FPGA output to test ed/syncro
endmodule