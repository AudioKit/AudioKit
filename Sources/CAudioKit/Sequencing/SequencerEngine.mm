// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#import "TargetConditionals.h"

#if !TARGET_OS_TV

#include "SequencerEngine.h"
#include <vector>
#include <bitset>
#include <stdio.h>
#include <atomic>
#include "../../Internals/Utilities/readerwriterqueue.h"

#define NOTEON 0x90
#define NOTEOFF 0x80

using moodycamel::ReaderWriterQueue;

typedef std::bitset<128> RunningStatus;

struct SequencerEvent {
    bool notesOff = false;
    double seekPosition = NAN;
};

struct SequencerEngine {
    RunningStatus runningStatus;
    long positionInSamples = 0;
    UInt64 framesCounted = 0;
    SequenceSettings settings = {0, 4.0, 120.0, true, 0};
    double sampleRate = 44100.0;
    std::atomic<bool> isStarted{false};
    AUScheduleMIDIEventBlock midiBlock = nullptr;

    ReaderWriterQueue<SequencerEvent> eventQueue;

    // Current position as reported to the UI.
    std::atomic<double> uiPosition{0};

    SequencerEngine() {}

    int beatToSamples(double beat) const {
        return (int)(beat / settings.tempo * 60 * sampleRate);
    }

    long lengthInSamples() const {
        return beatToSamples(settings.length);
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
        return (double)positionModulo() / sampleRate * (settings.tempo / 60);
    }

    bool validTriggerTime(double beat) {
        return true;
    }

    void sendMidiData(UInt8 status, UInt8 data1, UInt8 data2, int offset, double time) {
        if(midiBlock) {
            UInt8 midiBytes[3] = {status, data1, data2};
            int noteOffOffset = 0;
//            if(status == NOTEOFF) {
//                noteOffOffset = - 1;
//            }
            int adjustedOffset = (int)(AUEventSampleTimeImmediate + offset + noteOffOffset);
            printf("%05i status: %x note: %i \n", adjustedOffset, status, data1);
            midiBlock(adjustedOffset, 0, 3, midiBytes);
        }
    }

    /// Keeps a bitset up to date with note playing status
    void updateRunningStatus(UInt8 status, UInt8 data1, UInt8 data2) {
        if(status == NOTEOFF) {
            runningStatus.set(data1, 0);
        }
        if(status == NOTEON) {
            runningStatus.set(data1, 1);
        }
    }

    /// Stops all notes tracked by running status as playing
    /// If panic arg is set to true, this will send a note off msg for all notes
    void stopAllPlayingNotes(bool panic = false) {
        if(runningStatus.any() || panic) {
            for(int i = (int)runningStatus.size(); i >= 0; i--) {
                if(runningStatus[i] == 1 || panic) {
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

        SequencerEvent event;
        while(eventQueue.try_dequeue(event)) {
            if(event.notesOff) {
                stopAllPlayingNotes();
            }

            if(!isnan(event.seekPosition)) {
                seekTo(event.seekPosition);
            }
        }

    }

    void process(const std::vector<SequenceEvent>& events, AUAudioFrameCount frameCount) {

        processEvents();

        if (isStarted) {
            if (positionInSamples >= lengthInSamples()) {
                if (!settings.loopEnabled) { //stop if played enough
                    stop();
                    return;
                }
            }

            long currentStartSample = positionModulo();
            long currentEndSample = currentStartSample + frameCount;

            for (int i = 0; i < events.size(); i++) {
                // go through every event
                int triggerTime = beatToSamples(events[i].beat);

                if (currentEndSample > lengthInSamples() && settings.loopEnabled) {
                // this buffer extends beyond the length of the loop and looping is on
                int loopRestartInBuffer = (int)(lengthInSamples() - currentStartSample);
                int samplesOfBufferForNewLoop = frameCount - loopRestartInBuffer;
                    if (triggerTime < samplesOfBufferForNewLoop) {
                        // this event would trigger early enough in the next loop that it should happen in this buffer
                        // ie. this buffer contains events from the previous loop, and the next loop
                        int offset = (int)triggerTime + loopRestartInBuffer;
                        printf("sent - in next loop check\n");
                        sendMidiData(events[i].status, events[i].data1, events[i].data2,
                                     offset, events[i].beat);
                    } else {
                        printf("skipped in loop check\n");
                    }
                } else if (currentStartSample <= triggerTime && triggerTime < currentEndSample) {
                    // this event is supposed to trigger between currentStartSample and currentEndSample
                    int offset = (int)(triggerTime - currentStartSample);
                    printf("sent - contained in buffer\n");
                    sendMidiData(events[i].status, events[i].data1, events[i].data2,
                                 offset, events[i].beat);
                } else {
//                    printf("skipped\n");
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
    return new SequencerEngine;
}

void akSequencerEngineDestroy(SequencerEngineRef engine) {
    delete engine;
}

/// Updates the sequence and returns a new render observer.
AURenderObserver SequencerEngineUpdateSequence(SequencerEngineRef engine,
                                                 const SequenceEvent* eventsPtr,
                                                 size_t eventCount,
                                                 SequenceSettings settings,
                                                 double sampleRate,
                                                 AUScheduleMIDIEventBlock block) {

    const std::vector<SequenceEvent> events{eventsPtr, eventsPtr+eventCount};
    return ^void(AudioUnitRenderActionFlags actionFlags,
                 const AudioTimeStamp *timestamp,
                 AUAudioFrameCount frameCount,
                 NSInteger outputBusNumber)
    {
        if (actionFlags != kAudioUnitRenderAction_PreRender) return;

        engine->sampleRate = sampleRate;
        engine->midiBlock = block;
        engine->settings = settings;
        engine->process(events, frameCount);
    };
}

double akSequencerEngineGetPosition(SequencerEngineRef engine) {
    return engine->uiPosition;
}

void akSequencerEngineSeekTo(SequencerEngineRef engine, double position) {
    SequencerEvent event;
    event.seekPosition = position;
    engine->eventQueue.enqueue(event);
}

void akSequencerEngineSetPlaying(SequencerEngineRef engine, bool playing) {
    engine->isStarted = playing;
}

bool akSequencerEngineIsPlaying(SequencerEngineRef engine) {
    return engine->isStarted;
}

void akSequencerEngineStopPlayingNotes(SequencerEngineRef engine) {
    SequencerEvent event;
    event.notesOff = true;
    engine->eventQueue.enqueue(event);
}

#endif
