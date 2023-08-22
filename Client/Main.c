#include <fcntl.h>
#include <stdio.h>
#include <string.h>
#include <termios.h>
#include <unistd.h>

#define SERIAL_PORT "/dev/ttyS0"
#define MAX_BUFFER_SIZE 255

const unsigned char DATA_TO_SEND[] = {0x4F, 0x4B, 0x21};

int configureSerialPort(int fd) {
  /**
   * `struct` that hold the settings
   * for the serial communication.
   */
  struct termios settings;

  /* Get the current applied settings. */
  /* tcgetattr(fd, &settings); */

  /* Set up serial port:
   *   - B9600: Baud rate of 9600 bits per second.
   *   - CS8: 8 bits of data.
   *   - CLOCAL: Ignore modem status line.
   *   - CREAD: Enable receiver.
   */
  settings.c_cflag = B9600 | CS8 | CLOCAL | CREAD;
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
