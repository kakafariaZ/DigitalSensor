`timescale 1ns / 1ps

module BinaryToDisplayTB;
  parameter CLOCK_PERIOD = 20;

  reg clock;
  reg [3:0] binary_number;
  wire segment_a, segment_b, segment_c, segment_d, segment_e, segment_f, segment_g;

  BinaryToDisplay UUT (
      .clock(clock),
      .binary_number(binary_number),
      .segment_a(segment_a),
      .segment_b(segment_b),
      .segment_c(segment_c),
      .segment_d(segment_d),
      .segment_e(segment_e),
      .segment_f(segment_f),
      .segment_g(segment_g)
  );

  always begin
    clock = ~clock;
    #(CLOCK_PERIOD / 2);
  end

  initial begin
    clock = 0;

    binary_number = 4'b0000;  // 0x00 - 7b'1111110
    #(CLOCK_PERIOD);
    binary_number = 4'b0101;  // 0x05 - 7b'1011011
    #(CLOCK_PERIOD);
    binary_number = 4'b1100;  // 0x0C - 7b'1001110
    #(CLOCK_PERIOD);
    binary_number = 4'b1011;  // 0x0B - 7b'0011111
    #(CLOCK_PERIOD);
    binary_number = 4'b1111;  // 0x0F - 7b'1001111
    #(CLOCK_PERIOD);

    $stop;
  end

  always @(posedge clock) begin
    #(CLOCK_PERIOD / 4);
    $display("Binary Number: %b, 7-Segment Display: %h %h %h %h %h %h %h", binary_number,
             segment_a, segment_b, segment_c, segment_d, segment_e, segment_f, segment_g);
  end

endmodule

