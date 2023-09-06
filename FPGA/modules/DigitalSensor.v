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
*   - `RequestHandler`: Handles the data decoded by the `SensorDecoder` module to properly send
*   it back to the 'Client', by handing it to the `UART_TX` module.
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
  wire has_data_rx;

  UART_RX RX0 (
      .clock(clock),
      .incoming_bit(incoming_bit),
      .has_data(has_data_rx),
      .data_received(data_received)
  );

  wire has_request;
  wire [7:0] received_data;
  wire device_selected;
  wire [7:0] request;
  wire [31:0] device_selector;

  assign has_request   = has_data_rx;
  assign received_data = data_received;

  RequestHandler REQ0 (
      .clock(clock),
      .has_request(has_request),
      .received_data(received_data),
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

  wire has_response;
  wire [7:0] request_code;
  wire [7:0] data_to_send_rh;
  wire response_ready;
  wire [7:0] response;

  assign has_response = finished;
  assign request_code = request;
  assign data_to_send_rh = requested_data;

  ResponseHandler RESH0 (
      .clock(clock),
      .has_response(has_response),
      .request_code(request_code),
      .data_to_send(data_to_send_rh),
      .response_ready(response_ready),
      .response(response)
  );

  wire has_data_tx;
  wire [7:0] data_to_send_tx;

  assign has_data_tx = response_ready;
  assign data_to_send_tx = response;

  UART_TX TX0 (
      .clock(clock),
      .has_data(has_data_tx),
      .data_to_send(data_to_send_tx),
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
