```markdown
                     ____  _       _ _        _   ____
                    |  _ \(_) __ _(_) |_ __ _| | / ___|  ___ _ __  ___  ___  _ __
                    | | | | |/ _` | | __/ _` | | \___ \ / _ \ '_ \/ __|/ _ \| '__|
                    | |_| | | (_| | | || (_| | |  ___) |  __/ | | \__ \ (_) | |
                    |____/|_|\__, |_|\__\__,_|_| |____/ \___|_| |_|___/\___/|_|
                             |___/
```

> Prototype of a complete digital system for managing environments using IoT for tracking
> measurements such as temperature and humidity levels.
>
> By: [Kauan Caio de Arruda Farias](https://github.com/kakafariaZ)

<div align=center>

# Digital Sensor on FPGA using UART
</div>

## Problem description:

This work is the result of the collective collaboration of students in the TEC499 discipline of the Computer Engineering course at UEFS (State University of Feira de Santana).
The objective of the following work is the development of a hardware project that monitors temperature using serial communication on an FPGA. The communication protocol was made using UART (Universal Asynchronous Receiver/Transmitter), the sensor used (with the possibility of a future change) was the DHT11, the hardware platform was an FPGA and the human/machine interface was built in C.

## Project requirements:

- Use of the DHT11 sensor.
- Implementation of a serial communication interface (UART).
- Development of a testing system in C language.
- Writing the FPGA code in Verilog language.
- Guaranteed modularity to allow components to be replaced in the production version as needed.
- Ability to read, interpret and execute commands coming from the computer, as well as return responses to the commands.
- Commands must be composed of 8-bit words.
- Requests and responses with 2 bytes.

 ## Resources used:

- FPGA Mercurio IV Devkit - Cyclone IV EP4CE30F23
- DHT11 temperature and humidity sensor
- Quartus 20.1
- Verilog HDL
- Visual Studio Code

## Protocol:

> Here is described the protocol chosen for the communication between the devices.

Communication is done using 2 bytes for request and 2 bytes as response.
The commands are composed of 1 byte with the requested request or response obtained + 1 byte with the sensor address.
If, for example, the request asks the sensor for its current state, it would then send 1 byte with the address of the sensor that you want to obtain information about. If you want to obtain the current state of the sensor, the address would be sent along with the code 0x00.
The response then consists of the status of the sensor, along with the corresponding response code or whether it is working properly or not. The answer could contain the humidity number or temperature.

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

<div align="center">

[![Activity](https://img.shields.io/github/last-commit/gersonfaneto/DigitalSensor?color=blue&style=for-the-badge&logo=git)](https://github.com/gersonfaneto/DigitalSensor/commit/main)
[![License](https://img.shields.io/github/license/gersonfaneto/DigitalSensor?color=blue&style=for-the-badge)](https://github.com/gersonfaneto/DigitalSensor/blob/main/LICENSE)
[![Stars](https://img.shields.io/github/stars/gersonfaneto/DigitalSensor?style=for-the-badge&logo=github)](https://github.com/gersonfaneto/DigitalSensor)
[![Language](https://img.shields.io/static/v1?label=LANGUAGE&message=Verilog&color=informational&style=for-the-badge)](https://ieeexplore.ieee.org/document/5985443)

</div>

# License

Released under the [MIT](https://github.com/gersonfaneto/DigitalSensor/blob/main/LICENSE) license by:

Honorable mention:
- [Everton Vinicius da Silva Ferreira](https://github.com/Yamis4n)
- [Gerson Ferreira dos Anjos Neto](https://github.com/gersonfaneto)

