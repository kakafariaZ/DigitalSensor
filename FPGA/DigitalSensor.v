/**
* This is the main module of the project.
*/

module DigitalSensor (
    input  wire clk,
    input  wire reset,
    output wire led
);

  ClockDivider CD0 (
      .clk(clk),
      .reset(reset),
      .div_clk(led)
  );

endmodule
