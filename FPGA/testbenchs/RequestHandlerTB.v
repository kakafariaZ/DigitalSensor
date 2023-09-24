`timescale 1ns / 10ps

module RequestHandlerTB ();

  parameter CLOCK_PERIOD = 20;

  reg clock = 1'b0;
  reg enable = 1'b0;
  reg [7:0] received_data = 8'd0;

  wire device_selected;
  wire has_request;
  wire [7:0] request;
  wire [31:0] device_selector;
  wire [2:0] debug_state;

  RequestHandler RequestHandlerUUT (
      .clock(clock),
      .enable(enable),
      .received_data(received_data),
      .has_request(has_request),
      .request(request),
      .device_selected(device_selected),
      .device_selector(device_selector),
      .debug_state(debug_state)
  );

  always begin
    #(CLOCK_PERIOD / 2) clock <= !clock;
  end

  initial begin
    @(posedge clock);
    enable = 1'b1;
    received_data = 8'hFF;
    // has_request = 1'b0;

    @(posedge clock);
    enable = 1'b1;
    received_data = 8'h20;
    // has_request = 1'b0;

    #(CLOCK_PERIOD * 6);

    @(posedge clock);
    enable = 1'b0;

    $stop;
  end
endmodule
