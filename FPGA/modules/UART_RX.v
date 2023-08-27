/**
* This module contains the UART Receiver. This receiver is able to receive 8 bits of serial data,
* one start bit, one stop bit, and no parity bit. When reception is completed `has_data` will be
* driven high for one clock cycle.
*
* Parameters:
*   - `CLOCKS_PER_BIT` = (Frequency of Clock) / (Frequency of UART)
*     e.g.: 10 MHz Clock and 115,200 Baud UART
*     (10,000,000) / (115,200) = 87 CLOCKS_PER_BIT
*
* Source: https://nandland.com/uart-serial-port-module/
*
* NOTE: Minor modifications were made to the original code for better understanding of the
* working group.
*/

module UART_RX #(
    parameter CLOCKS_PER_BIT = 87
) (
    input        clock,
    input        incoming_bit,
    output       has_data,
    output [7:0] data_received
);

  localparam IDLE = 3'b000,
             START_BIT = 3'b001,
             DATA_BITS = 3'b010,
             STOP_BIT = 3'b011,
             CLEANUP = 3'b100;

  reg       current_bit_buffer = 1'b1;
  reg       current_bit = 1'b1;

  reg [2:0] current_state = IDLE;
  reg [2:0] current_index = 0;
  reg [7:0] counter = 0;
  reg [7:0] r_data_received = 0;
  reg       r_has_data = 0;

  always @(posedge clock) begin
    current_bit_buffer <= incoming_bit;
    current_bit <= current_bit_buffer;
  end

  always @(posedge clock) begin
    case (current_state)
      IDLE: begin
        counter <= 0;
        r_has_data <= 1'b0;
        current_index <= 0;

        if (current_bit == 1'b0) begin
          current_state <= START_BIT;
        end else begin
          current_state <= IDLE;
        end
      end

      START_BIT: begin
        if (counter == (CLOCKS_PER_BIT - 1) / 2) begin
          if (current_bit == 1'b0) begin
            counter <= 0;
            current_state <= DATA_BITS;
          end else begin
            current_state <= IDLE;
          end
        end else begin
          counter <= counter + 1;
          current_state <= START_BIT;
        end
      end

      DATA_BITS: begin
        if (counter < CLOCKS_PER_BIT - 1) begin
          counter <= counter + 1;
          current_state <= DATA_BITS;
        end else begin
          counter                        <= 0;
          r_data_received[current_index] <= current_bit;

          if (current_index != 7) begin
            current_index <= current_index + 1;
            current_state <= DATA_BITS;
          end else begin
            current_index <= 0;
            current_state <= STOP_BIT;
          end
        end
      end

      STOP_BIT: begin
        if (counter < CLOCKS_PER_BIT - 1) begin
          counter       <= counter + 1;
          current_state <= STOP_BIT;
        end else begin
          counter       <= 0;
          r_has_data    <= 1'b1;
          current_state <= CLEANUP;
        end
      end

      CLEANUP: begin
        r_has_data <= 1'b0;
        current_state <= IDLE;
      end

      default: begin
        current_state <= IDLE;
      end
    endcase
  end

  assign has_data = r_has_data;
  assign data_received = r_data_received;

endmodule
