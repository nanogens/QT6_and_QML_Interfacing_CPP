#ifndef DEFINES_H
#define DEFINES_H

// define statements
#define BUFFER_SIZE 256

// array sizes
#define ARRAY_SERIALNUMBER_MAX 13
#define ARRAY_IP_MAX 11

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

// Messages
#define INSTRUMENT_QUERY_MSGLGT 0x07
#define INSTRUMENT_QUERY_MSGID 0x06

#define INSTRUMENT_RESP_MSGLGT 0x17
#define INSTRUMENT_RESP_MSGID 0x07

#define INSTRUMENT_SET_MSGLGT 0x17
#define INSTRUMENT_SET_MSGID 0x08

// Re-check this -- just using some bogus values for now
#define COMMUNICATIONS_QUERY_MSGLGT 0x07
#define COMMUNICATIONS_QUERY_MSGID 0x09

#define COMMUNICATIONS_RESP_MSGLGT 0x17
#define COMMUNICATIONS_RESP_MSGID 0x0A

#define COMMUNICATIONS_SET_MSGLGT 0x07
#define COMMUNICATIONS_SET_MSGID 0x0B

// Re-check this -- just using some bogus values for now
#define POWER_QUERY_MSGLGT 0x07
#define POWER_QUERY_MSGID 0x0C

#define POWER_RESP_MSGLGT 0x17
#define POWER_RESP_MSGID 0x0D

#define POWER_SET_MSGLGT 0x07
#define POWER_SET_MSGID 0x0E

// Re-check this -- just using some bogus values for now
#define TIME_QUERY_MSGLGT 0x07
#define TIME_QUERY_MSGID 0x0F

#define TIME_RESP_MSGLGT 0x17
#define TIME_RESP_MSGID 0x10

#define TIME_SET_MSGLGT 0x07
#define TIME_SET_MSGID 0x11

// Re-check this -- just using some bogus values for now
#define SAMPLING_QUERY_MSGLGT 0x07
#define SAMPLING_QUERY_MSGID 0x12

#define SAMPLING_RESP_MSGLGT 0x17
#define SAMPLING_RESP_MSGID 0x13

#define SAMPLING_SET_MSGLGT 0x07
#define SAMPLING_SET_MSGID 0x14

// Re-check this -- just using some bogus values for now
#define ACTIVITION_QUERY_MSGLGT 0x07
#define ACTIVITION_QUERY_MSGID 0x15

#define ACTIVITION_RESP_MSGLGT 0x17
#define ACTIVITION_RESP_MSGID 0x16

#define ACTIVITION_SET_MSGLGT 0x07
#define ACTIVITION_SET_MSGID 0x17

// Re-check this -- just using some bogus values for now
#define NOTES_QUERY_MSGLGT 0x07
#define NOTES_QUERY_MSGID 0x18

#define NOTES_RESP_MSGLGT 0x07
#define NOTES_RESP_MSGID 0x19

#define NOTES_SET_MSGLGT 0x07
#define NOTES_SET_MSGID 0x1A

// Re-check this -- just using some bogus values for now
#define CLOUD_QUERY_MSGLGT 0x07
#define CLOUD_QUERY_MSGID 0x1B

#define CLOUD_RESP_MSGLGT 0x07
#define CLOUD_RESP_MSGID 0x1C

#define CLOUD_SET_MSGLGT 0x07
#define CLOUD_SET_MSGID 0x1D

// Re-check this -- just using some bogus values for now
#define MISC_QUERY_MSGLGT 0x07
#define MISC_QUERY_MSGID 0x1E

#define MISC_RESP_MSGLGT 0x07
#define MISC_RESP_MSGID 0x1F

#define MISC_SET_MSGLGT 0x07
#define MISC_SET_MSGID 0x20



#endif // DEFINES_H
