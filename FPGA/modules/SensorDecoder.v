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
    output reg [7:0] response,
    output reg [7:0] response_code,
    output reg finished
);

  reg [26:0] counter;

  wire [39:0] sensor_data;
  wire [7:0] hum_int;
  wire [7:0] hum_float;
  wire [7:0] temp_int;
  wire [7:0] temp_float;
  wire [7:0] checksum;

  reg enable_sensor;

  wire hold;
  wire error;
  wire data_valid;

  // DHT11 SS0 (
  //     .clock(clock),
  //     .enable(enable_sensor & device_selector[0]),
  //     .transmission_line(transmission_line),
  //     .sensor_data(sensor_data),
  //     .error(error),
  //     .done(done)
  // );

  DHT11_Alt SS0 (
      .clock(clock),
      .enable_sensor(enable_sensor & device_selector[0]),
      .dht11(transmission_line),
      .dados_sensor(sensor_data),
      .erro(error),
      .done(done)
  );

  assign hum_int = sensor_data[39:32];
  assign hum_float = sensor_data[31:24];
  assign temp_int = sensor_data[23:16];
  assign temp_float = sensor_data[15:8];
  assign checksum = sensor_data[7:0];

  assign data_valid = (checksum == hum_int + hum_float + temp_int + temp_int) ? 1'b1 : 1'b0;

  localparam [1:0] IDLE = 2'b00, READ = 2'b01, LOOP = 2'b10, FINISH = 2'b11;

  reg [2:0] current_state = IDLE;

  localparam TEMP = 1'b1, HUM = 1'b0;
  localparam INT = 1'b1, FLOAT = 1'b0;

  reg selected_measure;
  reg current_part;

  always @(posedge clock) begin
    case (current_state)
      IDLE: begin
        if (enable == 1'b0) begin
          enable_sensor <= 1'b0;
          current_state <= IDLE;
        end else begin
          enable_sensor <= 1'b1;
          current_state <= READ;
        end
      end
      READ: begin
        if (done == 1'b0) begin
          current_state <= READ;
        end else begin
          case (request)
            8'h00: begin  // Current state of the sensor.
              if (done == 1'b1 && data_valid == 1'b1 && error == 1'b0) begin
                response_code <= 8'h10;
                response <= 8'h11;  // Sensor working normally.
                finished <= 1'b1;
                current_state <= FINISH;
              end else begin
                response_code <= 8'h10;
                response <= 8'h12;  // Sensor with problems.
                finished <= 1'b1;
                current_state <= FINISH;
              end
            end
            8'h01: begin  // Request the current temperature level.
              response_code <= 8'h13;
              response <= temp_int;  // Integer part of the temperature.
              finished <= 1'b1;
              current_state <= FINISH;
            end
            8'h02: begin  // Request the current humidity level.
              response_code <= 8'h14;
              response <= hum_int;  // Integer part of the humidity.
              finished <= 1'b1;
              current_state <= FINISH;
            end
            8'h03: begin  // Activate the current monitoring of the temperature.
              response_code <= 8'h15;
              response <= 8'hCA;
              finished <= 1'b1;
              current_state <= LOOP;
            end
            8'h04: begin  // Activate the current monitoring of the humidity.
              response_code <= 8'h16;
              response <= 8'hCA;
              finished <= 1'b1;
              current_state <= LOOP;
            end
            8'h05: begin  // Deactivate the current monitoring of the temperature.
              response_code <= 8'h17;
              response <= 8'hEA;  // Invalid action! Can't Deactivate something that isn't active...
              finished <= 1'b1;
              current_state <= FINISH;
            end
            8'h06: begin  // Deactivate the current monitoring of the humidity.
              response_code <= 8'h18;
              response <= 8'hEA;  // Invalid action! Can't Deactivate something that isn't active...
              finished <= 1'b1;
              current_state <= FINISH;
            end
            default: begin
              response_code <= 8'hEC;  // Invalid command!
              response <= 8'hEC;
              finished <= 1'b1;
              current_state <= FINISH;
            end
          endcase
        end
      end
      LOOP: begin
        if (request == 8'h05 || request == 8'h06) begin
          if (request == 8'h05) begin  // Deactivate the current monitoring of the temperature.
            response_code <= 8'h17;  // Confirms the deactivation of the monitoring.
            response <= 8'hCA;  // Confirms the previous action.
          end else begin
            response_code <= 8'h18;  // Confirms the deactivation of the monitoring.
            response <= 8'hCA;  // Confirm the previous action.
          end
          counter <= 27'd0;
          finished <= 1'b1;
          enable_sensor <= 1'b0;
          current_state <= FINISH;
        end else begin
          if (counter >= 27'd100000000) begin
            enable_sensor <= 1'b1;
            if (done == 1'b1) begin
              case (selected_measure)
                TEMP: begin
                  response_code <= 8'h13;
                  response <= temp_int;
                end
                HUM: begin
                  response_code <= 8'h14;
                  response <= hum_int;
                end
                default: response <= 8'hFF;
              endcase
            end
          end else begin
            counter <= counter + 27'd1;
            finished <= 1'b0;
            enable_sensor <= 1'b0;
            current_state <= LOOP;
          end
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
