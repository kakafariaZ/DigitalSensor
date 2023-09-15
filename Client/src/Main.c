#include <fcntl.h>
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <termios.h>
#include <unistd.h>

#include "include/Codes.h"

#define SERIAL_PORT "/dev/ttyS0"
#define MAX_BUFFER_SIZE 255
#define PACKAGE_SIZE 2

#define BYTE_TO_BINARY_PATTERN "%c%c%c%c%c%c%c%c"
#define BYTE_TO_BINARY(byte)  \
  ((byte) & 0x80 ? '1' : '0'), \
  ((byte) & 0x40 ? '1' : '0'), \
  ((byte) & 0x20 ? '1' : '0'), \
  ((byte) & 0x10 ? '1' : '0'), \
  ((byte) & 0x08 ? '1' : '0'), \
  ((byte) & 0x04 ? '1' : '0'), \
  ((byte) & 0x02 ? '1' : '0'), \
  ((byte) & 0x01 ? '1' : '0') 

int QNT_SENSOR = 1;
// const unsigned char DATA_TO_SEND[] = {0x4F, 0x4B, 0x21};

// Configure the settings for the communication with the serial port.
int configureSerialPort(int fd);

// Attempts to read data from an open communication.
int sendData(int fd, const void *data, size_t size);

// Attempts to send data to an open communication.
int receiveData(int fd, void *buffer, size_t size);

// Attemps to open the file that represent the serial port.
void openPort(int *fileDescriptor);

// Show recieved data in continuos mode.
void *continuosMode(void *arg);

// Selects a sensor address.
int chooseSensor();

// Handles the transmission (Client -> FPGA & FPGA -> Client).
int handleTransmission(int *fd, char *dataToSend, char *buffer);

// Handles the continuous monitoring using a separate thread.
void *continuosMonitoring(void *args);

int main(void) {
  int fileDescriptor;
  int request = 0;
  int choosedSensor;
  int transmition_error;
  int whole_part, fractional_part;
  int thread_information[2];
  char availableSensors[] = {0x20};
  char dataToSend[2], buffer[2];  // See: PROTOCOL.md
  pthread_t monitoring_thread;

  do {
    system("clear");
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
    if (request != 0) {           // If the user don't quit...
      openPort(&fileDescriptor);  // Opens the serial port
      if (configureSerialPort(fileDescriptor)) {
        return 1;  // Quit the program if cant configure port.
      }
      // Second byte of the communication is the sensor address.
      dataToSend[1] = availableSensors[chooseSensor()];
    }

    switch (request) {
      case 0:
        printf("Finishing...\n");
        break;
      case 1:
        dataToSend[0] = REQ_STATUS;
        transmition_error =
          handleTransmission(&fileDescriptor, dataToSend, buffer);
        if (transmition_error) {
          printf("An error occourred!\n");
          return 1;
        }
        if (buffer[1] == REP_STATUS_OK)
          printf("Sensor working normally!\n");
        else if (buffer[1] == REP_STATUS_ERROR)
          printf("Sensor with problem!\n");
        else
          printf("Communication Error!\n");
        break;

      case 2:
        dataToSend[0] = REQ_TEMP_INT;
        transmition_error =
          handleTransmission(&fileDescriptor, dataToSend, buffer);
        if (transmition_error) {
          printf("An error occourred!\n");
          return 1;
        }
        
        if (buffer[0] != REP_TEMP_INT){
          printf("Communication Error!\n");
          break;
        }

        whole_part = (int)buffer[1];
        dataToSend[0] = REQ_TEMP_FLOAT;
        transmition_error =
          handleTransmission(&fileDescriptor, dataToSend, buffer);
        if (transmition_error) {
          printf("An error occourred!\n");
          return 1;
        }

        if (buffer[0] != REP_TEMP_FLOAT){
          printf("Communication Error!\n");
          break;
        }

        fractional_part = (int)buffer[1];
        printf("Temperature of Sensor %d: \n", choosedSensor);
        printf("   %d.%d\n", whole_part, fractional_part);
        break;

      case 3:
        dataToSend[0] = REQ_HUM_INT;
        transmition_error =
          handleTransmission(&fileDescriptor, dataToSend, buffer);
        if (transmition_error) {
          printf("An error occourred!\n");
          return 1;
        }

        if (buffer[0] != REP_HUM_INT){
          printf("Communication Error!\n");
          break;
        }

        whole_part = (int)buffer[1];
        dataToSend[0] = REQ_HUM_FLOAT;
        transmition_error =
          handleTransmission(&fileDescriptor, dataToSend, buffer);
        
        if (transmition_error) {
          printf("An error occourred!\n");
          return 1;
        }

        if (buffer[0] != REP_HUM_FLOAT){
          printf("Communication Error!\n");
          break;
        }

        fractional_part = (int)buffer[1];
        printf("Humidity of Sensor %d: \n", choosedSensor);
        printf("   %d.%d\n", whole_part, fractional_part);
        break;

      default:
        thread_information[0] = fileDescriptor;
        if (request == 4){
          dataToSend[0] = REQ_ACT_MNTR_TEMP;
          thread_information[1] = 1;
        }
        else{
          dataToSend[0] = REQ_ACT_MNTR_HUM;
          thread_information[1] = 0;
        }

        system("clear");
        // asking for continuous monitoring.
        sendData(fileDescriptor ,dataToSend ,PACKAGE_SIZE);
        sleep(1);
      
        // Create a thread for continuous monitoring.
        if (pthread_create(&monitoring_thread, NULL, continuosMonitoring, thread_information) != 0) {
          perror("pthread_create");
          break;
        }

        getchar(); // Waits for user's input to close the thread
        
        pthread_cancel(monitoring_thread);
        pthread_join(monitoring_thread, NULL);
        printf("Finishing continuous monitoring");

        if (request == 4)
          dataToSend[0] = REQ_DEACT_MNTR_TEMP;
        else 
          dataToSend[0] = REQ_DEACT_MNTR_HUM;

        sendData(fileDescriptor, dataToSend, PACKAGE_SIZE);
        sleep(1);
        system("clear");

        break;
    }
  }
  while (request != 0);
  close(fileDescriptor);

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

int chooseSensor() {
  int choosedSensor = -1;
  do {
    printf("Choose the sensor:\n");
    printf("  1 - DHT11 (0x20)\n");
    printf("> ");
    scanf("%d%*c", &choosedSensor);
    choosedSensor--;
    if (choosedSensor < 0 || choosedSensor > QNT_SENSOR) {
      printf("Please choose one of the following sensors...\n");
      sleep(1);
      system("clear");
    }
  } while (choosedSensor < 0 || choosedSensor > QNT_SENSOR);
  return choosedSensor;
}

int handleTransmission(int *fd, char *dataToSend, char *buffer) {
  int bytes_written = sendData(*fd, dataToSend, PACKAGE_SIZE);
  if (bytes_written > 0) {
    printf("Sent %d bytes:\n", bytes_written);  // debug
    for (int i = 0; i < bytes_written; i++) {
      printf(BYTE_TO_BINARY_PATTERN, BYTE_TO_BINARY(dataToSend[i]));
      printf("%s", (i == bytes_written - 1) ? "\n" : "-");
    }
  } else {
    return 1;
  }
  int bytes_read = receiveData(*fd, buffer, PACKAGE_SIZE);
  if (bytes_read > 0) {
    printf("Received %d bytes:\n", bytes_read);  // debug:
    for (int i = 0; i < bytes_read; i++) {
      printf(BYTE_TO_BINARY_PATTERN, BYTE_TO_BINARY(dataToSend[i]));
      printf("%s", (i == bytes_written - 1) ? "\n" : "-");
    }
  } else {
    return 1;
  }
  return 0;
}

void *continuosMonitoring(void *arg) {
  int *information = (int *)arg;  // information 0 -> fd, information 1 -> type
  int whole_part;
  int fractional_part;
  char buffer[2];

  while (1) {
    system("clear");
    receiveData(information[0], buffer, PACKAGE_SIZE);
    
    if (buffer[0] !=REP_ACT_MNTR_TEMP && buffer[0] != REP_ACT_MNTR_HUM){
      printf("Communication Error!\n");
      continue;
    }

    whole_part = (int)buffer[1];
    sleep(1);
    receiveData(information[0], buffer, PACKAGE_SIZE);

    if (buffer[0] !=REP_ACT_MNTR_TEMP && buffer[0] != REP_ACT_MNTR_HUM){
      printf("Communication Error!\n");
      continue;
    }

    fractional_part = (int)buffer[1];

    if (information[1]) {  // 1 Stands for Temperature, 0 for Humidity
      printf("Actual temperature...\n");
    } else {
      printf("Actual Humidity...\n");
    }

    printf("   %d.%d\n", whole_part, fractional_part);

    sleep(1);
  }
  return NULL;
}
