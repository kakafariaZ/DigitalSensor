module ClockDivider #(
    parameter COUNTER_MAX  = 26'b10111110101111000010000000,
    parameter COUNTER_SIZE = 26
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
