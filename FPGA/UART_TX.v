/**
* This file contains the UART Transmitter. This transmitter is able to transmit 8 bits of serial
* data, one start bit, one stop bit, and no parity bit. When transmit is complete o_Tx_done will
* be driven high for one clock cycle.
*
* Set Parameter `CLKS_PER_BIT` as follows:
* CLKS_PER_BIT = (Frequency of i_Clock) / (Frequency of UART)
* Example: 10 MHz Clock and 115,200 Baud UART
* (10,000,000) / (115,200) = 87 CLKS_PER_BIT
*
* Source: https://nandland.com/uart-serial-port-module/
*
* NOTE: Minor modifications were made to the original code for better understanding of the
* working group.
*/

module UART_TX #(
    parameter CLKS_PER_BIT = 87
) (
    input  wire       clock,
    input  wire       has_data,
    input  wire [7:0] data_to_send,
    output wire       is_transmitting,
    output reg        sending_bit,
    output wire       transmission_done
);

  localparam IDLE = 3'b000,
             START_BIT = 3'b001,
             DATA_BITS = 3'b010,
             STOP_BIT = 3'b011,
             CLEANUP = 3'b100;

  reg [2:0] current_state = 0;
  reg [2:0] current_bit = 0;
  reg [7:0] counter = 0;
  reg [7:0] r_data_to_send = 0;
  reg       r_transmission_done = 0;
  reg       r_is_transmitting = 0;

  always @(posedge clock) begin
    case (current_state)
      IDLE: begin
        counter <= 0;
        current_bit <= 0;
        sending_bit <= 1'b1;
        r_transmission_done <= 1'b0;

        if (has_data == 1'b1) begin
          r_is_transmitting <= 1'b1;
          r_data_to_send <= data_to_send;
          current_state <= START_BIT;
        end else begin
          current_state <= IDLE;
        end
      end

      START_BIT: begin
        sending_bit <= 1'b0;

        if (counter < CLKS_PER_BIT - 1) begin
          counter       <= counter + 1;
          current_state <= START_BIT;
        end else begin
          counter       <= 0;
          current_state <= DATA_BITS;
        end
      end

      DATA_BITS: begin
        sending_bit <= data_to_send[current_bit];

        if (counter < CLKS_PER_BIT - 1) begin
          counter       <= counter + 1;
          current_state <= DATA_BITS;
        end else begin
          counter <= 0;

          if (current_bit < 7) begin
            current_bit   <= current_bit + 1;
            current_state <= DATA_BITS;
          end else begin
            current_bit   <= 0;
            current_state <= STOP_BIT;
          end
        end
      end

      STOP_BIT: begin
        sending_bit <= 1'b1;

        if (counter < CLKS_PER_BIT - 1) begin
          counter       <= counter + 1;
          current_state <= STOP_BIT;
        end else begin
          r_transmission_done <= 1'b1;
          counter             <= 0;
          current_state       <= CLEANUP;
          r_is_transmitting   <= 1'b0;
        end
      end

      CLEANUP: begin
        r_transmission_done <= 1'b1;
        current_state <= IDLE;
      end

      default: begin
        current_state <= IDLE;
      end
    endcase
  end

  assign is_transmitting   = r_is_transmitting;
  assign transmission_done = r_transmission_done;

endmodule
