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
    input wire enable,
    input wire [7:0] received_data,
    output wire device_selected,
    output reg has_request,
    output reg [7:0] request,
    output reg [31:0] device_selector,
    output reg [2:0] debug_state
);

  reg [7:0] address;

  localparam [3:0] IDLE    = 3'b000,
                   REQUEST = 3'b001,
                   ADDRESS = 3'b010,
                   SELECT  = 3'b011,
                   FINISH  = 3'b100;

  reg [2:0] current_state;

  initial begin
    has_request = 1'b0;
    request = 8'd0;
    address = 8'd0;
    device_selector = 32'd0;
    current_state = IDLE;
    debug_state = IDLE;
  end

  always @(posedge clock) begin
    debug_state <= current_state;
    case (current_state)
      IDLE: begin
        has_request <= 1'b0;
        if (enable == 1'b1) begin
          current_state <= REQUEST;
        end else begin
          current_state <= IDLE;
        end
      end
      REQUEST: begin
        request <= received_data;
        current_state <= ADDRESS;
      end
      ADDRESS: begin
        address <= received_data;
        current_state <= SELECT;
      end
      SELECT: begin
        if (address == 8'b00100000) begin
          device_selector[0] <= 1'b1;
        end else begin
          device_selector <= 32'b00000000000000000000000000000000;
        end
        current_state <= FINISH;
        has_request   <= 1'b1;
      end
      FINISH: begin
        request = 8'd0;
        address = 8'd0;
        device_selector = 32'd0;
        current_state = IDLE;
      end
      default: begin
        current_state <= IDLE;
      end
    endcase
  end

  /**
  * Performs a bitwise `or` operation on the `device_selector` to check if any known device was
  * selected. The output of the operation, the `enable` signal, is used to trigger the
  * `SensorDecoder` state machine.
  */
  assign device_selected = |device_selector;

endmodule
