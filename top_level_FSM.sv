module top_FSM
     #(
        input logic strobe,
        input logic nrst,
        input logic clk

        output logic [1:0] mode,
        output logic idle, 
        output logic read,
        output logic write,
        output logic finish

);

logic [1:0] next_mode;
typedef enum logic [1:0] {IDLE = 2'b00, READ = 2'b01, WRITE = 2'b10, FINISH = 2'b11} states;
assign idle = (mode = IDLE);
assign read = (mode = READ);
assign write = (mode = WRITE);
assign finish = (mode = FINISH);

always_ff @ (posedge clk, negedge nrst) begin
    if(~nrst)
        mode <= IDLE;
    else 
        mode <= next_mode;
end

always_comb begin
if (strobe) begin
    case(mode)
        IDLE: next_mode = READ;
        READ: next_mode = WRITE;
        WRITE: next_mode = FINISH;
        FINISH: next_mode = IDLE;
        default: next_mode = IDLE;
    endcase 
end

else  
    next_mode = mode;

end 
endmodule