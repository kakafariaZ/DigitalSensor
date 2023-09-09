#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <termios.h>
#include <unistd.h>
#include <pthread.h>

#include "include/Codes.h"

#define SERIAL_PORT "/dev/ttyS0"
#define MAX_BUFFER_SIZE 255

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

// TODO: What does this do...? - Gerson
int handleTransmission(int *fd, char *dataToSend, char *buffer);

// Handle with the continuos monitoring.
void *continuosMonitoring(void *);


int main(void) {
  int fileDescriptor;
  int request = 0;
  int choosedSensor;
  int transmition_error;
  int whole_part, fractional_part;
  int thread_information[2];
  char availableSensors[] = {0x20};
  char dataToSend[2], buffer[2];  // see protocol.md file
  pthread_t monitoring_thread;

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
  if (request != 0) {           // if the user don't quit
    openPort(&fileDescriptor);  // Opens the serial port
    if (configureSerialPort(fileDescriptor))
      return 1;  // quit the program if cant configure port

    dataToSend[1] = chooseSensor();  // Second byte of the comunication is the
                                     // sensor addres;
  }

  switch (request) {
    case 0:
      printf("Finishing...\n");
      break;
    case 1:
      dataToSend[0] = 0x00;
      transmition_error = handleTransmission(&fileDescriptor, dataToSend, buffer);
      if (transmition_error) {
        printf("An error occourred!\n");
        return 1;
      }
      if (buffer[1] == 0x10)
        printf("Sensor with problem!\n");
      else
        printf("Sensor working normally!\n");
      break;

    case 2:
      dataToSend[0] = 0x01;  // asking for the whole part from temperature
      transmition_error = handleTransmission(&fileDescriptor, dataToSend, buffer);
      if (transmition_error) {
        printf("An error occourred!\n");
        return 1;
      }
      whole_part = (int)buffer[1];
      dataToSend[0] = 0x02;  // asking for the fractional part from temperature
      transmition_error = handleTransmission(&fileDescriptor, dataToSend, buffer);
      if (transmition_error) {
        printf("An error occourred!\n");
        return 1;
      }
      fractional_part = (int)buffer[1];
      printf("Temperature of Sensor %d: \n", choosedSensor);
      printf("   %d.%d\n", whole_part, fractional_part);
      break;

    case 3:
      dataToSend[0] = 0x03;  // asking for the whole part from humidity
      transmition_error = handleTransmission(&fileDescriptor, dataToSend, buffer);
      if (transmition_error) {
        printf("An error occourred!\n");
        return 1;
      }
      whole_part = (int)buffer[1];
      dataToSend[0] = 0x04;  // asking for the fractional part from humidity
      transmition_error = handleTransmission(&fileDescriptor, dataToSend, buffer);
      if (transmition_error) {
        printf("An error occourred!\n");
        return 1;
      }
      fractional_part = (int)buffer[1];
      printf("Humidity of Sensor %d: \n", choosedSensor);
      printf("   %d.%d\n", whole_part, fractional_part);
      break;

    case 4:
	thread_information[1] = fileDescriptor;
	thread_information[1] = 1;
	dataToSend[0] = 0x05;
	system("clear");
	sendData(fileDescriptor, dataToSend, sizeof(dataToSend));
	sleep(1);
	// Create a thread for continuos monitoring
	if (pthread_create(&monitoring_thread, NULL, continuosMonitoring, thread_information) != 0){
		perror("pthread_create");
		break;
	}
	
	getchar();
	
	pthread_cancel(monitoring_thread);
	pthread_join(monitoring_thread, NULL);
	printf("Finishing...\n");
	
	dataToSend[0] = 0x07; 
	sendData(fileDescriptor, dataToSend, sizeof(dataToSend));
	sleep(1);
	system("clear");

        break;
    case 5:
	thread_information[0] = fileDescriptor;
	thread_information[1] = 0;
	dataToSend[0] = 0x06;
	system("clear");
	sendData(fileDescriptor, dataToSend, sizeof(dataToSend));
	sleep(1);
	// Create a thread for continuos monitoring
	if (pthread_create(&monitoring_thread, NULL, continuosMonitoring, thread_information) != 0){
		perror("pthread_create");
		break;
	}
	
	getchar();
	
	pthread_cancel(monitoring_thread);
	pthread_join(monitoring_thread, NULL);
	printf("Finishing...\n");

	dataToSend[0] = 0x08; 
	sendData(fileDescriptor, dataToSend, sizeof(dataToSend));
	sleep(1);
	system("clear");

        break;
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
  int bytes_written = sendData(*fd, dataToSend, sizeof(dataToSend));
  if (bytes_written > 0) {
    printf("Sent %d bytes:\n", bytes_written);  // debug
    for (int i = 0; i < bytes_written; i++) {
      printf("%c%s", dataToSend[i], (i == bytes_written - 1) ? "\n" : "");
    }
  } else {
    return 1;
  }
  int bytes_read = receiveData(*fd, buffer, sizeof(buffer));
  if (bytes_read > 0) {
    printf("Received %d bytes:\n", bytes_read);  // debug:
    for (int i = 0; i < bytes_read; i++) {
      printf("%c%s", buffer[i], (i == bytes_read - 1) ? "\n" : "");
    }
  } else {
    return 1;
  }
  return 0;
}





void *continuosMonitoring(void * arg){
	int * information = (int *) arg; // information 1 -> fd, information 2 -> type
	int whole_part;
	int fractional_part;
	char buffer[2];	
	
	while(1){

		receiveData(information[0], buffer, sizeof(buffer));
		whole_part = buffer[1];
		receiveData(information[0], buffer, sizeof(buffer));
		fractional_part = buffer[1];
	
		if (information[1]) { // 1 Stands for Temperature, 0 for Humidity
			printf("Actual temperature...\n");
		}
		else { 
			printf("Actual Humidity...\n");
		}
			
		printf("   %d.%d\n", whole_part, fractional_part);
		
		sleep(1);
	}
	return NULL;
}
