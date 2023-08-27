#include <fcntl.h>
#include <stdio.h>
#include <unistd.h>

#include "include/Serial.h"

#define SERIAL_PORT "/dev/ttyS0"
#define MAX_BUFFER_SIZE 255

const unsigned char DATA_TO_SEND[] = {0x4F, 0x4B, 0x21, 0x00};

int main(void) {
  int fd;
  char buffer[MAX_BUFFER_SIZE];

  /**
   * Open the serial port with some flags:
   *   - O_RDWR: Open for read and writing.
   *   - O_NDELAY: Disable delay while reading/writing.
   *   - O_NOCTTY: Do not assign controlling terminal.
   */
  fd = open(SERIAL_PORT, O_RDWR | O_NDELAY | O_NOCTTY);

  if (fd < 0) {
    printf("[ERROR]: Couldn't open targeted serial port!\n");
    return 1;
  }

  /* Configure the serial port. */
  if (configureSerialPort(fd) != 0) {
    close(fd);
    return 1;
  }

  /* Send data. */
  int bytes_written = sendData(fd, DATA_TO_SEND, sizeof(DATA_TO_SEND));
  if (bytes_written > 0) {
    printf("Sent %d bytes: %s\n", bytes_written, DATA_TO_SEND);
  }

  /* Receive data. */
  int bytes_read = receiveData(fd, buffer, sizeof(buffer));
  if (bytes_read > 0) {
    buffer[bytes_read] = '\0';
    printf("Received %d bytes: %s\n", bytes_read, buffer);
  }

  /* Close the serial port. */
  close(fd);

  return 0;
}
