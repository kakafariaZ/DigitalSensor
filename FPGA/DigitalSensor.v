/**
* This is the main module of the project.
*/

module DigitalSensor (
    input wire clock,
    input wire reset,
    input wire has_data_tx,
    output wire is_transmitting,
    output wire transmission_done,
    output wire has_data_rx,
    output wire [6:0] first_digit,
    output wire [6:0] second_digit
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

  BinaryToDisplay BD0 (
      .clock(div_clock),
      .binary_number(data_received[7:4]),
      .segment_a(first_digit[6]),
      .segment_b(first_digit[5]),
      .segment_c(first_digit[4]),
      .segment_d(first_digit[3]),
      .segment_e(first_digit[2]),
      .segment_f(first_digit[1]),
      .segment_g(first_digit[0])
  );

  BinaryToDisplay BD1 (
      .clock(div_clock),
      .binary_number(data_received[3:0]),
      .segment_a(second_digit[6]),
      .segment_b(second_digit[5]),
      .segment_c(second_digit[4]),
      .segment_d(second_digit[3]),
      .segment_e(second_digit[2]),
      .segment_f(second_digit[1]),
      .segment_g(second_digit[0])
  );

  assign incoming_bit = sending_bit;

endmodule
