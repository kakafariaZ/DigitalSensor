#ifndef SERIAL_H
#define SERIAL_H

#include <unistd.h>

/**
 * Configure the settings for the communication with the serial port.
 */
int configureSerialPort(int fd);

/**
 * Attempts to read data from an open communication.
 */
int sendData(int fd, const void *data, size_t size);

/**
 * Attempts to send data to an open communication.
 */
int receiveData(int fd, void *buffer, size_t size);

#endif  // !SERIAL_H
