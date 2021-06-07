// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

/// Pointer to an instance of an DSPBase subclass
typedef struct DSPBase* DSPRef;

#ifdef __cplusplus
#define AK_API extern "C"
#else
#define AK_API
#endif

/// MIDI Constants
#define MIDI_NOTE_ON 0x90
#define MIDI_NOTE_OFF 0x80
#define MIDI_CONTINUOUS_CONTROLLER 0xB0
