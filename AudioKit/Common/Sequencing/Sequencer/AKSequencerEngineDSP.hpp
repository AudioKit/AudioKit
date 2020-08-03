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

typedef struct {
    int maximumPlayCount;
    double length;
    double tempo;
    bool loopEnabled;
    uint numberOfLoops;
} AKSequenceSettings;

typedef struct AKSequencerEngine* AKSequencerEngineRef;

/// Creates the audio-thread-only state for the sequencer.
AK_API AKSequencerEngineRef AKSequencerEngineCreate(void);

/// Deallocate the sequencer.
AK_API void AKSequencerEngineDestroy(AKSequencerEngineRef engine);

/// Updates the sequence and returns a new render observer.
AK_API AURenderObserver AKSequencerEngineUpdateSequence(AKSequencerEngineRef engine,
                                                        const AKSequenceEvent* events,
                                                        size_t eventCount,
                                                        const AKSequenceNote* notes,
                                                        size_t noteCount,
                                                        AKSequenceSettings settings,
                                                        double sampleRate,
                                                        AUScheduleMIDIEventBlock block);

/// Returns the sequencer playhead position in beats.
AK_API double AKSequencerEngineGetPosition(AKSequencerEngineRef engine);

/// Move the playhead to a location in beats.
AK_API void AKSequencerEngineSeekTo(AKSequencerEngineRef engine, double position);

AK_API void AKSequencerEngineSetPlaying(AKSequencerEngineRef engine, bool playing);

/// Stop all notes currently playing.
AK_API void AKSequencerEngineStopPlayingNotes(AKSequencerEngineRef engine);
