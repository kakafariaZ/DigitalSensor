/**
* This module contains a clock divider, used to modulate frequencies to appropriate values
* for different use cases.
*
* Parameters:
*   - `COUNTER_MAX`: Defines by how much the clock will be divided.
*   e.g.: COUNTER_MAX = 3'b100 -> Divides the clock 5 times.
*
*   - `COUNTER_SIZE`: Defines the size of the counter register. Must be in accordance with
*   the `COUNTER_MAX`.
*   e.g.: COUNTER_SIZE = 3 -> Counter will be declared as `input wire [2:0]`.
*/
module ClockDivider #(
    parameter COUNTER_MAX  = 3'b100,
    parameter COUNTER_SIZE = 3
) (
    input  wire clk,
    input  wire reset,
    output reg  div_clk
);

  reg [COUNTER_SIZE - 1:0] counter;

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      counter <= 0;
      div_clk <= 0;
    end else if (counter == COUNTER_MAX) begin
      counter <= 0;
      div_clk <= ~div_clk;
    end else begin
      counter <= counter + 1'b1;
      div_clk <= div_clk;
    end
  end

endmodule
