# Protocol

> Here is described the protocol chosen for the communication between the devices.

<!-- TODO: Definir detalhes do protocolo de comuniação. -->

###### Request commands

| Code |                       Description                        |
| :--: | :------------------------------------------------------: |
| 0x00 |         Request the current state of the sensor          |
| 0x01 |          Request the current temperature level           |
| 0x02 |            Request the current humidity level            |
| 0x03 |  Activate continuos monitoring of the temperature level  |
| 0x04 |   Activate continuos monitoring of the humidity level    |
| 0x05 | Deactivate continuos monitoring of the temperature level |
| 0x06 |  Deactivate continuos monitoring of the humidity level   |

###### Response commands

| Code |                                    Description                                    |                           Response                           |
| :--: | :-------------------------------------------------------------------------------: | :----------------------------------------------------------: |
| 0x10 |                           Current status of the sensor                            | 0xDF - Sensor working normally / 0xDE - Sensor with problems |
| 0x11 |                                 Temperature level                                 |                         Temperature                          |
| 0x12 |                                  Humidity level                                   |                           Humidity                           |
| 0x15 | Confirmation of the deactivation of continuos monitoring of the temperature level |                 0xEA - If not active! / 0xCA                 |
| 0x16 |  Confirmation of the deactivation of continuos monitoring of the humidity level   |                 0xEA - If not active! / 0xCA                 |
| 0xCA |                        INFO: Confirms the received request                        |                             NULL                             |
| 0xEA |            ERROR: Invalid action at the current state of the prototype            |                             NULL                             |
| 0xEC |             ERROR: Command received isn't registered on the Protocol              |                             NULL                             |
| 0xED |          ERROR: Device address received isn't registered on the Protocol          |                             NULL                             |

###### Available devices

| Code |   Binary    |  Sensor   |
| :--: | :---------: | :-------: |
| 0x20 | 8'b00100000 |   DHT11   |
| 0x21 | 8'b00100001 | Undefined |
| 0x22 | 8'b00100010 | Undefined |
| 0x23 | 8'b00100011 | Undefined |
| 0x24 | 8'b00100100 | Undefined |
| 0x25 | 8'b00100101 | Undefined |
| 0x26 | 8'b00100110 | Undefined |
| 0x27 | 8'b00100111 | Undefined |
| 0x28 | 8'b00101000 | Undefined |
| 0x29 | 8'b00101001 | Undefined |
| 0x2A | 8'b00101010 | Undefined |
| 0x2B | 8'b00101011 | Undefined |
| 0x2C | 8'b00101100 | Undefined |
| 0x2D | 8'b00101101 | Undefined |
| 0x2E | 8'b00101110 | Undefined |
| 0x2F | 8'b00101111 | Undefined |
| 0x30 | 8'b00110000 | Undefined |
| 0x31 | 8'b00110001 | Undefined |
| 0x32 | 8'b00110010 | Undefined |
| 0x33 | 8'b00110011 | Undefined |
| 0x34 | 8'b00110100 | Undefined |
| 0x35 | 8'b00110101 | Undefined |
| 0x36 | 8'b00110110 | Undefined |
| 0x37 | 8'b00110111 | Undefined |
| 0x38 | 8'b00111000 | Undefined |
| 0x39 | 8'b00111001 | Undefined |
| 0x3A | 8'b00111010 | Undefined |
| 0x3B | 8'b00111011 | Undefined |
| 0x3C | 8'b00111100 | Undefined |
| 0x3D | 8'b00111101 | Undefined |
| 0x3E | 8'b00111110 | Undefined |
| 0x3F | 8'b00111111 | Undefined |

Communication is done using 2 bytes for request and 2 bytes as response.
The commands are composed of 1 byte with the requested request or response obtained + 1 byte with the sensor address.

If, for example, the request asks the sensor for its current state, it would then send 1 byte with the address of the sensor that you want to obtain information about. If you want to obtain the current state of the sensor, the address would be sent along with the code 0x00.

The response then consists of the address of the sensor that was requested, together with the corresponding response code. The response could be negative by presenting NULL or it could be returned as the sensor address along with the code 0x10.
