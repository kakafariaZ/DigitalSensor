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
    input wire enable,
    input wire [7:0] response_code,
    input wire [7:0] response_data,
    output reg has_response,
    output reg [7:0] response
);

  localparam [1:0] IDLE = 2'b00, RESPONSE_CODE = 2'b01, RESPONSE_DATA = 2'b10, FINISH = 2'b11;

  reg [1:0] current_state;

  initial begin
    has_response <= 1'b0;
    response <= 8'd0;
    current_state <= IDLE;
  end

  always @(posedge clock) begin
    case (current_state)
      IDLE: begin
        has_response <= 1'b0;
        if (enable == 1'b1) begin
          current_state <= RESPONSE_CODE;
        end else begin
          current_state <= IDLE;
        end
      end
      RESPONSE_CODE: begin
        response <= response_code;
        current_state <= RESPONSE_DATA;
      end
      RESPONSE_DATA: begin
        has_response <= 1'b1;
        response <= response_data;
        current_state <= FINISH;
      end
      FINISH: begin
        response <= 8'd0;
        current_state <= IDLE;
      end
      default: begin
        has_response <= 1'b0;
        response <= 8'd0;
        current_state <= IDLE;
      end
    endcase
  end

endmodule
