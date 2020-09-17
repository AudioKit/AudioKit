// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import <AVFoundation/AVFoundation.h>
#import "Interop.h"

typedef struct {
    uint8_t status;
    uint8_t data1;
    uint8_t data2;
    double beat;
} SequenceEvent;

typedef struct {
    SequenceEvent noteOn;
    SequenceEvent noteOff;
} SequenceNote;

typedef struct {
    int maximumPlayCount;
    double length;
    double tempo;
    bool loopEnabled;
    uint numberOfLoops;
} SequenceSettings;

typedef struct SequencerEngine* SequencerEngineRef;

/// Creates the audio-thread-only state for the sequencer.
AK_API SequencerEngineRef akSequencerEngineCreate(void);

/// Deallocate the sequencer.
AK_API void akSequencerEngineDestroy(SequencerEngineRef engine);

/// Updates the sequence and returns a new render observer.
AK_API AURenderObserver SequencerEngineUpdateSequence(SequencerEngineRef engine,
                                                        const SequenceEvent* events,
                                                        size_t eventCount,
                                                        const SequenceNote* notes,
                                                        size_t noteCount,
                                                        SequenceSettings settings,
                                                        double sampleRate,
                                                        AUScheduleMIDIEventBlock block);

/// Returns the sequencer playhead position in beats.
AK_API double akSequencerEngineGetPosition(SequencerEngineRef engine);

/// Move the playhead to a location in beats.
AK_API void akSequencerEngineSeekTo(SequencerEngineRef engine, double position);

AK_API void akSequencerEngineSetPlaying(SequencerEngineRef engine, bool playing);

AK_API bool akSequencerEngineIsPlaying(SequencerEngineRef engine);

/// Stop all notes currently playing.
AK_API void akSequencerEngineStopPlayingNotes(SequencerEngineRef engine);
