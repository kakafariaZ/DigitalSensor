/**
* This is the main module of the `DigitalSensor` project. Here the inputs are properly handled to
* their respective sub modules, which are also connected internally by wires and buses. This design
* was chosen to make the system more concise and modular.
*
* Brief description of the roles of each sub module:
*   - `UART_RX`: Handles the reception of data coming from the 'Client' via the UART protocol.
*
*   - `RequestHandler`: Handles the storage and part of the decoding of the data received by
*   the `UART_RX`.
*
*   - `SensorDecoder`: Act as a 'Facade' for the sub modules for the available sensors, decoding
*   the other part of the data coming from the `RequestHandler` to return the proper information.
*
*   - `UART_TX`: Sends the information produced by the other sub modules back to the 'Client' via
*   the UART protocol.
*
* NOTE: Some of the modules and outputs are commented out, as they were only used during the
* testing of the prototype, although they may be used on the next phases of development.
*/

module DigitalSensor (
    input  wire clock,
    input  wire incoming_bit,
    inout  wire transmission_line,
    output wire sending_bit,
    output wire is_transmitting,
    output wire transmission_done
    // output wire [6:0] first_digit,
    // output wire [6:0] second_digit
);

  wire [7:0] data_received;
  wire has_data;

  UART_RX RX0 (
      .clock(clock),
      .incoming_bit(incoming_bit),
      .has_data(has_data),
      .data_received(data_received)
  );

  wire [31:0] device_selector;
  wire [7:0] request;
  wire device_selected;

  RequestHandler RH0 (
      .clock(clock),
      .has_request(has_data),
      .received_data(data_received),
      .device_selected(device_selected),
      .request(request),
      .device_selector(device_selector)
  );

  wire [7:0] requested_data;
  wire       finished;
  wire       enable;

  assign enable = device_selected;

  SensorDecoder SD0 (
      .clock(clock),
      .enable(enable),
      .device_selector(device_selector),
      .transmission_line(transmission_line),
      .request(request),
      .requested_data(requested_data),
      .finished(finished)
  );

  UART_TX TX0 (
      .clock(clock),
      .has_data(finished),
      .data_to_send(requested_data),
      .sending_bit(sending_bit),
      .is_transmitting(is_transmitting),
      .transmission_done(transmission_done)
  );

  // BinaryToDisplay BD0 (
  //     .clock(clock),
  //     .binary_number(data_received[3:0]),
  //     .segment_a(first_digit[6]),
  //     .segment_b(first_digit[5]),
  //     .segment_c(first_digit[4]),
  //     .segment_d(first_digit[3]),
  //     .segment_e(first_digit[2]),
  //     .segment_f(first_digit[1]),
  //     .segment_g(first_digit[0])
  // );

  // BinaryToDisplay BD1 (
  //     .clock(clock),
  //     .binary_number(data_received[7:4]),
  //     .segment_a(second_digit[6]),
  //     .segment_b(second_digit[5]),
  //     .segment_c(second_digit[4]),
  //     .segment_d(second_digit[3]),
  //     .segment_e(second_digit[2]),
  //     .segment_f(second_digit[1]),
  //     .segment_g(second_digit[0])
  // );

endmodule
