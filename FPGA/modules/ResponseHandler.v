/**
* This module implements a decoder for handling the data received from the `SensorDecoder` module.
* It receives the two bytes representing, respectively, the request code and the information decode
* by the `SensorDecoder`.
*
* It sends the corresponding response code and the decoded information back to the 'Client', by
* handing it to the `UART_TX` module.
*/

module ResponseHandler (
    input wire clock,
    input wire has_response,
    input wire [7:0] data_to_send,
    input wire [7:0] response_code,
    output reg response_ready,
    output reg [7:0] response
);

  localparam CODE = 1'b0, DATA = 1'b1;

  reg current_state;

  always @(posedge clock) begin
    if (has_response == 1'b1) begin
      case (current_state)
        CODE: begin
          current_state <= DATA;
          response_ready <= 1'b1;
          response <= response_code;
        end
        DATA: begin
          current_state <= CODE;
          response_ready <= 1'b1;
          response <= data_to_send;
        end
        default: begin
          current_state <= CODE;
          response_ready <= 1'b0;
          response <= 8'hFF;
        end
      endcase
    end
  end

endmodule
