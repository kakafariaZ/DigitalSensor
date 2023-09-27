/**
* This module implements a parameterized frequency divider, i.e. a clock divider.
*
* Parameters:
*   - `COUNTER_MAX`: The amount, **divided by 2**, of times the clock should be divided.
*     e.g.: To bring a 50MHz clock down to 1MHz, `COUNTER_MAX` should be 25.
*
*   - `COUNTER_SIZE`: The size of the `counter` inside the module. MUST be big enough
*      to represent `COUNTER_MAX`.
*     e.g.: For `counter` to reach 50 it must have, at least, 6 bits.
*/

module ClockDivider #(
    parameter COUNTER_MAX  = 6'd25,
    parameter COUNTER_SIZE = 6
) (
    input clock,
    output reg divided_clock
);

  reg [COUNTER_SIZE - 1:0] counter;

  initial begin
    counter = 0;
    divided_clock = 1'b0;
  end

  always @(posedge clock) begin
    if (counter == (COUNTER_MAX - 1)) begin
      counter <= 6'd0;
      divided_clock  <= ~divided_clock;
    end else begin
      counter <= counter + 1'b1;
      divided_clock = divided_clock;
    end
  end

endmodule
