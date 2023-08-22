/**
* This is the main module of the project.
*/

module DigitalSensor (
    input  wire clock,
    input  wire reset,
    output wire led
);

  ClockDivider CD0 (
      .clock(clock),
      .reset(reset),
      .div_clock(led)
  );

endmodule
