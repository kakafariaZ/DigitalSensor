/**
* This is the main module of the project.
*/

module DigitalSensor (
    input  wire clock,
    input  wire reset,
    input  wire has_data_tx,
    output wire is_transmitting,
    output wire transmission_done,
    output wire has_data_rx
);

  localparam DATA_TO_SEND = 16'h0x4F;

  wire div_clock;
  wire sending_bit;
  wire incoming_bit;

  wire [7:0] data_received;

  ClockDivider CD0 (
      .clock(clock),
      .reset(reset),
      .div_clock(div_clock)
  );

  UART_TX TX0 (
      .clock(div_clock),
      .has_data(has_data_tx),
      .data_to_send(DATA_TO_SEND),
      .sending_bit(sending_bit),
      .is_transmitting(is_transmitting),
      .transmission_done(transmission_done)
  );

  UART_RX RX0 (
      .clock(div_clock),
      .incoming_bit(incoming_bit),
      .has_data(has_data_rx),
      .data_received(data_received)
  );

  assign incoming_bit = sending_bit;

endmodule
