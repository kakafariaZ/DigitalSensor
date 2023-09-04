/**
* This module implements a decoder for handling the requests given to the FPGA. The handling is
* based on the established communication protocol found in - (LINK).
*/
module RequestHandler (
    input clock,
    input has_request,
    input [7:0] received_data,
    output reg [7:0] request,
    output reg [31:0] device_selector
);

  reg [7:0] address = 8'b00000000;

  localparam [2:0] REQUEST = 2'b00, ADDRESS = 2'b01, SELECT = 2'b10;

  reg [2:0] current_state;

  always @(posedge clock) begin
    if (has_request == 1'b1) begin
      case (current_state)
        REQUEST: begin
          current_state <= ADDRESS;
          request <= received_data;
          device_selector <= 32'b00000000000000000000000000000000;
        end
        ADDRESS: begin
          current_state <= SELECT;
          address <= received_data;
        end
        SELECT: begin
          if (address == 8'b00100000) begin
            device_selector[0] <= 1'b1;
          end else begin
            device_selector <= 32'b00000000000000000000000000000000;
          end
          current_state <= REQUEST;
        end
        default: begin
          current_state <= REQUEST;
        end
      endcase
    end
  end

endmodule
