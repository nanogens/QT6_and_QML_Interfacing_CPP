#ifndef DEFINES_H
#define DEFINES_H

// define statements
#define BUFFER_SIZE 256

// array sizes
#define ARRAY_SERIALNUMBER_MAX 13
#define ARRAY_IP_MAX 11

// boxes
#define INSTRUMENT 1
#define COMMUNICATIONS 2
#define POWER 3
#define TIME 4
#define SAMPLING 5
#define ACTIVATION 6
#define NOTES 7
#define CLOUD 8
#define MISCELLENEOUS 9

// message header
#define DLE 0x10
#define STX 0x02
#define SOURCE 0x00
#define DEST 0x88

// Messages
#define INSTRUMENT_QUERY_MSGLGT 0x07
#define INSTRUMENT_QUERY_MSGID 0x08

#define INSTRUMENT_SET_MSGLGT 0x17
#define INSTRUMENT_SET_MSGID 0x09

#define INSTRUMENT_RESP_MSGLGT 0x17
#define INSTRUMENT_RESP_MSGID 0x0A


// Re-check this -- just using some bogus values for now
#define COMMUNICATIONS_QUERY_MSGLGT 0x07
#define COMMUNICATIONS_QUERY_MSGID 0x0B

#define COMMUNICATIONS_SET_MSGLGT 0x07
#define COMMUNICATIONS_SET_MSGID 0x0C

#define COMMUNICATIONS_RESP_MSGLGT 0x17
#define COMMUNICATIONS_RESP_MSGID 0x0D

// Re-check this -- just using some bogus values for now
#define POWER_QUERY_MSGLGT 0x07
#define POWER_QUERY_MSGID 0x0E

#define POWER_SET_MSGLGT 0x07
#define POWER_SET_MSGID 0x0F

#define POWER_RESP_MSGLGT 0x17
#define POWER_RESP_MSGID 0x10


#endif // DEFINES_H
