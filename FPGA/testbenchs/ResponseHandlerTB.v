`timescale 1ns / 10ps

module ResponseHandlerTB ();
  parameter CLOCK_PERIOD = 20;

  reg clock = 1'b0;
  reg enable = 1'b0;
  reg [7:0] response_code = 7'd0;
  reg [7:0] response_data = 7'd0;

  wire has_response;
  wire [7:0] response;
  wire [1:0] debug_state;

  ResponseHandler ResponseHandlerUUT (
      .clock(clock),
      .enable(enable),
      .response_code(response_code),
      .response_data(response_data),
      .has_response(has_response),
      .response(response),
      .debug_state(debug_state)
  );

  always begin
    #(CLOCK_PERIOD / 2) clock <= !clock;
  end

  initial begin
    @(posedge clock);
    enable = 1'b1;
    response_code = 8'h11;

    @(posedge clock);
    response_data = 8'h20;

    #(CLOCK_PERIOD * 5);

    @(posedge clock);
    enable = 1'b0;

    $stop;
  end
endmodule
