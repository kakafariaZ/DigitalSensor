# Protocol

> Here is described the protocol chosen for the communication between the devices.

<!-- TODO: Definir detalhes do protocolo de comuniação. -->

###### Request commands

| Code |                       Description                        |
| :--: | :------------------------------------------------------: |
| 0x00 |         Request the current state of the sensor          |
| 0x01 |    Request the current temperature level - Whole part    |
| 0x02 | Request the current temperature level - Fractional part  |
| 0x03 |     Request the current humidity level - Whole part      |
| 0x04 |     Request the current humidity level - Fractional      |
| 0x05 |  Activate continuos monitoring of the temperature level  |
| 0x06 |   Activate continuos monitoring of the humidity level    |
| 0x07 | Deactivate continuos monitoring of the temperature level |
| 0x08 |  Deactivate continuos monitoring of the humidity level   |
| 0xCB |              Request to begin communication              |
| 0xCD |               Request to end communication               |

###### Response commands

| Code |                                    Description                                    |
| :--: | :-------------------------------------------------------------------------------: |
| 0x1F |                               Sensor with problems                                |
| 0x09 |                              Sensor working normally                              |
| 0x0A |                          Temperature level - Whole part                           |
| 0x0B |                        Temperature level - Fractional part                        |
| 0x0C |                            Humidity level - Whole part                            |
| 0x0D |                         Humidity level - Fractional part                          |
| 0x0E | Confirmation of the deactivation of continuos monitoring of the temperature level |
| 0x0F |  Confirmation of the deactivation of continuos monitoring of the humidity level   |
| 0xFB |                        Confirm beginning of communication                         |
| 0xFD |                           Confirm end of communication                            |
