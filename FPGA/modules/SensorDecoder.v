/**
* This module implements a high level 'Facade' for handling the information comming from the
* available sensors and delivering them properly per the requests given by the 'Client'.
*
* NOTE: Currently only working with the DHT11 sensor, whose module can be found in this project
* under the name of `DHT11.v`.
*/

module SensorDecoder (
    input wire clock,
    input wire enable,
    inout wire transmission_line,
    input wire [31:0] device_selector,
    input wire [7:0] request,
    output reg [7:0] requested_data,
    output reg finished
);

  wire [7:0] hum_int;
  wire [7:0] hum_float;
  wire [7:0] temp_int;
  wire [7:0] temp_float;
  wire [7:0] checksum;

  reg reset_sensor;
  reg enable_sensor;

  wire hold;
  wire debug;
  wire error;

  DHT11 SS0 (
      .clock(clock),
      .enable(enable_sensor & device_selector[0]),
      .reset(reset_sensor),
      .transmission_line(transmission_line),
      .hum_int(hum_int),
      .hum_float(hum_float),
      .temp_int(temp_int),
      .temp_float(temp_float),
      .checksum(checksum),
      .hold(hold),
      .debug(debug),
      .error(error)
  );

  localparam [1:0] IDLE = 2'b00, READ = 2'b01, SEND = 2'b10, FINISH = 2'b11;

  reg [1:0] current_state = IDLE;

  always @(posedge clock) begin
    case (current_state)
      IDLE: begin
        if (enable == 1'b1) begin
          enable_sensor <= 1'b1;
          reset_sensor  <= 1'b1;
          current_state <= READ;
        end
      end
      READ: begin
        if (hold == 1'b1) begin
          current_state <= SEND;
        end else begin
          enable_sensor <= 1'b1;
          reset_sensor  <= 1'b0;
        end
      end
      SEND: begin
        if (hold == 1'b0) begin
          if (error == 1'b1) begin
            requested_data <= 8'h10;
          end else begin
            case (request)
              8'h00:   requested_data <= (error == 1'b1) ? 8'h10 : 8'h11;
              8'h01:   requested_data <= temp_int;
              8'h02:   requested_data <= temp_float;
              8'h03:   requested_data <= hum_int;
              8'h04:   requested_data <= hum_float;
              8'h05:   requested_data <= 8'b00000000;  // TODO: Act. C.M. Temp.
              8'h06:   requested_data <= 8'b00000000;  // TODO: Act. C.M. Hum.
              8'h07:   requested_data <= 8'b00000000;  // TODO: Deact. C.M. Temp.
              8'h08:   requested_data <= 8'b00000000;  // TODO: Deact. C.M. Hum.
              8'hCB:   requested_data <= 8'b00000000;  // TODO: Begin Comm.
              8'hCD:   requested_data <= 8'b00000000;  // TODO: Drop Comm.
              default: requested_data <= 8'b00000000;
            endcase
          end
          finished <= 1'b1;
          current_state <= FINISH;
        end
      end
      FINISH: begin
        finished <= 1'b0;
        enable_sensor <= 1'b0;
        current_state <= IDLE;
      end
      default: begin
        current_state <= IDLE;
      end
    endcase
  end

endmodule
