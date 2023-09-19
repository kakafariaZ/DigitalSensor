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

  wire [39:0] sensor_data;
  wire [7:0] hum_int;
  wire [7:0] hum_float;
  wire [7:0] temp_int;
  wire [7:0] temp_float;
  wire [7:0] checksum;

  reg enable_sensor;

  wire hold;
  wire error;
  wire data_invalid;

  DHT11 SS0 (
      .clock(clock),
      .enable(enable_sensor & device_selector[0]),
      .transmission_line(transmission_line),
      .sensor_data(sensor_data),
      .error(error),
      .done(done)
  );

  assign hum_int = sensor_data[39:32];
  assign hum_float = sensor_data[31:24];
  assign temp_int = sensor_data[23:16];
  assign temp_float = sensor_data[15:8];
  assign checksum = sensor_data[7:0];

  assign data_invalid = (checksum == hum_int + hum_float + temp_int + temp_int) ? 1'b1 : 1'b0;

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
            8'h00: begin
              finished <= 1'b1;
              current_state <= FINISH;
              if (done == 1'b1 && error == 1'b0 && data_invalid == 1'b0) begin
                requested_data <= 8'h11;
              end else begin
                requested_data <= 8'h10;
              end
            end
            8'h01: begin
              finished <= 1'b1;
              current_state <= FINISH;
              requested_data <= temp_int;
            end
            8'h02: begin
              finished <= 1'b1;
              current_state <= FINISH;
              requested_data <= temp_float;
            end
            8'h03: begin
              finished <= 1'b1;
              current_state <= FINISH;
              requested_data <= hum_int;
            end
            8'h04: begin
              finished <= 1'b1;
              current_state <= FINISH;
              requested_data <= hum_float;
            end
            8'h05: begin
              current_part <= INT;
              current_state <= LOOP;
              selected_measure <= TEMP;
            end
            8'h06: begin
              current_part <= INT;
              current_state <= LOOP;
              selected_measure <= HUM;
            end
            default: begin
              finished <= 1'b1;
              current_state <= FINISH;
              requested_data <= 8'b00000000;
            end
          endcase
        end
      end
      LOOP: begin
        if (request == 8'h07 || request == 8'h08) begin
          finished <= 1'b1;
          current_state <= FINISH;
        end else begin
          case (selected_measure)
            TEMP: begin
              if (current_part == INT) begin
                requested_data <= temp_int;
                current_part   <= FLOAT;
              end else begin
                requested_data <= temp_float;
                current_part   <= INT;
              end
            end
            HUM: begin
              if (current_part == INT) begin
                requested_data <= hum_int;
                current_part   <= FLOAT;
              end else begin
                requested_data <= hum_float;
                current_part   <= INT;
              end
            end
            default: requested_data <= 8'b00000000;
          endcase
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
