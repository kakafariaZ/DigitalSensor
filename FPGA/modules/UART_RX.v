/**
* This module contains the UART Receiver. This receiver is able to receive 8 bits of serial data,
* one start bit, one stop bit, and no parity bit. When reception is completed `has_data` will be
* driven high for one clock cycle.
*
* Parameters:
*   - `CLOCKS_PER_BIT` = (Frequency of Clock) / (Frequency of UART)
*     e.g.: 10 MHz Clock and 115,200 Baud UART
*     (50,000,000) / (115,200) = 434 `CLOCKS_PER_BIT`
*
* Source: https://nandland.com/uart-serial-port-module/
*
* NOTE: Modifications were made to the original code to suit the targeted problem and for better
* understanding of the working group.
*/

module UART_RX #(
    parameter CLOCKS_PER_BIT = 434
) (
    input  wire       clock,
    input  wire       incoming_bit,
    output reg        has_data,
    output reg  [7:0] data_received,
    output reg  [2:0] debug_state     // Used on simulations to view FSM transitions.
);

  reg [2:0] current_index;
  reg [8:0] counter;

  reg       current_bit_buffer;
  reg       current_bit;

  always @(posedge clock) begin
    current_bit_buffer <= incoming_bit;
    current_bit <= current_bit_buffer;
  end

  localparam [2:0] IDLE = 3'b000,
                   START_BIT = 3'b001,
                   DATA_BITS = 3'b010,
                   STOP_BIT = 3'b011,
                   CLEANUP = 3'b100;

  reg [2:0] current_state = IDLE;

  always @(posedge clock) begin
    debug_state <= current_state;
    case (current_state)
      IDLE: begin
        has_data <= 1'b0;
        counter <= 7'b0000000;
        current_index <= 3'b000;

        if (current_bit == 1'b0) begin
          current_state <= START_BIT;
        end else begin
          current_state <= IDLE;
        end
      end

      START_BIT: begin
        if (counter == (CLOCKS_PER_BIT - 1) / 2) begin
          if (current_bit == 1'b0) begin
            counter <= 7'b0000000;
            current_state <= DATA_BITS;
          end else begin
            current_state <= IDLE;
          end
        end else begin
          counter <= counter + 1'b1;
          current_state <= START_BIT;
        end
      end

      DATA_BITS: begin
        if (counter < CLOCKS_PER_BIT - 1) begin
          counter <= counter + 1'b1;
          current_state <= DATA_BITS;
        end else begin
          counter <= 7'b0000000;
          data_received[current_index] <= current_bit;

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
        if (counter < CLOCKS_PER_BIT - 1) begin
          counter       <= counter + 1'b1;
          current_state <= STOP_BIT;
        end else begin
          counter <= 7'b0000000;
          has_data    <= 1'b1;
          current_state <= CLEANUP;
        end
      end

      CLEANUP: begin
        has_data <= 1'b0;
        current_state <= IDLE;
      end

      default: begin
        current_state <= IDLE;
      end
    endcase
  end

endmodule
