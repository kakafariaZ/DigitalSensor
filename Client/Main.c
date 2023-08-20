#include <fcntl.h>
#include <stdio.h>
#include <string.h>
#include <termios.h>
#include <unistd.h>

#define SERIAL_PORT "/dev/ttyS0"
#define DATA_TO_SEND "Hello, World!"
#define MAX_BUFFER_SIZE 255

int configureSerialPort(int fd) {
  struct termios settings;

  tcgetattr(fd, &settings);

  /* Set the baud rate to 9600. */
  cfsetospeed(&settings, B9600);
  cfsetispeed(&settings, B9600);

  /* Set the data bits, stop bits, and parity. */
  settings.c_cflag &= ~PARENB;  // No parity bit.
  settings.c_cflag &= ~CSTOPB;  // Single stop bit.
  settings.c_cflag &= ~CSIZE;   // Clear size of data bits.
  settings.c_cflag |= CS8;      // 8 bits of data.

  /* Apply the settings. */
  if (tcsetattr(fd, TCSANOW, &settings) != 0) {
    printf("[ERROR]: Couldn't configure serial port settings!\n");
    return -1;
  }

  return 0;
}

int sendData(int fd, const char *data) {
  int bytes_written = write(fd, data, strlen(data));

  if (bytes_written < 0) {
    printf("[ERROR]: Failed to write data to serial port!\n");
  }

  return bytes_written;
}

int receiveData(int fd, char *buffer, int buffer_size) {
  int bytes_read = read(fd, buffer, buffer_size);

  if (bytes_read < 0) {
    printf("[ERROR]: Failed to read data from serial port!\n");
  }

  return bytes_read;
}

int main(void) {
  int fd;
  char buffer[MAX_BUFFER_SIZE];

  /* Open the serial port. */
  fd = open(SERIAL_PORT, O_RDWR);

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
  int bytes_written = sendData(fd, DATA_TO_SEND);
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
