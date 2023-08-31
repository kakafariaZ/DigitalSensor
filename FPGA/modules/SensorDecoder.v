module SensorDecoder (
    input CLK,
    input EN,
    input RST,
    inout DHT_DATA,
    output [7:0] HUM_INT,
    output [7:0] HUM_FLOAT,
    output [7:0] TEMP_INT,
    output [7:0] TEMP_FLOAT,
    output [7:0] CRC,
    output WAIT,
    output DEBUG,
    output ERROR
);

  reg DHT_OUT, DIR, WAIT_REG, DEBUG_REG;
  reg [25:0] COUNTER;
  reg [5:0] index;
  reg [39:0] INTDATA;
  reg error;
  wire DHT_IN;

  assign WAIT  = WAIT_REG;
  assign DEBUG = DEBUG_REG;

  TriState TS0 (
      .port(DHT_DATA),
      .dir (DIR),
      .send(DHT_OUT),
      .read(DHT_IN)
  );

  assign HUM_INT[0] = INTDATA[0];
  assign HUM_INT[1] = INTDATA[1];
  assign HUM_INT[2] = INTDATA[2];
  assign HUM_INT[3] = INTDATA[3];
  assign HUM_INT[4] = INTDATA[4];
  assign HUM_INT[5] = INTDATA[5];
  assign HUM_INT[6] = INTDATA[6];
  assign HUM_INT[7] = INTDATA[7];

  assign HUM_FLOAT[0] = INTDATA[8];
  assign HUM_FLOAT[1] = INTDATA[9];
  assign HUM_FLOAT[2] = INTDATA[10];
  assign HUM_FLOAT[3] = INTDATA[11];
  assign HUM_FLOAT[4] = INTDATA[12];
  assign HUM_FLOAT[5] = INTDATA[13];
  assign HUM_FLOAT[6] = INTDATA[14];
  assign HUM_FLOAT[7] = INTDATA[15];

  assign TEMP_INT[0] = INTDATA[16];
  assign TEMP_INT[1] = INTDATA[17];
  assign TEMP_INT[2] = INTDATA[18];
  assign TEMP_INT[3] = INTDATA[19];
  assign TEMP_INT[4] = INTDATA[20];
  assign TEMP_INT[5] = INTDATA[21];
  assign TEMP_INT[6] = INTDATA[22];
  assign TEMP_INT[7] = INTDATA[23];

  assign TEMP_FLOAT[0] = INTDATA[24];
  assign TEMP_FLOAT[1] = INTDATA[25];
  assign TEMP_FLOAT[2] = INTDATA[26];
  assign TEMP_FLOAT[3] = INTDATA[27];
  assign TEMP_FLOAT[4] = INTDATA[28];
  assign TEMP_FLOAT[5] = INTDATA[29];
  assign TEMP_FLOAT[6] = INTDATA[30];
  assign TEMP_FLOAT[7] = INTDATA[31];

  assign CRC[0] = INTDATA[32];
  assign CRC[1] = INTDATA[33];
  assign CRC[2] = INTDATA[34];
  assign CRC[3] = INTDATA[35];
  assign CRC[4] = INTDATA[36];
  assign CRC[5] = INTDATA[37];
  assign CRC[6] = INTDATA[38];
  assign CRC[7] = INTDATA[39];

  localparam S0 = 4'b0001, S1 = 4'b0010, S2 = 4'b0011,
             S3 = 4'b0100, S4 = 4'b0101, S5 = 4'b0110,
             S6 = 4'b0111, S7 = 4'b1000, S8 = 4'b1001,
             S9 = 4'b1010, START = 4'b1011, STOP = 4'b0000;

  reg [3:0] STATE = STOP;

  always @(posedge CLK) begin
    if (EN == 1'b1) begin
      if (RST == 1'b1) begin
        DHT_OUT <= 1'b1;
        WAIT_REG <= 1'b0;
        COUNTER <= 26'b00000000000000000000000000;
        INTDATA <= 40'b0000000000000000000000000000000000000000;
        DIR <= 1'b1;
        error <= 1'b0;
        STATE <= START;
      end else begin
        case (STATE)
          START: begin
            WAIT_REG <= 1'b1;
            DIR <= 1'b1;
            DHT_OUT <= 1'b1;
            STATE <= S0;
          end

          S0: begin
            DIR <= 1'b1;
            DHT_OUT <= 1'b1;
            WAIT_REG <= 1'b1;
            error <= 1'b0;

            if (COUNTER < 1_800_000) begin
              COUNTER <= COUNTER + 1'b1;
            end else begin
              STATE   <= S1;
              COUNTER <= 26'b00000000000000000000000000;
            end
          end

          S1: begin
            DHT_OUT  <= 1'b0;
            WAIT_REG <= 1'b1;

            if (COUNTER < 1_800_000) begin
              COUNTER <= COUNTER + 1'b1;
            end else begin
              STATE   <= S2;
              COUNTER <= 26'b00000000000000000000000000;
            end
          end

          S2: begin
            DHT_OUT <= 1'b1;

            if (COUNTER < 2_000) begin
              COUNTER <= COUNTER + 1'b1;
            end else begin
              STATE <= S3;
              DIR   <= 1'b0;
            end
          end

          S3: begin
            if (COUNTER < 6_000 && DHT_IN == 1'b1) begin
              STATE   <= S3;
              COUNTER <= COUNTER + 1'b1;
            end else begin
              if (DHT_IN == 1'b1) begin
                STATE   <= STOP;
                error   <= 1'b1;
                COUNTER <= 26'b00000000000000000000000000;
              end else begin
                STATE   <= S4;
                COUNTER <= 26'b00000000000000000000000000;
              end
            end
          end

          S4: begin
            if (DHT_IN == 1'b0 && COUNTER < 8800) begin
              STATE   <= S4;
              COUNTER <= COUNTER + 1'b1;
            end else begin
              if (DHT_IN == 1'b0) begin
                STATE   <= STOP;
                error   <= 1'b1;
                COUNTER <= 26'b00000000000000000000000000;
              end else begin
                STATE   <= S5;
                COUNTER <= 26'b00000000000000000000000000;
              end
            end
          end

          S5: begin
            if (DHT_IN == 1'b1 && COUNTER < 8800) begin
              STATE   <= S5;
              COUNTER <= COUNTER + 1'b1;
            end else begin
              if (DHT_IN == 1'b1) begin
                STATE   <= STOP;
                error   <= 1'b1;
                COUNTER <= 26'b00000000000000000000000000;
              end else begin
                STATE   <= S6;
                error   <= 1'b1;
                index   <= 6'b000000;
                COUNTER <= 26'b00000000000000000000000000;
              end
            end
          end

          S6: begin
            if (DHT_IN == 1'b0) begin
              STATE <= S7;
            end else begin
              STATE   <= STOP;
              error   <= 1'b1;
              COUNTER <= 26'b00000000000000000000000000;
            end
          end

          S7: begin
            if (DHT_IN == 1'b1) begin
              STATE   <= S8;
              COUNTER <= 26'b00000000000000000000000000;
            end else begin
              if (COUNTER < 3200000) begin
                STATE   <= S7;
                COUNTER <= COUNTER + 1'b1;
              end else begin
                STATE   <= STOP;
                error   <= 1'b1;
                COUNTER <= 26'b00000000000000000000000000;
              end
            end
          end

          S8: begin
            if (DHT_IN == 1'b0) begin
              if (COUNTER > 5000) begin
                INTDATA[index] <= 1'b1;
                DEBUG_REG <= 1'b1;
              end else begin
                INTDATA[index] <= 1'b0;
                DEBUG_REG <= 1'b0;
              end

              if (index < 39) begin
                STATE   <= S9;
                COUNTER <= 26'b00000000000000000000000000;
              end else begin
                error <= 1'b0;
                STATE <= STOP;
              end
            end else begin
              COUNTER <= COUNTER + 1'b1;

              if (COUNTER == 3200000) begin
                error <= 1'b1;
                STATE <= STOP;
              end
            end
          end

          S9: begin
            index <= index + 1'b1;
            STATE <= S6;
          end

          STOP: begin
            STATE <= STOP;

            if (error == 1'b0) begin
              DHT_OUT <= 1'b1;
              WAIT_REG <= 1'b0;
              COUNTER <= 26'b00000000000000000000000000;
              DIR <= 1'b1;
              error <= 1'b0;
              index <= 6'b000000;
            end else begin
              if (COUNTER < 3200000) begin
                INTDATA <= 40'b0000000000000000000000000000000000000000;
                COUNTER <= COUNTER + 1'b1;
                error <= 1'b1;
                WAIT_REG <= 1'b1;
                DIR <= 1'b0;
              end else begin
                error <= 1'b0;
              end
            end
          end

          default: begin
          end
        endcase
      end
    end
  end

endmodule
