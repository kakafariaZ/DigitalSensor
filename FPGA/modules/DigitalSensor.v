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
*/

module DigitalSensor (
    input  wire clock,
    input  wire incoming_bit,
    inout  wire transmission_line,
    output wire sending_bit,
    output wire is_transmitting,
    output wire transmission_done
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
  wire enable_rh;
  wire [7:0] received_data;
  wire device_selected;
  wire [7:0] request;
  wire [31:0] device_selector;

  assign enable_rh = has_data_rx;
  assign received_data = data_received;

  RequestHandler REQ0 (
      .clock(clock),
      .enable(enable_rh),
      .received_data(received_data),
      .has_request(has_request),
      .request(request),
      .device_selected(device_selected),
      .device_selector(device_selector)
  );

  wire [7:0] response;
  wire [7:0] response_code;
  wire       finished;
  wire       enable;

  assign enable = device_selected;

  SensorDecoder SD0 (
      .clock(clock),
      .enable(enable),
      .device_selector(device_selector),
      .transmission_line(transmission_line),
      .request(request),
      .response(response),
      .response_code(response_code),
      .finished(finished)
  );

  wire has_response;
  wire [7:0] data_to_send_rh;
  wire response_ready;
  wire [7:0] response_rh;

  assign has_response = finished;
  assign data_to_send_rh = response;

  ResponseHandler RESH0 (
      .clock(clock),
      .has_response(has_response),
      .data_to_send(data_to_send_rh),
      .response_code(response_code),
      .response_ready(response_ready),
      .response(response_rh)
  );

  wire has_data_tx;
  wire [7:0] data_to_send_tx;

  assign has_data_tx = response_ready;
  assign data_to_send_tx = response_rh;

  UART_TX TX0 (
      .clock(clock),
      .has_data(has_data_tx),
      .data_to_send(data_to_send_tx),
      .sending_bit(sending_bit),
      .is_transmitting(is_transmitting),
      .transmission_done(transmission_done)
  );

endmodule
