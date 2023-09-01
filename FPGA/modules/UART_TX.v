/**
* This module contains the UART Transmitter. This transmitter is able to transmit 8 bits of serial
* data, one start bit, one stop bit, and no parity bit. When the transmition is completed
* `transmission_done` will be driven high for one clock cycle.
*
* Parameters:
*   - `CLOCKS_PER_BIT` = (Frequency of Clock) / (Frequency of UART)
*     e.g.: 10 MHz Clock and 115,200 Baud UART
*     (10,000,000) / (115,200) = 87 CLOCKS_PER_BIT
*
* Source: https://nandland.com/uart-serial-port-module/
*
* NOTE: Minor modifications were made to the original code to suit the targeted problem and for
* better understanding of the working group.
*/

module UART_TX #(
    parameter CLOCKS_PER_BIT = 87
) (
    input  wire       clock,
    input  wire       has_data,
    input  wire [7:0] data_to_send,
    output reg        sending_bit,
    output reg        is_transmitting,
    output reg        transmission_done
);

  reg [2:0] current_index;
  reg [7:0] counter;
  reg [7:0] buffer;

  localparam [2:0] IDLE = 3'b000,
                   START_BIT = 3'b001,
                   DATA_BITS = 3'b010,
                   STOP_BIT = 3'b011,
                   CLEANUP = 3'b100;

  reg [2:0] current_state = IDLE;

  always @(posedge clock) begin
    case (current_state)
      IDLE: begin
        sending_bit <= 1'b1;
        counter <= 7'b0000000;
        current_index <= 3'b000;
        is_transmitting <= 1'b0;
        transmission_done <= 1'b0;

        if (has_data == 1'b1) begin
          is_transmitting <= 1'b1;
          buffer <= data_to_send;
          current_state <= START_BIT;
        end else begin
          current_state <= IDLE;
        end
      end

      START_BIT: begin
        sending_bit <= 1'b0;

        if (counter < CLOCKS_PER_BIT - 1) begin
          counter       <= counter + 1'b1;
          current_state <= START_BIT;
        end else begin
          counter <= 7'b0000000;
          current_state <= DATA_BITS;
        end
      end

      DATA_BITS: begin
        sending_bit <= buffer[current_index];

        if (counter < CLOCKS_PER_BIT - 1) begin
          counter       <= counter + 1'b1;
          current_state <= DATA_BITS;
        end else begin
          counter <= 7'b0000000;

          if (current_index != 7) begin
            current_index <= current_index + 1'b1;
            current_state <= DATA_BITS;
          end else begin
            current_index <= 3'b000;
            current_state <= STOP_BIT;
          end
        end
      end

      STOP_BIT: begin
        sending_bit <= 1'b1;

        if (counter < CLOCKS_PER_BIT - 1) begin
          counter       <= counter + 1'b1;
          current_state <= STOP_BIT;
        end else begin
          counter           <= 7'b0000000;
          is_transmitting   <= 1'b0;
          transmission_done <= 1'b1;
          current_state     <= CLEANUP;
        end
      end

      CLEANUP: begin
        transmission_done <= 1'b1;
        current_state <= IDLE;
      end

      default: begin
        current_state <= IDLE;
      end
    endcase
  end

endmodule
