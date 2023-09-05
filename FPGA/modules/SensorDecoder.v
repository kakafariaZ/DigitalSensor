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

  localparam [2:0] IDLE = 3'b000, READ = 3'b001, SEND = 3'b010, LOOP = 3'b011, FINISH = 3'b100;

  reg [2:0] current_state = IDLE;

  localparam TEMP = 1'b1, HUM = 1'b0;
  localparam INT = 1'b1, FLOAT = 1'b0;

  reg selected_measure;
  reg current_part;

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
              default: requested_data <= 8'b00000000;
            endcase
          end
          finished <= 1'b1;
          current_state <= FINISH;
        end else begin
          current_state <= SEND;
        end
      end
      LOOP: begin
        if (request != 8'h07 & request != 8'h08) begin
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
        end else begin
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
