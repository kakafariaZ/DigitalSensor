module ClockDividerTB ();

  parameter CLOCK_PERIOD = 20;

  parameter COUNTER_MAX = 6'd25;
  parameter COUNTER_SIZE = 6;

  reg  clock = 1'b0;

  wire divided_clock;

  ClockDivider #(
      .COUNTER_MAX (COUNTER_MAX),
      .COUNTER_SIZE(COUNTER_SIZE)
  ) ClockDividerUUT (
      .clock(clock),
      .divided_clock(divided_clock)
  );

  always begin
    #(CLOCK_PERIOD / 2) clock <= !clock;
  end

  initial begin
    @(posedge divided_clock)
    @(posedge divided_clock)
    @(posedge divided_clock)
    @(posedge divided_clock)
    @(posedge divided_clock)

    $stop;
  end

endmodule
