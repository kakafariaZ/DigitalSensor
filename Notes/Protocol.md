# Protocol

> Here is described the protocol chosen for the communication between the devices.

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

| Code |                                    Description                                    |
| :--: | :-------------------------------------------------------------------------------: |
| 0x1F |                               Sensor with problems                                |
| 0x07 |                              Sensor working normally                              |
| 0x08 |                          Temperature level - Whole part                           |
| 0x09 |                        Temperature level - Fractional part                        |
| 0x0A |                            Humidity level - Whole part                            |
| 0x0B |                         Humidity level - Fractional part                          |
| 0x0C | Confirmation of the deactivation of continuos monitoring of the temperature level |
| 0x0D |  Confirmation of the deactivation of continuos monitoring of the humidity level   |
