module DigitalSensor (
    input  wire clk,
    input  wire reset,
    output wire led
);

  ClockDivider #(
      .COUNTER_MAX (50000000),
      .COUNTER_SIZE(25)
  ) CD0 (
      .clk(clk),
      .reset(reset),
      .div_clk(led)
  );

endmodule
