/**
* This module implements a tri-state buffer, which can assume one of three output states: high (1),
*  low (0), or high-impedance (Z), depending on the control signal `dir`.
*
* Usage:
*   - Connect `port` to the desired signal bus.
*   - Set `dir` to 1 to enable data flow from `send` to `port`.
*   - Set `dir` to 0 to place `port` in a high-impedance state (Z) and read data from `port`
*     using `read`.
*/

module TriState (
    inout  wire port,
    input  wire dir,
    input  wire send,
    output wire read
);

  assign port = dir ? send : 1'bZ;
  assign read = dir ? 1'bZ : port;

endmodule
