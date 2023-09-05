#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <termios.h>
#include <unistd.h>

#include "include/Codes.h"

#define SERIAL_PORT "/dev/ttyS0"
#define MAX_BUFFER_SIZE 255

const unsigned char DATA_TO_SEND[] = {0x4F, 0x4B, 0x21};

// Configure the settings for the communication with the serial port.
int configureSerialPort(int fd);

// Attempts to read data from an open communication.
int sendData(int fd, const void *data, size_t size);

// Attempts to send data to an open communication.
int receiveData(int fd, void *buffer, size_t size);

// Attemps to open the file that represent the serial port.
void openPort(int *fileDescriptor);

int main(void) {
  /* int fileDescriptor; */
  int request = 0;

  printf("Select on one of the following options:             \n");
  printf("  1 - Request current status of a device.           \n");
  printf("  2 - Request temperature level.                    \n");
  printf("  3 - Request humidity level.                       \n");
  printf("  4 - Activate continuos monitoring - Temperature.  \n");
  printf("  5 - Activate continuos monitoring - humidity.     \n");
  printf("  0 - Quit.                                         \n");
  printf("> ");

  scanf("%d%*c", &request);

  while (request < 0 || request > 5) {
    printf("Invalid option! Please select from the ones listed above...\n");
    printf("> ");
    scanf("%d%*c", &request);
  }

  system("clear");

  switch (request) {
    case 0:
      printf("Finishing...\n");
      break;
    case 1:
      break;
    case 2:
      break;
    case 3:
      break;
    case 4:
      break;
    case 5:
      break;
    default:
      break;
  }

  /* openPort(&fileDescriptor); */

  /* close(fileDescriptor); */

  return 0;
}

void openPort(int *fileDescriptor) {
  /**
   * Open the serial port with some flags:
   *   - O_RDWR: Open for read and writing.
   *   - O_NDELAY: Disable delay while reading/writing.
   *   - O_NOCTTY: Do not assign controlling terminal.
   */
  *fileDescriptor = open(SERIAL_PORT, O_RDWR | O_NDELAY | O_NOCTTY);

  if (*fileDescriptor < 0) {
    printf("[ERROR]: Couldn't open targeted serial port!\n");
    close(*fileDescriptor);
    exit(1);
  }
}

int configureSerialPort(int fileDescriptor) {
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
  tcflush(fileDescriptor, TCIFLUSH);
  if (tcsetattr(fileDescriptor, TCSANOW, &settings) != 0) {
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
