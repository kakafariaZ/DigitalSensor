#include "include/Serial.h"

#include <stdio.h>
#include <string.h>
#include <termios.h>
#include <unistd.h>

int configureSerialPort(int fd) {
  /**
   * `struct` that hold the settings
   * for the serial communication.
   */
  struct termios settings;

  /* Get the current applied settings. */
  /* tcgetattr(fd, &settings); */

  /* Set up serial port:
   *   - B115200: Baud rate of 115,200 bits per second.
   *   - CS8: 8 bits of data.
   *   - CLOCAL: Ignore modem status line.
   *   - CREAD: Enable receiver.
   */
  settings.c_cflag = B115200 | CS8 | CLOCAL | CREAD;
  settings.c_iflag = IGNPAR;
  settings.c_oflag = 0;
  settings.c_lflag = 0;

  /* Apply the settings. */
  tcflush(fd, TCIFLUSH);
  if (tcsetattr(fd, TCSANOW, &settings) != 0) {
    printf("[ERROR]: Couldn't configure serial port settings!\n");
    return -1;
  }

  return 0;
}

int sendData(int fd, const void *data, size_t size) {
  int bytes_written = write(fd, data, size);

  if (bytes_written < 0) {
    printf("[ERROR]: Failed to write data to serial port!\n");
  }

  return bytes_written;
}

int receiveData(int fd, void *buffer, size_t size) {
  int bytes_read = read(fd, buffer, size);

  if (bytes_read < 0) {
    printf("[ERROR]: Failed to read data from serial port!\n");
  }

  return bytes_read;
}
