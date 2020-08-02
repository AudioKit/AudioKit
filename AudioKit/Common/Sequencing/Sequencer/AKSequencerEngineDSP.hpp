// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import <AVFoundation/AVFoundation.h>
#import "AKInterop.h"

typedef NS_ENUM(AUParameterAddress, AKSequencerEngineParameter) {
    AKSequencerEngineParameterTempo,
    AKSequencerEngineParameterLength,
    AKSequencerEngineParameterMaximumPlayCount,
    AKSequencerEngineParameterPosition,
    AKSequencerEngineParameterLoopEnabled
};

typedef struct {
    uint8_t status;
    uint8_t data1;
    uint8_t data2;
    double beat;
} AKSequenceEvent;

typedef struct {
    AKSequenceEvent noteOn;
    AKSequenceEvent noteOff;
} AKSequenceNote;

AK_API AKDSPRef akAKSequencerEngineCreateDSP(void);
AK_API void sequencerEngineUpdateSequence(AKDSPRef dsp,
                                          const AKSequenceEvent* events,
                                          size_t eventCount,
                                          const AKSequenceNote* notes,
                                          size_t noteCount);
AK_API void sequencerEngineStopPlayingNotes(AKDSPRef dsp);

AK_API void sequencerEngineSetAUTarget(AKDSPRef dsp, AudioUnit audioUnit);
