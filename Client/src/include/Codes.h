#ifndef CODES_H
#define CODES_H

// clang-format off
#define REQ_STATUS           0x00
#define REQ_TEMP             0x01
#define REQ_HUM              0x02
#define REQ_ACT_MNTR_TEMP    0x03
#define REQ_ACT_MNTR_HUM     0x04
#define REQ_DEACT_MNTR_TEMP  0x05
#define REQ_DEACT_MNTR_HUM   0x06

#define RESP_STATUS           0x10
#define RESP_STATUS_ERROR     0x13
#define RESP_STATUS_OK        0x14
#define RESP_TEMP             0x11
#define RESP_HUM              0x12
#define RESP_DEACT_MNTR_TEMP  0x15
#define RESP_DEACT_MNTR_HUM   0x16
#define CONFIRMS_ACTION       0xCA
#define INVALID_ACTION        0xEA
#define UNKNOWN_COMMAND       0xEC
#define UNKNOWN_DEVICE        0xED
// clang-format on

#endif
