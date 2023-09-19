/**
* This module implements a decoder for handling communication with the DHT11 sensor.
*
* Regarding the `counter` use:
*   * When using a clock 1Mhz every clock cycle takes 1µs, that is 1 x 10⁻3 ms. Supposing we need
*     to wait for 18ms, it would take:
*       - 18 / 1 x 10⁻³ = 900,000 cycles
*   * To know how much time each `counter` is accounting for, just multiply the compared number by
*   the clock period (1 x 10⁻³). The result is the time in milliseconds.
*       - 900,000 * (1 x 10⁻³) = 18ms
*
* Source: https://www.kancloud.cn/dlover/fpga/1637659
*
* NOTE: Modifications were made to the original code to suit the targeted problem and for better
* understanding of the working group.
*/

module DHT11 (
    input  wire        clock,
    input  wire        enable,
    inout  wire        transmission_line,
    output reg  [39:0] sensor_data,
    output reg         error,
    output reg         done
);

  reg [39:0] raw_data;
  reg [15:0] counter;
  reg [ 5:0] received_bits;
  reg [ 3:0] current_state;
  reg bouncer_a, bouncer_b, enable_sensor;
  reg direction, sensor_in;

  wire sensor_out;
  wire divided_clock;

  localparam  IDLE            = 0,
              START_BIT       = 1,
              SEND_HIGH_20US  = 2,
              WAIT_LOW        = 3,
              WAIT_HIGH       = 4,
              END_SYNC        = 5,
              WAIT_BIT        = 6,
              READ_DATA       = 7,
              COLECT_DATA     = 8,
              FINISH          = 9;

  TriState TS0 (
      .port(transmission_line),
      .dir (direction),
      .send(sensor_in),
      .read(sensor_out)
  );

  ClockDivider CD0 (
      .clock(clock),
      .divided_clock(divided_clock)
  );

  /**
  * This block is used to delay the signal of `enable` to ensure the
  * value captured is valid and stable.
  */
  always @(posedge divided_clock, negedge enable) begin
    if (enable == 1'b0) begin
      bouncer_a <= 1'b0;
      bouncer_b <= 1'b0;
      enable_sensor <= 1'b0;
    end else begin
      bouncer_a <= enable;
      bouncer_b <= bouncer_a;
      enable_sensor <= bouncer_a & (~bouncer_b);
    end
  end

  always @(posedge divided_clock, negedge enable) begin
    if (enable == 1'b0) begin
      direction <= 1'b1;
      current_state <= IDLE;
      sensor_in <= 1'b1;
      raw_data <= 40'd0;
      sensor_data <= 40'd0;
      counter <= 16'd0;
      received_bits <= 6'd0;
      error <= 0;
      done <= 1'b0;
    end else begin
      case (current_state)
        IDLE: begin
          if (enable_sensor == 1'b1 && sensor_out == 1'b1) begin
            current_state <= START_BIT;
            direction <= 1'b0;
            sensor_in <= 1'b0;
            counter <= 16'd0;
            received_bits <= 6'd0;
          end else begin
            direction <= 1'b1;
            sensor_in <= 1'b1;
            counter   <= 16'd0;
          end
        end

        START_BIT: begin
          if (counter >= 16'd19000) begin
            current_state <= SEND_HIGH_20US;
            sensor_in <= 1'b1;
            counter <= 16'd0;
          end else begin
            counter <= counter + 1'b1;
          end
        end

        SEND_HIGH_20US: begin
          if (counter >= 16'd20) begin
            counter <= 16'd0;
            direction <= 1'b1;
            current_state <= WAIT_LOW;
          end else begin
            counter <= counter + 1'b1;
          end
        end

        WAIT_LOW: begin
          if (sensor_out == 1'b0) begin
            current_state <= WAIT_HIGH;
            counter <= 16'd0;
          end else begin
            counter <= counter + 1'b1;
            if (counter >= 16'd65500) begin
              current_state <= FINISH;
              error <= 1'b1;
              counter <= 16'd0;
              direction <= 1'b1;
            end
          end
        end

        WAIT_HIGH: begin
          if (sensor_out == 1'b1) begin
            current_state <= END_SYNC;
            counter <= 16'd0;
            received_bits <= 6'd0;
          end else begin
            counter <= counter + 1'b1;
            if (counter >= 16'd65500) begin
              current_state <= FINISH;
              error <= 1'b1;
              counter <= 16'd0;
              direction <= 1'b1;
            end

          end

        end

        END_SYNC: begin
          if (sensor_out == 1'b0) begin
            current_state <= WAIT_BIT;
            counter <= counter + 1'b1;
          end else begin
            counter <= counter + 1'b1;
            if (counter >= 16'd65500) begin
              current_state <= FINISH;
              error <= 1'b1;
              counter <= 16'd0;
              direction <= 1'b1;
            end
          end
        end

        WAIT_BIT: begin
          if (sensor_out == 1'b1) begin
            current_state <= READ_DATA;
            counter <= 16'd0;
          end else begin
            counter <= counter + 1'b1;
            if (counter >= 16'd65500) begin
              current_state <= FINISH;
              error <= 1'b1;
              counter <= 16'd0;
              direction <= 1'b1;
            end
          end
        end

        READ_DATA: begin
          if (sensor_out == 1'b0) begin
            received_bits <= received_bits + 1'b1;
            current_state <= (received_bits >= 6'd39) ? COLECT_DATA : WAIT_BIT;
            counter <= 16'd0;
            if (counter >= 16'd60) begin
              raw_data <= {raw_data[39:0], 1'b1};
            end else begin
              raw_data <= {raw_data[39:0], 1'b0};
            end
          end else begin
            counter <= counter + 1'b1;
            if (counter >= 16'd65500) begin
              current_state <= FINISH;
              error <= 1'b1;
              counter <= 16'd0;
              direction <= 1'b1;
            end
          end
        end

        COLECT_DATA: begin
          sensor_data <= raw_data;
          if (sensor_out == 1'b1) begin
            current_state <= FINISH;
            counter <= 16'd0;
          end else begin
            counter <= counter + 1'b1;
            if (counter >= 16'd65500) begin
              current_state <= IDLE;
              counter <= 16'd0;
              direction <= 1'b1;
            end
          end
        end

        FINISH: begin
          if (error == 1'b1) begin
            current_state <= FINISH;
            counter <= counter + 1'b1;
            if (counter >= 16'd65500) begin
              current_state <= IDLE;
              counter <= 16'd0;
              direction <= 1'b1;
              done <= 1'b1;
            end
          end else begin
            done <= 1'b1;
            current_state <= IDLE;
            counter <= 16'd0;
          end
        end

        default: begin
          current_state <= IDLE;
          counter <= 16'd0;
        end

      endcase
    end
  end
endmodule
