`timescale 1ns / 1ps

module ClockDividerTB;
  parameter CLOCK_PERIOD = 20;

  reg clock;
  reg reset;

  wire div_clock;

  ClockDivider #(.COUNTER_MAX(3'b100), .COUNTER_SIZE(3)) UUT (
    .clock(clock),
    .reset(reset),
    .div_clock(div_clock)
  );

  always begin
    clock = ~clock;
    #((CLOCK_PERIOD / 2));
  end

  initial begin
    clock = 0;
    reset = 0;
    reset = 1;
    #((CLOCK_PERIOD * 5) / 2) reset = 0;
    #((CLOCK_PERIOD * 100) / 2) $stop;
  end

  always @(posedge div_clock) begin
    $display("Divided Clock = %b", div_clock);
  end

  always @(posedge clock) begin
    $display("Clock = %b", clock);
  end

endmodule

