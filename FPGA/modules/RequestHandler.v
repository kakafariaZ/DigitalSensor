/**
* This module implements a decoder for handling the information comming from the 'Client'. It
* receives the two bytes representing, respectively, the request code and address of the targeted
* sensor.
*
* The `request` is stored and will be used in the `SensorDecoder` module to determine which
* information will be sent back, and the `device_selector` represents the set of avaliable sensors,
* each of the bits representing one of the avaliable sensors.
*
* NOTE: Currently, the only mapped address/device is the DHT11, assigned to the LSB bit of the
* `device_selector`. When it's address is decoded, said bit is driven to a high logical level,
* indicating that the sensor will be activated.
*/
module RequestHandler (
    input wire clock,
    input wire has_request,
    input wire [7:0] received_data,
    output wire device_selected,
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

  /**
  * Performs a bitwise `or` operation on the `device_selector` to check if any known device was
  * selected. The output of the operation, the `enable` signal, is used to trigger the
  * `SensorDecoder` state machine.
  */
  assign device_selected = |device_selector;

endmodule
