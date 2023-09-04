/**
* This module implements a high level facade for handling responses off up to 32 different sensors.
*
* NOTE: Currently only working with the DHT11 sensor, whose module is found in this project by the
* name of `DHT11.v`.
*/

module SensorDecoder (
    input wire clock,
    input wire enable,
    inout wire transmission_line,  // Entrada e saída do sensor DHT11
    input wire [7:0] request,  // Byte de requisição do dado
    output reg [7:0] requested_data,  // Saida do dado da interface
    output reg finished  // Bit para informar se o processo foi terminado

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
      .enable(enable_sensor),
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
            requested_data <= 8'b10000000;
          end else begin
            case (request)
              // TODO: Complete with the proper encoding.
              default: begin
                requested_data <= 8'b00000000;
              end
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
