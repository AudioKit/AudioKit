// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import <AVFoundation/AVFoundation.h>
#import "AKInterop.h"

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

typedef struct {
    int maximumPlayCount;
    double length;
    double tempo;
    bool loopEnabled;
    uint numberOfLoops;
} AKSequenceSettings;

typedef struct AKSequencerEngine* AKSequencerEngineRef;

/// Creates the audio-thread-only state for the sequencer.
AK_API AKSequencerEngineRef akSequencerEngineCreate(void);

/// Deallocate the sequencer.
AK_API void akSequencerEngineDestroy(AKSequencerEngineRef engine);

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
AK_API double akSequencerEngineGetPosition(AKSequencerEngineRef engine);

/// Move the playhead to a location in beats.
AK_API void akSequencerEngineSeekTo(AKSequencerEngineRef engine, double position);

AK_API void akSequencerEngineSetPlaying(AKSequencerEngineRef engine, bool playing);

AK_API bool akSequencerEngineIsPlaying(AKSequencerEngineRef engine);

/// Stop all notes currently playing.
AK_API void akSequencerEngineStopPlayingNotes(AKSequencerEngineRef engine);
