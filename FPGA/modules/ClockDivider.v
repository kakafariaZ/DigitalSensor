/**
* This module implements a parameterized frequency divider, i.e. a clock divider.
*
* Parameters:
*   - `COUNTER_MAX`: The amount of times the clock will be divided.
*     e.g.: To bring a 50MHz clock down to 1MHz, `COUNTER_MAX` should be 50.
*
*   - `COUNTER_SIZE`: The size of the `counter` inside the module. MUST be big enough
*      to represent `COUNTER_MAX`.
*     e.g.: For `counter` to reach 50 it must have, at least, 6 bits.
*/

module ClockDivider #(
    parameter COUNTER_MAX  = 6'd50,
    parameter COUNTER_SIZE = 6
) (
    input clock,
    output reg divided_clock
);

  reg [COUNTER_SIZE - 1:0] counter;

  always @(posedge clock) begin
    if (counter < COUNTER_MAX) begin
      counter <= counter + 1'b1;
      divided_clock = 1'b0;
    end else begin
      counter <= 6'd0;
      divided_clock  <= ~divided_clock;
    end
  end

endmodule

