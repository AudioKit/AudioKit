#pragma once

#if __APPLE__
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#else // __APPLE__
#include <stdint.h>
typedef double Float64;
typedef uint64_t UInt64;
typedef uint32_t UInt32;
typedef int16_t SInt16;
typedef uint8_t UInt8;

typedef float AUValue;
typedef uint64_t AUParameterAddress;
struct AUInternalRenderBlock {
  // TODO
};
typedef struct AudioBuffer {
  UInt32 mNumberChannels;
  UInt32 mDataByteSize;
  void* mData;
} AudioBuffer;
typedef struct AVAudioPCMBuffer {
  UInt32 mNumberChannels;
  UInt32 mDataByteSize;
  void* mData;
} AVAudioPCMBuffer;
typedef uint32_t	AVAudioChannelCount;
struct AVAudioFormat {
  AVAudioChannelCount channelCount;
  double sampleRate;
};
typedef struct AudioBufferList {
  UInt32 mNumberBuffers;
  AudioBuffer mBuffers[1];
} AudioBufferList;
typedef int64_t AUEventSampleTime;
typedef uint32_t AUAudioFrameCount;
typedef struct SMPTETime {
  UInt64 mCounter;
  UInt32 mType;
  UInt32 mFlags;
  SInt16 mHours;
  SInt16 mMinutes;
  SInt16 mSeconds;
  SInt16 mFrames;
} SMPTETime;
typedef struct AudioTimeStamp {
  Float64 mSampleTime;
  UInt64 mHostTime;
  Float64 mRateScalar;
  UInt64 mWordClockTime;
  SMPTETime mSMPTETime;
  UInt32 mFlags;
  UInt32 mReserved;
} AudioTimeStamp;

// forward declaration
union AURenderEvent;

// =================================================================================================
// Realtime events - parameters and MIDI

typedef enum AURenderEventType_t {
  AURenderEventParameter		= 1,
  AURenderEventParameterRamp	= 2,
  AURenderEventMIDI			= 8,
  AURenderEventMIDISysEx		= 9
} AURenderEventType;

typedef struct AURenderEventHeader {
  union AURenderEvent *next;
  AUEventSampleTime		eventSampleTime;
  AURenderEventType		eventType;
  uint8_t					reserved;
} AURenderEventHeader;

/// Describes a scheduled parameter change.
typedef struct AUParameterEvent {
  union AURenderEvent *next;
  AUEventSampleTime		eventSampleTime;
  AURenderEventType		eventType;
  uint8_t					reserved[3];
  AUAudioFrameCount		rampDurationSampleFrames;
  AUParameterAddress		parameterAddress;
  AUValue					value;
} AUParameterEvent;

typedef struct AUMIDIEvent {
  union AURenderEvent *next;
  AUEventSampleTime		eventSampleTime;
  AURenderEventType		eventType;
  uint8_t					reserved;
  uint16_t				length;
  uint8_t					cable;
  uint8_t					data[3];
} AUMIDIEvent;

typedef union AURenderEvent {
  AURenderEventHeader		head;
  AUParameterEvent		parameter;
  AUMIDIEvent				MIDI;
} AURenderEvent;

#endif // __APPLE__
