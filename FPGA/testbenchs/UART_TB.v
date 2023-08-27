/**
* This testbench will exercise both the `UART_RX` and `UART_TX` modules. It sends out a byte and
* ensures the RX receives it correctly.
*
* Source: http://www.nandland.com
*
* NOTE: Minor modifications were made to the original code for better understanding of the
* working group.
*/

`timescale 1ns / 10ps

module UART_TB ();
  parameter SAMPLE_DATA = 8'h55;

  // Define clock parameters.
  parameter CLOCK_PERIOD = 100;
  parameter CLOCK_FREQUENCY = 10000000;

  // UART parameters.
  parameter BAUD_RATE = 115200;
  parameter CLOCKS_PER_BIT = (CLOCK_FREQUENCY / BAUD_RATE) + 1;

  reg clock = 0;
  reg has_data_tx = 0;
  reg [7:0] data_to_send = 0;

  wire has_data_rx;
  wire sending_bit;
  wire is_transmitting;
  wire transmission_line;
  wire transmission_done;
  wire [7:0] data_received;

  UART_TX #(
      .CLOCKS_PER_BIT(CLOCKS_PER_BIT)
  ) UART_TX_UUT (
      .clock(clock),
      .has_data(has_data_tx),
      .data_to_send(data_to_send),
      .sending_bit(sending_bit),
      .is_transmitting(is_transmitting),
      .transmission_done(transmission_done)
  );

  UART_RX #(
      .CLOCKS_PER_BIT(CLOCKS_PER_BIT)
  ) UART_RX_UUT (
      .clock(clock),
      .incoming_bit(transmission_line),
      .has_data(has_data_rx),
      .data_received(data_received)
  );

  assign transmission_line = is_transmitting ? sending_bit : 1'b1;

  always begin
    #(CLOCK_PERIOD / 2) clock = ~clock;
  end

  initial begin
    @(posedge clock);
    has_data_tx <= 1'b1;

    @(posedge clock);
    data_to_send <= SAMPLE_DATA;

    @(posedge clock);
    has_data_tx <= 1'b0;

    @(posedge has_data_rx);
    if (data_received == SAMPLE_DATA) begin
      $display("Test Passed - Correct Byte Received - 0x%h", data_received);
    end else begin
      $display("Test Failed - Incorrect Byte Received - 0x%h", data_received);
    end

    $stop();
  end

endmodule
