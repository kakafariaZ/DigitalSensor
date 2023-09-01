/**
* This module implements a decoder for handling communication with the DHT11 sensor.
*
* Source: https://www.youtube.com/watch?v=BkTYD7kujTk&list=PLZ8dBTV2_5HT0Gm24XcJcx43YMWRbDlxW&index=11&pp=iAQB
*
* NOTE: Minor modifications were made to the original code to suit the targeted problem and for
* better understanding of the working group.
*/

module SensorDecoder (
    input wire clock,
    input wire enable,
    input wire reset,
    inout wire transmission_line,
    output wire [7:0] hum_int,
    output wire [7:0] hum_float,
    output wire [7:0] temp_int,
    output wire [7:0] temp_float,
    output wire [7:0] checksum,
    output reg hold,
    output reg debug,
    output reg error
);

  reg [39:0] sensor_data;
  reg [25:0] counter;
  reg [ 5:0] index;

  reg sensor_in, sensor_out, direction;

  TriState TS0 (
      .port(transmission_line),
      .dir (direction),
      .send(sensor_in),
      .read(sensor_out)
  );

  assign hum_int[0] = sensor_data[0];
  assign hum_int[1] = sensor_data[1];
  assign hum_int[2] = sensor_data[2];
  assign hum_int[3] = sensor_data[3];
  assign hum_int[4] = sensor_data[4];
  assign hum_int[5] = sensor_data[5];
  assign hum_int[6] = sensor_data[6];
  assign hum_int[7] = sensor_data[7];

  assign hum_float[0] = sensor_data[8];
  assign hum_float[1] = sensor_data[9];
  assign hum_float[2] = sensor_data[10];
  assign hum_float[3] = sensor_data[11];
  assign hum_float[4] = sensor_data[12];
  assign hum_float[5] = sensor_data[13];
  assign hum_float[6] = sensor_data[14];
  assign hum_float[7] = sensor_data[15];

  assign temp_int[0] = sensor_data[16];
  assign temp_int[1] = sensor_data[17];
  assign temp_int[2] = sensor_data[18];
  assign temp_int[3] = sensor_data[19];
  assign temp_int[4] = sensor_data[20];
  assign temp_int[5] = sensor_data[21];
  assign temp_int[6] = sensor_data[22];
  assign temp_int[7] = sensor_data[23];

  assign temp_float[0] = sensor_data[24];
  assign temp_float[1] = sensor_data[25];
  assign temp_float[2] = sensor_data[26];
  assign temp_float[3] = sensor_data[27];
  assign temp_float[4] = sensor_data[28];
  assign temp_float[5] = sensor_data[29];
  assign temp_float[6] = sensor_data[30];
  assign temp_float[7] = sensor_data[31];

  assign checksum[0] = sensor_data[32];
  assign checksum[1] = sensor_data[33];
  assign checksum[2] = sensor_data[34];
  assign checksum[3] = sensor_data[35];
  assign checksum[4] = sensor_data[36];
  assign checksum[5] = sensor_data[37];
  assign checksum[6] = sensor_data[38];
  assign checksum[7] = sensor_data[39];

  localparam S0 = 4'b0001, S1 = 4'b0010, S2 = 4'b0011,
             S3 = 4'b0100, S4 = 4'b0101, S5 = 4'b0110,
             S6 = 4'b0111, S7 = 4'b1000, S8 = 4'b1001,
             S9 = 4'b1010, START = 4'b1011, STOP = 4'b0000;

  reg [3:0] current_state = STOP;

  always @(posedge clock) begin
    if (enable == 1'b1) begin
      if (reset == 1'b1) begin
        hold <= 1'b0;
        error <= 1'b0;
        direction <= 1'b1;
        sensor_out <= 1'b1;
        counter <= 26'b00000000000000000000000000;
        sensor_data <= 40'b0000000000000000000000000000000000000000;
        current_state <= START;
      end else begin
        case (current_state)
          START: begin
            hold <= 1'b1;
            direction <= 1'b1;
            sensor_out <= 1'b1;
            current_state <= S0;
          end

          S0: begin
            hold <= 1'b1;
            error <= 1'b0;
            direction <= 1'b1;
            sensor_out <= 1'b1;

            if (counter < 1_800_000) begin
              counter <= counter + 1'b1;
            end else begin
              current_state <= S1;
              counter <= 26'b00000000000000000000000000;
            end
          end

          S1: begin
            hold <= 1'b1;
            sensor_out <= 1'b0;

            if (counter < 1_800_000) begin
              counter <= counter + 1'b1;
            end else begin
              current_state <= S2;
              counter <= 26'b00000000000000000000000000;
            end
          end

          S2: begin
            sensor_out <= 1'b1;

            if (counter < 2_000) begin
              counter <= counter + 1'b1;
            end else begin
              current_state <= S3;
              direction <= 1'b0;
            end
          end

          S3: begin
            if (counter < 6_000 && sensor_in == 1'b1) begin
              current_state <= S3;
              counter <= counter + 1'b1;
            end else begin
              if (sensor_in == 1'b1) begin
                current_state <= STOP;
                error <= 1'b1;
                counter <= 26'b00000000000000000000000000;
              end else begin
                current_state <= S4;
                counter <= 26'b00000000000000000000000000;
              end
            end
          end

          S4: begin
            if (sensor_in == 1'b0 && counter < 8800) begin
              current_state <= S4;
              counter <= counter + 1'b1;
            end else begin
              if (sensor_in == 1'b0) begin
                current_state <= STOP;
                error <= 1'b1;
                counter <= 26'b00000000000000000000000000;
              end else begin
                current_state <= S5;
                counter <= 26'b00000000000000000000000000;
              end
            end
          end

          S5: begin
            if (sensor_in == 1'b1 && counter < 8800) begin
              current_state <= S5;
              counter <= counter + 1'b1;
            end else begin
              if (sensor_in == 1'b1) begin
                current_state <= STOP;
                error <= 1'b1;
                counter <= 26'b00000000000000000000000000;
              end else begin
                current_state <= S6;
                error <= 1'b1;
                index <= 6'b000000;
                counter <= 26'b00000000000000000000000000;
              end
            end
          end

          S6: begin
            if (sensor_in == 1'b0) begin
              current_state <= S7;
            end else begin
              current_state <= STOP;
              error <= 1'b1;
              counter <= 26'b00000000000000000000000000;
            end
          end

          S7: begin
            if (sensor_in == 1'b1) begin
              current_state <= S8;
              counter <= 26'b00000000000000000000000000;
            end else begin
              if (counter < 3200000) begin
                current_state <= S7;
                counter <= counter + 1'b1;
              end else begin
                current_state <= STOP;
                error <= 1'b1;
                counter <= 26'b00000000000000000000000000;
              end
            end
          end

          S8: begin
            if (sensor_in == 1'b0) begin
              if (counter > 5000) begin
                debug <= 1'b1;
                sensor_data[index] <= 1'b1;
              end else begin
                debug <= 1'b0;
                sensor_data[index] <= 1'b0;
              end

              if (index < 39) begin
                current_state <= S9;
                counter <= 26'b00000000000000000000000000;
              end else begin
                current_state <= STOP;
                error <= 1'b0;
              end
            end else begin
              counter <= counter + 1'b1;

              if (counter == 3200000) begin
                current_state <= STOP;
                error <= 1'b1;
              end
            end
          end

          S9: begin
            current_state <= S6;
            index <= index + 1'b1;
          end

          STOP: begin
            current_state <= STOP;

            if (error == 1'b0) begin
              hold <= 1'b0;
              error <= 1'b0;
              direction <= 1'b1;
              sensor_out <= 1'b1;
              index <= 6'b000000;
              counter <= 26'b00000000000000000000000000;
            end else begin
              if (counter < 3200000) begin
                hold <= 1'b1;
                error <= 1'b1;
                direction <= 1'b0;
                counter <= counter + 1'b1;
                sensor_data <= 40'b0000000000000000000000000000000000000000;
              end else begin
                error <= 1'b0;
              end
            end
          end

          default: begin
          end
        endcase
      end
    end
  end

endmodule
