// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import <AVFoundation/AVFoundation.h>
#import "Interop.h"

/// Sequence Event
typedef struct {
    uint8_t status;
    uint8_t data1;
    uint8_t data2;
    double beat;
} SequenceEvent;

/// Sequence Note
typedef struct {
    SequenceEvent noteOn;
    SequenceEvent noteOff;
} SequenceNote;

/// Sequence Settings
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

/// Release ownership of the sequencer. Sequencer is deallocated when no render observers are live.
AK_API void akSequencerEngineRelease(SequencerEngineRef engine);

/// Updates the sequence and returns a new render observer.
AK_API AURenderObserver akSequencerEngineUpdateSequence(SequencerEngineRef engine,
                                                        const SequenceEvent* events,
                                                        size_t eventCount,
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

/// Update sequencer tempo.
AK_API void akSequencerEngineSetTempo(SequencerEngineRef engine, double tempo);
