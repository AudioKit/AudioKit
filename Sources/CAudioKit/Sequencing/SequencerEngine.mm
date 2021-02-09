// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#import "TargetConditionals.h"

#if !TARGET_OS_TV

#include "SequencerEngine.h"
#include <vector>
#include <stdio.h>
#include <atomic>
#include "../../Internals/Utilities/readerwriterqueue.h"

#define NOTEON 0x90
#define NOTEOFF 0x80

using moodycamel::ReaderWriterQueue;

struct SequencerEvent {
    bool notesOff = false;
    double seekPosition = NAN;
};

struct SequencerEngine {
    std::vector<SequenceNote> playingNotes;
    long positionInSamples = 0;
    UInt64 framesCounted = 0;
    SequenceSettings settings = {0, 4.0, 120.0, true, 0};
    double sampleRate = 44100.0;
    std::atomic<bool> isStarted{false};
    AUScheduleMIDIEventBlock midiBlock = nullptr;

    ReaderWriterQueue<SequencerEvent> eventQueue;

    // Current position as reported to the UI.
    std::atomic<double> uiPosition{0};

    SequencerEngine() {
        // Try to reserve enough notes so allocation on the DSP
        // thread is unlikely. (This is not ideal)
        playingNotes.reserve(256);
    }

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
            midiBlock(AUEventSampleTimeImmediate + offset, 0, 3, midiBytes);
        }
    }

    void addPlayingNote(SequenceNote note, int offset) {
        if (note.noteOn.data2 > 0) {
            sendMidiData(note.noteOn.status, note.noteOn.data1, note.noteOn.data2, offset, note.noteOn.beat);
            playingNotes.push_back(note);
        } else {
            sendMidiData(note.noteOff.status, note.noteOff.data1, note.noteOff.data2, offset, note.noteOn.beat);
        }
    }

    void stopPlayingNote(SequenceNote note, int offset, int index) {
        sendMidiData(note.noteOff.status, note.noteOff.data1, note.noteOff.data2, offset, note.noteOff.beat);
        playingNotes.erase(playingNotes.begin() + index);
    }

    void stop() {
        isStarted = false;
    }

    void seekTo(double position) {
        positionInSamples = beatToSamples(position);
    }

    void processEvents() {

        SequencerEvent event;
        while(eventQueue.try_dequeue(event)) {
            if(event.notesOff) {
                while (playingNotes.size() > 0) {
                    stopPlayingNote(playingNotes[0], 0, 0);
                }
            }

            if(!isnan(event.seekPosition)) {
                seekTo(event.seekPosition);
            }
        }

    }

    void process(const std::vector<SequenceEvent>& events,
                 const std::vector<SequenceNote>& notes,
                 AUAudioFrameCount frameCount) {

        processEvents();

        if (isStarted) {
            if (positionInSamples >= lengthInSamples()){
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
                if (currentStartSample <= triggerTime && triggerTime < currentEndSample) {
                    // this event is supposed to trigger between currentStartSample and currentEndSample
                    int offset = (int)(triggerTime - currentStartSample);
                    sendMidiData(events[i].status, events[i].data1, events[i].data2,
                                 offset, events[i].beat);
                } else if (currentEndSample > lengthInSamples() && settings.loopEnabled) {
                    // this buffer extends beyond the length of the loop and looping is on
                    int loopRestartInBuffer = (int)(lengthInSamples() - currentStartSample);
                    int samplesOfBufferForNewLoop = frameCount - loopRestartInBuffer;
                    if (triggerTime < samplesOfBufferForNewLoop) {
                        // this event would trigger early enough in the next loop that it should happen in this buffer
                        // ie. this buffer contains events from the previous loop, and the next loop
                        int offset = (int)triggerTime + loopRestartInBuffer;
                        sendMidiData(events[i].status, events[i].data1, events[i].data2,
                                     offset, events[i].beat);
                    }
                }
            }
            
            // Check the playing notes for note offs
            int i = 0;
            while (i < playingNotes.size()) {
                int triggerTime = beatToSamples(playingNotes[i].noteOff.beat);
                if (currentStartSample <= triggerTime && triggerTime < currentEndSample) {
                    int offset = (int)(triggerTime - currentStartSample);
                    stopPlayingNote(playingNotes[i], offset, i);
                    continue;
                }

                if (currentEndSample > lengthInSamples() && settings.loopEnabled) {
                    int loopRestartInBuffer = (int)(lengthInSamples() - currentStartSample);
                    int samplesOfBufferForNewLoop = frameCount - loopRestartInBuffer;
                    if (triggerTime < samplesOfBufferForNewLoop) {
                        int offset = (int)triggerTime + loopRestartInBuffer;
                        stopPlayingNote(playingNotes[i], offset, i);
                        continue;
                    }
                }
                i++;
            }

            // Check scheduled notes for note ons
            for (int i = 0; i < notes.size(); i++) {
                int triggerTime = beatToSamples(notes[i].noteOn.beat);
                if (currentStartSample <= triggerTime && triggerTime < currentEndSample) {
                    int offset = (int)(triggerTime - currentStartSample);
                    addPlayingNote(notes[i], offset);
                } else if (currentEndSample > lengthInSamples() && settings.loopEnabled) {
                    int loopRestartInBuffer = (int)(lengthInSamples() - currentStartSample);
                    int samplesOfBufferForNewLoop = frameCount - loopRestartInBuffer;
                    if (triggerTime < samplesOfBufferForNewLoop) {
                        int offset = (int)triggerTime + loopRestartInBuffer;
                        addPlayingNote(notes[i], offset);
                    }
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
                                                 const SequenceNote* notesPtr,
                                                 size_t noteCount,
                                                 SequenceSettings settings,
                                                 double sampleRate,
                                                 AUScheduleMIDIEventBlock block) {

    const std::vector<SequenceEvent> events{eventsPtr, eventsPtr+eventCount};
    const std::vector<SequenceNote> notes{notesPtr, notesPtr+noteCount};

    return ^void(AudioUnitRenderActionFlags actionFlags,
                 const AudioTimeStamp *timestamp,
                 AUAudioFrameCount frameCount,
                 NSInteger outputBusNumber)
    {
        if (actionFlags != kAudioUnitRenderAction_PreRender) return;

        engine->sampleRate = sampleRate;
        engine->midiBlock = block;
        engine->settings = settings;
        engine->process(events, notes, frameCount);
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
