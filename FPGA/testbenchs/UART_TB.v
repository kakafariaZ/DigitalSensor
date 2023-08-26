`timescale 1ns / 1ps

module UART_TB;

  // Define clock parameters
  parameter CLOCK_PERIOD = 10; // 10ns clock period
  parameter CLOCK_FREQUENCY = 10000000; // 10MHz
  reg CLK = 0;

  // UART parameters
  parameter BAUD_RATE = 115200;
  parameter CLOCKS_PER_BIT = CLOCK_FREQUENCY / BAUD_RATE; // Calculate bit period in ns

  // UART data
  reg [7:0] tx_data = 8'hAB;
  reg tx_data_valid = 0;
  wire tx_sending_bit;
  wire tx_is_transmitting;
  wire tx_transmission_done;
  wire [7:0] rx_data;
  reg rx_serial = 1'b1;
  wire rx_data_valid;

  // Instantiate UART modules
  UART_TX #(
    .CLOCKS_PER_BIT(CLOCKS_PER_BIT)
  ) tx (
    .clock(CLK),
    .has_data(tx_data_valid),
    .data_to_send(tx_data),
    .sending_bit(tx_sending_bit),
    .is_transmitting(tx_is_transmitting),
    .transmission_done(tx_transmission_done)
  );

  UART_RX #(
    .CLOCKS_PER_BIT(CLOCKS_PER_BIT)
  ) rx (
    .clock(CLK),
    .incoming_bit(rx_serial),
    .has_data(rx_data_valid),
    .data_received(rx_data)
  );

  // Clock generation
  always begin
    #(CLOCK_PERIOD / 2) CLK = ~CLK;
  end

  // Test procedure
  initial begin
    // Initialize UART modules
    rx_serial = 1;

    // Start transmission
    tx_data_valid = 1;
    #(CLOCK_PERIOD * 10); // Wait for transmission to complete
    
    // Stop transmission
    tx_data_valid = 0;
    #(CLOCK_PERIOD * 10); // Wait for transmission to complete
    
    // Check received data
    if (rx_data_valid) begin
      if (rx_data == 8'hAB)
        $display("Test Passed - Correct Byte Received: %h", rx_data);
      else
        $display("Test Failed - Incorrect Byte Received: %h", rx_data);
    end else begin
      $display("Test Failed - No Data Received");
    end

    $stop; // End simulation
  end

endmodule

