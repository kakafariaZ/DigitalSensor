module ResponseHandler (
    input wire clock,
    input wire has_response,
    input wire [7:0] request_code,
    input wire [7:0] data_to_send,
    output reg response_ready,
    output reg [7:0] response
);

  localparam TYPE = 1'b0, DATA = 1'b1;

  reg current_state;

  always @(posedge clock) begin
    if (has_response == 1'b1) begin
      case (current_state)
        TYPE: begin
          case (request_code)
            8'h00:   response <= 8'h00; // WARN: Request sensor current state...
            8'h01:   response <= 8'h12;
            8'h02:   response <= 8'h13;
            8'h03:   response <= 8'h14;
            8'h04:   response <= 8'h15;
            8'h05:   response <= 8'h16;
            8'h06:   response <= 8'h17;
            8'h07:   response <= 8'h18;
            8'h08:   response <= 8'h19;
            default: response <= 8'b00000000;
          endcase
          current_state <= DATA;
          response_ready <= 1'b1;
        end
        DATA: begin
          current_state <= TYPE;
          response_ready <= 1'b1;
          response <= data_to_send;
        end
        default: begin
          current_state <= TYPE;
        end
      endcase
    end
  end

endmodule
