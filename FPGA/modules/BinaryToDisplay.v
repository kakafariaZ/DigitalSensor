/**
* This module converts a binary number into an output which can get sent to a 7-Segment Display.
* 7-Segment Displays have the ability to display all decimal numbers 0-9 as well as Hex digits A,
* B, C, D, E and F. The input to this module is a 4-bit binary number.
*
* This module will properly drive the individual segments of a 7-Segment LED in order to display
* the digit.
*
* Source: https://nandland.com/uart-serial-port-module/
*
* NOTE: Minor modifications were made to the original code for better understanding of the
* working group.
*/

module BinaryToDisplay (
    input  wire       clock,
    input  wire [3:0] binary_number,
    output wire       segment_a,
    output wire       segment_b,
    output wire       segment_c,
    output wire       segment_d,
    output wire       segment_e,
    output wire       segment_f,
    output wire       segment_g
);

  reg [6:0] segments_encoding = 7'b0000000;

  always @(posedge clock) begin
    case (binary_number)
      4'b0000: segments_encoding <= 7'b1111110;  // 0
      4'b0001: segments_encoding <= 7'b0110000;  // 1
      4'b0010: segments_encoding <= 7'b1101101;  // 2
      4'b0011: segments_encoding <= 7'b1111001;  // 3
      4'b0100: segments_encoding <= 7'b0110011;  // 4
      4'b0101: segments_encoding <= 7'b1011011;  // 5
      4'b0110: segments_encoding <= 7'b1011111;  // 6
      4'b0111: segments_encoding <= 7'b1110001;  // 7
      4'b1000: segments_encoding <= 7'b1111111;  // 8
      4'b1001: segments_encoding <= 7'b1110011;  // 9
      4'b1010: segments_encoding <= 7'b1110111;  // A
      4'b1011: segments_encoding <= 7'b0011111;  // B
      4'b1100: segments_encoding <= 7'b1001110;  // C
      4'b1101: segments_encoding <= 7'b0111101;  // D
      4'b1110: segments_encoding <= 7'b1001111;  // E
      4'b1111: segments_encoding <= 7'b1000111;  // F
      default: segments_encoding <= 7'b0000000;  // OFF
    endcase
  end

  assign segment_a = segments_encoding[6];
  assign segment_b = segments_encoding[5];
  assign segment_c = segments_encoding[4];
  assign segment_d = segments_encoding[3];
  assign segment_e = segments_encoding[2];
  assign segment_f = segments_encoding[1];
  assign segment_g = segments_encoding[0];

endmodule
