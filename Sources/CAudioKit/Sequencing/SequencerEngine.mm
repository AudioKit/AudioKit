// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#import "TargetConditionals.h"

#if !TARGET_OS_TV

#include "SequencerEngine.h"
#include <vector>
#include <bitset>
#include <stdio.h>
#include <atomic>
#include "../../Internals/Utilities/RingBuffer.h"
#include "../../Internals/Utilities/AtomicDataPtr.h"
#define NOTEON 0x90
#define NOTEOFF 0x80

using AudioKit::RingBuffer;

/// NOTE: To support more than a single channel, RunningStatus can be made larger
/// e.g. typedef std::bitset<128 * 16> RunningStatus; would track 16 channels of notes
typedef std::bitset<128> RunningStatus;

struct SequencerEvent {
    bool notesOff = false;
    double seekPosition = NAN;
    double tempo = NAN;
};

struct SequencerData {
    double sampleRate = 44100;
    std::vector<SequenceEvent> events;
    SequenceSettings settings = {
        .maximumPlayCount = 0,
        .length = 4.0,
        .tempo = 120.0,
        .loopEnabled = true,
        .numberOfLoops = 0
    };

    AUScheduleMIDIEventBlock midiBlock = nullptr;
};

struct SequencerEngineImpl;

/// This uses another level of indirection to ensure that SequencerEngineImpl
/// is not destroyed while a render observer is still active.
struct SequencerEngine {
    std::shared_ptr<SequencerEngineImpl> impl;
};

struct SequencerEngineImpl {
    RunningStatus runningStatus;
    long positionInSamples = 0;
    UInt64 framesCounted = 0;
    std::atomic<bool> isStarted{false};

    AtomicDataPtr<SequencerData> data;

    RingBuffer<SequencerEvent> eventQueue;

    // Current position as reported to the UI.
    std::atomic<double> uiPosition{0};

    SequencerEngineImpl() {
        runningStatus.reset();
    }

    ~SequencerEngineImpl() {
        stopAllPlayingNotes();
    }

    int beatToSamples(double beat) const {
        return (int)(beat / data->settings.tempo * 60 * data->sampleRate);
    }

    long lengthInSamples() const {
        return beatToSamples(data->settings.length);
    }

    long positionModulo() const {
        long length = lengthInSamples();
        if (positionInSamples == 0 || length == 0) {
            return 0;
        } else if (positionInSamples < 0) {
            return positionInSamples;
        } else {
            return positionInSamples % length;
        }
    }

    double currentPositionInBeats() const {
        return (double)positionModulo() / data->sampleRate * (data->settings.tempo / 60);
    }

    bool validTriggerTime(double beat) {
        return true;
    }

    void sendMidiData(UInt8 status, UInt8 data1, UInt8 data2, int offset, double time) {
        if(data->midiBlock) {
            UInt8 midiBytes[3] = {status, data1, data2};
            updateRunningStatus(status, data1, data2);
            data->midiBlock(AUEventSampleTimeImmediate + offset, 0, 3, midiBytes);
        }
    }

    /// Update note playing status
    void updateRunningStatus(UInt8 status, UInt8 data1, UInt8 data2) {
        if(status == NOTEOFF) {
            runningStatus.set(data1, 0);
        }
        if(status == NOTEON) {
            runningStatus.set(data1, 1);
        }
    }

    /// Stop all notes whose running status is currently on
    /// If panic is set to true, a note-off message will be sent for all notes
    void stopAllPlayingNotes(bool panic = false) {
        if(runningStatus.any() || (panic == true)) {
            for(int i = (int)runningStatus.size() - 1; i >= 0; i--) {
                if(runningStatus[i] == 1 || (panic == true)) {
                    sendMidiData(NOTEOFF, (UInt8)i, 0, 1, 0);
                }
            }
        }
    }

    void stop() {
        isStarted = false;
        stopAllPlayingNotes();
    }

    void seekTo(double position) {
        positionInSamples = beatToSamples(position);
    }

    void processEvents() {

        eventQueue.popAll([this](const SequencerEvent& event) {
            if(event.notesOff) {
                stopAllPlayingNotes();
            }

            if(!isnan(event.seekPosition)) {
                seekTo(event.seekPosition);
            }

            if(!isnan(event.tempo)) {
                double lastPosition = currentPositionInBeats(); // 1) save where we are before we manipulate time
                data->settings.tempo = event.tempo;             // 2) manipulate time
                seekTo(lastPosition);                           // 3) go back to where we were before time manipulation
            }
        });

    }

    void process(AUAudioFrameCount frameCount) {

        data.update();
        processEvents();

        if (isStarted) {
            if (positionInSamples >= lengthInSamples()) {
                if (!data->settings.loopEnabled) { //stop if played enough
                    stop();
                    return;
                }
            }

            auto& events = data->events;

            long currentStartSample = positionModulo();
            long currentEndSample = currentStartSample + frameCount;

            for (auto& event : events) {
                // go through every event
                int triggerTime = beatToSamples(event.beat);

                if (currentEndSample > lengthInSamples() && data->settings.loopEnabled) {
                    // this buffer extends beyond the length of the loop and looping is on
                    int loopRestartInBuffer = (int)(lengthInSamples() - currentStartSample);
                    int samplesOfBufferForNewLoop = frameCount - loopRestartInBuffer;
                    if (triggerTime < samplesOfBufferForNewLoop) {
                        // this event would trigger early enough in the next loop that it should happen in this buffer
                        // ie. this buffer contains events from the previous loop, and the next loop
                        int offset = (int)triggerTime + loopRestartInBuffer;
                        sendMidiData(event.status, event.data1, event.data2,
                                     offset, event.beat);
                    }
                } else if (currentStartSample <= triggerTime && triggerTime < currentEndSample) {
                    // this event is supposed to trigger between currentStartSample and currentEndSample
                    int offset = (int)(triggerTime - currentStartSample);
                    sendMidiData(event.status, event.data1, event.data2,
                                 offset, event.beat);
                }
            }

            positionInSamples += frameCount;
        }
        framesCounted += frameCount;

        uiPosition = currentPositionInBeats();
    }
};

/// Creates the audio-thread-only state for the sequencer.
SequencerEngineRef akSequencerEngineCreate(void) {
    return new SequencerEngine { .impl = std::make_shared<SequencerEngineImpl>() };
}

void akSequencerEngineRelease(SequencerEngineRef engine) {
    engine->impl->stopAllPlayingNotes();
    delete engine;
}

/// Updates the sequence and returns a new render observer.
AURenderObserver akSequencerEngineUpdateSequence(SequencerEngineRef engine,
                                                 const SequenceEvent* eventsPtr,
                                                 size_t eventCount,
                                                 SequenceSettings settings,
                                                 double sampleRate,
                                                 AUScheduleMIDIEventBlock block) {

    // impl is captured in the render observer block.
    auto impl = engine->impl;

    auto data = new SequencerData;
    data->settings = settings;
    data->sampleRate = sampleRate;
    data->midiBlock = block;
    data->events = {eventsPtr, eventsPtr+eventCount};
    impl->data.set(data);

    return ^void(AudioUnitRenderActionFlags actionFlags,
                 const AudioTimeStamp *timestamp,
                 AUAudioFrameCount frameCount,
                 NSInteger outputBusNumber)
    {
        if (actionFlags != kAudioUnitRenderAction_PreRender) return;
        impl->process(frameCount);
    };
}

double akSequencerEngineGetPosition(SequencerEngineRef engine) {
    return engine->impl->uiPosition;
}

void akSequencerEngineSeekTo(SequencerEngineRef engine, double position) {
    SequencerEvent event;
    event.seekPosition = position;
    engine->impl->eventQueue.push(event);
}

void akSequencerEngineSetPlaying(SequencerEngineRef engine, bool playing) {
    engine->impl->isStarted = playing;
}

bool akSequencerEngineIsPlaying(SequencerEngineRef engine) {
    return engine->impl->isStarted;
}

void akSequencerEngineStopPlayingNotes(SequencerEngineRef engine) {
    SequencerEvent event;
    event.notesOff = true;
    engine->impl->eventQueue.push(event);
}

void akSequencerEngineSetTempo(SequencerEngineRef engine, double tempo) {
    SequencerEvent event;
    event.tempo = tempo;
    engine->impl->eventQueue.push(event);
}

#endif
