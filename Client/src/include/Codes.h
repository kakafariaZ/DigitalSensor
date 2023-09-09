#ifndef CODES_H
#define CODES_H

// clang-format off
#define REQ_STATUS           0x00
#define REQ_TEMP_INT         0x01
#define REQ_TEMP_FLOAT       0x02
#define REQ_HUM_INT          0x03
#define REQ_HUM_FLOAT        0x04
#define REQ_ACT_MNTR_TEMP    0x05
#define REQ_ACT_MNTR_HUM     0x06
#define REQ_DEACT_MNTR_TEMP  0x07
#define REQ_DEACT_MNTR_HUM   0x08

#define REP_STATUS_OK        0x10
#define REP_STATUS_ERROR     0x11
#define REP_TEMP_INT         0x12
#define REP_TEMP_FLOAT       0x13
#define REP_HUM_INT          0x14
#define REP_HUM_FLOAT        0x15
#define REP_ACT_MNTR_TEMP    0x16
#define REP_ACT_MNTR_HUM     0x17
#define REP_DEACT_MNTR_TEMP  0x18
#define REP_DEACT_MNTR_HUM   0x19
// clang-format on

#endif
