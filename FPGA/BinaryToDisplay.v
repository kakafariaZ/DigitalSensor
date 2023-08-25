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
    input        clock,
    input  [3:0] binary_number,
    output       segment_a,
    output       segment_b,
    output       segment_c,
    output       segment_d,
    output       segment_e,
    output       segment_f,
    output       segment_g
);

  reg [6:0] hex_encoding = 7'h00;

  always @(posedge clock) begin
    case (binary_number)
      4'b0000: hex_encoding <= 7'h7E;
      4'b0001: hex_encoding <= 7'h30;
      4'b0010: hex_encoding <= 7'h6D;
      4'b0011: hex_encoding <= 7'h79;
      4'b0100: hex_encoding <= 7'h33;
      4'b0101: hex_encoding <= 7'h5B;
      4'b0110: hex_encoding <= 7'h5F;
      4'b0111: hex_encoding <= 7'h70;
      4'b1000: hex_encoding <= 7'h7F;
      4'b1001: hex_encoding <= 7'h7B;
      4'b1010: hex_encoding <= 7'h77;
      4'b1011: hex_encoding <= 7'h1F;
      4'b1100: hex_encoding <= 7'h4E;
      4'b1101: hex_encoding <= 7'h3D;
      4'b1110: hex_encoding <= 7'h4F;
      4'b1111: hex_encoding <= 7'h47;
    endcase
  end

  assign segment_a = hex_encoding[6];
  assign segment_b = hex_encoding[5];
  assign segment_c = hex_encoding[4];
  assign segment_d = hex_encoding[3];
  assign segment_e = hex_encoding[2];
  assign segment_f = hex_encoding[1];
  assign segment_g = hex_encoding[0];

endmodule
