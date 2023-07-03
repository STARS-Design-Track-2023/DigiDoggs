module edge_detector (
    input logic clk, nrst,
    input logic signal,
    output logic posedge_detected
);

  ///////////////////
  // EDGE DETECTOR //
  ///////////////////

  logic signal_prev;

  always_ff @(posedge clk, negedge nrst) begin
    if (!nrst)
      signal_prev <= 0;
    else
      signal_prev <= signal; 
  end

  assign posedge_detected = (signal && !signal_prev);  

endmodule