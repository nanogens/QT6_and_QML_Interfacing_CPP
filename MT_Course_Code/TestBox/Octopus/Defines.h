#ifndef DEFINES_H
#define DEFINES_H

// define statements
#define DLE 0x10
#define STX 0x02
#define SOURCE 0x00
#define DEST 0x88

#define FILLED_UART 1
#define CLEAR_UART 0

#define QUERY 0
#define SETTING 1
#define RESP 2

#define BUFFER_SIZE 256
#define ACCEPT_1BYTE_AT_A_TIME_ONLY 1
#define MAX_UART_ARRAY 100

// Array size - Page 1 (Streaming)
//#define MAX_INSTRUMENT_SERIALNUMBER_ARRAY 13
// Instrument
//#define MAX_INSTRUMENT_SERIALNUMBER_ARRAY 13
//#define MAX_INSTRUMENT_USAGE_ARRAY 2
// Memory
#define MAX_MEMORY_TOTAL_ARRAY 2
#define MAX_MEMORY_USED_ARRAY 2

#define MAX_CONFIGURATION_SURFACEPRESSURE_ARRAY 2

// Array sizes - Page 2 (Configuration)
// Version
#define MAX_VERSION_FW_ARRAY 2
#define MAX_VERSION_SW_ARRAY 2
#define MAX_VERSION_RES_ARRAY 4
// Status
#define MAX_STATUS_RES_ARRAY 2
// Instrument
#define MAX_INSTRUMENT_SERIALNUMBER_ARRAY 13
#define MAX_INSTRUMENT_USAGE_ARRAY 2
// Power
#define MAX_POWER_DURATION_ARRAY 2
#define MAX_POWER_POWERREMAINING_ARRAY 2
// Timing
#define MAX_TIMING_COMPCLOCK_FULLYEAR_ARRAY 2
#define MAX_TIMING_INSTRCLOCK_FULLYEAR_ARRAY 2
// Activation
#define MAX_ACTIVATION_START_FULLYEAR_ARRAY 2
#define MAX_ACTIVATION_END_FULLYEAR_ARRAY 2
// Notes
#define MAX_NOTES_NOTE_ARRAY 255
// Cloud
#define MAX_CLOUD_IP_ARRAY 13
#define MAX_CLOUD_LOGIN_ARRAY 25
#define MAX_CLOUD_PW_ARRAY 25
// Misc





// boxes
#define INSTRUMENT 0     // Cell A
#define COMMUNICATIONS 1 // Cell B
#define POWER 2          // Cell C
#define TIME 3           // Cell D
#define SAMPLING 4       // Cell E
#define ACTIVATION 5     // Cell F
#define NOTES 6          // Cell G
#define CLOUD 7          // Cell H
#define MISCELLENEOUS 8  // Cell I

// message header
#define DLE 0x10
#define STX 0x02
#define SOURCE 0x00
#define DEST 0x88

// Constants for pressureToDepthCm()
#define MBAR_TO_PA 100.0
#define FRESHWATER_DENSITY 1000.0
#define GRAVITY 9.80665

// Re-check this -- just using some bogus values for now
#define VERSION_QUERY_MSGLGT 0x07
#define VERSION_QUERY_MSGID 0x01

#define VERSION_RESP_MSGLGT 0x0D
#define VERSION_RESP_MSGID 0x02

// Re-check this -- just using some bogus values for now
#define STATUS_QUERY_MSGLGT 0x07
#define STATUS_QUERY_MSGID 0x03

#define STATUS_RESP_MSGLGT 0x0B
#define STATUS_RESP_MSGID 0x04

#define STATUS_SET_MSGLGT 0x0B
#define STATUS_SET_MSGID 0x05

// Re-check this -- just using some bogus values for now
#define INSTRUMENT_QUERY_MSGLGT 0x07
#define INSTRUMENT_QUERY_MSGID 0x06

#define INSTRUMENT_RESP_MSGLGT 0x19
#define INSTRUMENT_RESP_MSGID 0x07

#define INSTRUMENT_SET_MSGLGT 0x19
#define INSTRUMENT_SET_MSGID 0x08

// Re-check this -- just using some bogus values for now
#define COMMUNICATION_QUERY_MSGLGT 0x07
#define COMMUNICATION_QUERY_MSGID 0x09

#define COMMUNICATION_RESP_MSGLGT 0x0B
#define COMMUNICATION_RESP_MSGID 0x0A

#define COMMUNICATION_SET_MSGLGT 0x0B
#define COMMUNICATION_SET_MSGID 0x0B

// Re-check this -- just using some bogus values for now
#define POWER_QUERY_MSGLGT 0x07
#define POWER_QUERY_MSGID 0x0C

#define POWER_RESP_MSGLGT 0x0F
#define POWER_RESP_MSGID 0x0D

#define POWER_SET_MSGLGT 0x0F
#define POWER_SET_MSGID 0x0E

// Re-check this -- just using some bogus values for now
#define TIMING_QUERY_MSGLGT 0x07
#define TIMING_QUERY_MSGID 0x0F

#define TIMING_RESP_MSGLGT 0x1B
#define TIMING_RESP_MSGID 0x10

#define TIMING_SET_MSGLGT 0x1B
#define TIMING_SET_MSGID 0x11

// Re-check this -- just using some bogus values for now
#define SAMPLING_QUERY_MSGLGT 0x07
#define SAMPLING_QUERY_MSGID 0x12

#define SAMPLING_RESP_MSGLGT 0x0D
#define SAMPLING_RESP_MSGID 0x13

#define SAMPLING_SET_MSGLGT 0x0D
#define SAMPLING_SET_MSGID 0x14

// Re-check this -- just using some bogus values for now
#define ACTIVATION_QUERY_MSGLGT 0x07
#define ACTIVATION_QUERY_MSGID 0x15

#define ACTIVATION_RESP_MSGLGT 0x0D
#define ACTIVATION_RESP_MSGID 0x16

#define ACTIVATION_SET_MSGLGT 0x0D
#define ACTIVATION_SET_MSGID 0x17

// Re-check this -- just using some bogus values for now
#define NOTES_QUERY_MSGLGT 0x07
#define NOTES_QUERY_MSGID 0x18

#define NOTES_RESP_MSGLGT 0x29
#define NOTES_RESP_MSGID 0x19

#define NOTES_SET_MSGLGT 0x29
#define NOTES_SET_MSGID 0x1A

// Re-check this -- just using some bogus values for now
#define CLOUD_QUERY_MSGLGT 0x07
#define CLOUD_QUERY_MSGID 0x1B

#define CLOUD_RESP_MSGLGT 0x07
#define CLOUD_RESP_MSGID 0x0D

#define CLOUD_SET_MSGLGT 0x07
#define CLOUD_SET_MSGID 0x0D

// Re-check this -- just using some bogus values for now
#define MISC_QUERY_MSGLGT 0x07
#define MISC_QUERY_MSGID 0x1E

#define MISC_RESP_MSGLGT 0x0D
#define MISC_RESP_MSGID 0x1F

#define MISC_SET_MSGLGT 0x0D
#define MISC_SET_MSGID 0x20

// Re-check this -- just using some bogus values for now
#define CTD_VARIABLES_QUERY_MSGLGT 0x07
#define CTD_VARIABLES_QUERY_MSGID 0x21

#define CTD_VARIABLES_RESP_MSGLGT 0x07
#define CTD_VARIABLES_RESP_MSGID 0x22

#define CTD_VARIABLES_SET_MSGLGT 0x07
#define CTD_VARIABLES_SET_MSGID 0x23

// Re-check this -- just using some bogus values for now
#define CTD_READINGS_RAW_QUERY_MSGLGT 0x07
#define CTD_READINGS_RAW_QUERY_MSGID 0x24

#define CTD_READINGS_RAW_RESP_MSGLGT 0x07
#define CTD_READINGS_RAW_RESP_MSGID 0x25

// Re-check this -- just using some bogus values for now
#define CTD_READINGS_PROCESSED_QUERY_MSGLGT 0x07
#define CTD_READINGS_PROCESSED_QUERY_MSGID 0x26

#define CTD_READINGS_PROCESSED_RESP_MSGLGT 0x11
#define CTD_READINGS_PROCESSED_RESP_MSGID 0x27

// Re-check this -- just using some bogus values for now
#define SUBMERSIBLE_INFO_QUERY_MSGLGT 0x07
#define SUBMERSIBLE_INFO_QUERY_MSGID 0x28

#define SUBMERSIBLE_INFO_RESP_MSGLGT 0x4A
#define SUBMERSIBLE_INFO_RESP_MSGID 0x29


#endif // DEFINES_H
