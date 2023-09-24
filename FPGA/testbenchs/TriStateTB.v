`timescale 1ns / 10ps

module TriStateTB;

  parameter CLOCK_PERIOD = 20;

  reg  clock = 1'b0;
  reg  dir = 1'b0;
  reg  send = 1'b0;
  reg port_drive = 1'bZ;

  wire port;
  wire read;

  assign port = port_drive;

  TriState TriStateUUT (
      .port(port),
      .dir (dir),
      .send(send),
      .read(read)
  );

  always begin
    #(CLOCK_PERIOD / 2) clock <= ~clock;
  end

  initial begin
    // Test 1.0: When `dir` is 1, `port` should reflect the value of `send`.
    dir  = 1'b1;
    #(CLOCK_PERIOD * 2);

    send = 1'b1;
    #(CLOCK_PERIOD * 2);

    send = 1'b0;
    #(CLOCK_PERIOD * 2);

    // Test 2.0: When `dir` is 0, `port` should reflect the value of `read`.
    dir = 1'b0;
    #(CLOCK_PERIOD * 2);

    port_drive = 1'b1;
    #(CLOCK_PERIOD * 2);

    port_drive = 1'b0;
    #(CLOCK_PERIOD * 2);

    $stop;
  end

endmodule
