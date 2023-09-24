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
  parameter SAMPLE_DATA = 8'hCD;

  // Define clock parameters.
  parameter CLOCK_PERIOD = 20;
  parameter CLOCK_FREQUENCY = 50000000;

  // UART parameters.
  parameter BAUD_RATE = 115200;
  parameter CLOCKS_PER_BIT = (CLOCK_FREQUENCY / BAUD_RATE) + 1;

  reg clock = 1'b0;
  reg has_data_tx = 1'b0;
  reg [7:0] data_to_send = 7'd0;

  wire has_data_rx;
  wire sending_bit;
  wire is_transmitting;
  wire transmission_line;
  wire transmission_done;
  wire [2:0] debug_state_tx, debug_state_rx;
  wire [7:0] data_received;

  UART_TX #(
      .CLOCKS_PER_BIT(CLOCKS_PER_BIT)
  ) UART_TX_UUT (
      .clock(clock),
      .has_data(has_data_tx),
      .data_to_send(data_to_send),
      .sending_bit(sending_bit),
      .is_transmitting(is_transmitting),
      .transmission_done(transmission_done),
      .debug_state(debug_state_tx)
  );

  UART_RX #(
      .CLOCKS_PER_BIT(CLOCKS_PER_BIT)
  ) UART_RX_UUT (
      .clock(clock),
      .incoming_bit(transmission_line),
      .has_data(has_data_rx),
      .data_received(data_received),
      .debug_state(debug_state_rx)
  );

  assign transmission_line = is_transmitting ? sending_bit : 1'b1;

  always begin
    #(CLOCK_PERIOD / 2) clock <= !clock;
  end

  initial begin
    @(posedge clock);
    @(posedge clock);
    has_data_tx  <= 1'b1;
    data_to_send <= SAMPLE_DATA;

    @(posedge clock);
    has_data_tx <= 1'b0;

    @(posedge transmission_done);
    if (data_received == SAMPLE_DATA) begin
      $display("Test Passed - Correct Byte Received - 0x%H", data_received);
    end else begin
      $display("Test Failed - Incorrect Byte Received - 0x%H", data_received);
    end

    #(CLOCK_PERIOD * 10);

    $stop();
  end

endmodule

