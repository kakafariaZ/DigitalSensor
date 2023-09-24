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

  localparam [7:0] REQ_CURRENT_STATE     = 8'h00,
                   REQ_TEMP              = 8'h01,
                   REQ_HUMI              = 8'h02,
                   ACT_MONIT_TEMP        = 8'h03,
                   ACT_MONIT_HUMI        = 8'h04,
                   DEACT_MONIT_TEMP      = 8'h05,
                   DEACT_MONIT_HUMI      = 8'h06;

  localparam [7:0] RESP_CURRENT_STATE    = 8'h10,
                   DEVICE_ERROR          = 8'hDE,
                   DEVICE_FUNCTIONING    = 8'hDF,
                   RESP_TEMP             = 8'h11,
                   RESP_HUMI             = 8'h12,
                   CONF_DEACT_MONIT_TEMP = 8'h15,
                   CONF_DEACT_MONIT_HUMI = 8'h16,
                   CONFIRM_ACTION        = 8'hCA,
                   INVALID_ACTION        = 8'hEA,
                   UNKNOWN_COMMAND       = 8'hEC,
                   UNKNOWN_DEVICE        = 8'hED;

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

  assign data_valid = (checksum == hum_int + hum_float + temp_int + temp_int) ? 1'b1 : 1'b0;

  localparam [2:0] IDLE = 3'b000, READ = 3'b001, LOOP = 3'b010, FINISH = 3'b011, STOP = 3'b100;

  reg [2:0] current_state = IDLE;

  localparam TEMP = 1'b1, HUM = 1'b0;

  reg selected_measure;

  always @(posedge clock) begin
    case (current_state)
      IDLE: begin
        if (enable == 1'b0) begin
          finished <= 1'b0;
          enable_sensor <= 1'b0;
          current_state <= IDLE;
        end else begin
          finished <= 1'b0;
          enable_sensor <= 1'b1;
          current_state <= READ;
        end
      end
      READ: begin
        if (done == 1'b0) begin
          current_state <= READ;
        end else begin
          case (request)
            REQ_CURRENT_STATE: begin
              if (done == 1'b1 && data_valid == 1'b1 && error == 1'b0) begin
                response_code <= RESP_CURRENT_STATE;
                response <= DEVICE_FUNCTIONING;
                current_state <= FINISH;
              end else begin
                response_code <= RESP_CURRENT_STATE;
                response <= DEVICE_ERROR;
                current_state <= FINISH;
              end
            end
            REQ_TEMP: begin
              response_code <= RESP_TEMP;
              response <= temp_int;
              current_state <= FINISH;
            end
            REQ_HUMI: begin
              response_code <= RESP_HUMI;
              response <= hum_int;
              current_state <= FINISH;
            end
            ACT_MONIT_TEMP: begin
              selected_measure <= TEMP;
              current_state <= LOOP;
            end
            ACT_MONIT_HUMI: begin
              selected_measure <= HUM;
              current_state <= LOOP;
            end
            DEACT_MONIT_TEMP: begin
              response_code <= CONF_DEACT_MONIT_TEMP;
              response <= INVALID_ACTION;
              current_state <= FINISH;
            end
            DEACT_MONIT_HUMI: begin
              response_code <= CONF_DEACT_MONIT_HUMI;
              response <= INVALID_ACTION;
              current_state <= FINISH;
            end
            default: begin
              response_code <= UNKNOWN_COMMAND;
              response <= UNKNOWN_COMMAND;
              current_state <= FINISH;
            end
          endcase
        end
      end
      FINISH: begin
        finished <= 1'b1;
        current_state <= STOP;
      end
      STOP: begin
        enable_sensor <= 1'b0;
        current_state <= IDLE;
      end
      LOOP: begin
        if (request == DEACT_MONIT_TEMP || request == DEACT_MONIT_HUMI) begin
          if (request == DEACT_MONIT_TEMP) begin
            response_code <= CONF_DEACT_MONIT_TEMP;
            response <= CONFIRM_ACTION;
          end else begin
            response_code <= CONF_DEACT_MONIT_HUMI;
            response <= CONFIRM_ACTION;
          end
          counter <= 27'd0;
          current_state <= FINISH;
        end else begin
          if (counter >= 27'd100000000) begin
            enable_sensor <= 1'b1;
            if (done == 1'b1) begin
              case (selected_measure)
                TEMP: begin
                  response_code <= RESP_TEMP;
                  response <= temp_int;
                  counter <= 27'd0;
                end
                HUM: begin
                  response_code <= RESP_HUMI;
                  response <= hum_int;
                  counter <= 27'd0;
                end
                default: response <= 8'hFF;
              endcase
            end
          end else begin
            counter <= counter + 27'd1;
            current_state <= LOOP;
            enable_sensor = 1'b0;
          end
        end
      end
      default: begin
        current_state <= IDLE;
      end
    endcase
  end

endmodule
