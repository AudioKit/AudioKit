// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#import "TargetConditionals.h"

#if !TARGET_OS_TV

#include "AKSequencerEngineDSP.hpp"
#include "AKDSPBase.hpp"
#include <vector>
#include <stdio.h>
#include <atomic>

#define NOTEON 0x90
#define NOTEOFF 0x80

class AKSequencerEngineDSP : public AKDSPBase {

    struct Sequence {
        std::vector<AKSequenceEvent> events;
        std::vector<AKSequenceNote> notes;

        // DSP thread sets this to true when finished with the sequence.
        bool collect = false;
    };

public:

    AKSequencerEngineDSP() {
        // Try to reserve enough notes so allocation on the DSP
        // thread is unlikely. (This is not ideal)
        playingNotes.reserve(256);
    }

    void setTargetAU(AudioUnit target) {
        targetAU = target;
    }

    void seekTo(double position) {
        positionInSamples = beatToSamples(position);
    }

    void setTempo(double newValue) {
        double lastPosition = currentPositionInBeats(); // 1) save where we are before we manipulate time
        tempo = newValue;                               // 2) manipulate time
        seekTo(lastPosition);                           // 3) go back to where we were before time manipulation
    }

    void setStartPoint(float value) {
        startPoint = value;
    }

    void addPlayingNote(AKSequenceNote note, int offset) {
        if (note.noteOn.data2 > 0) {
            sendMidiData(note.noteOn.status, note.noteOn.data1, note.noteOn.data2, offset, note.noteOn.beat);
            playingNotes.push_back(note);
        } else {
            sendMidiData(note.noteOff.status, note.noteOff.data1, note.noteOff.data2, offset, note.noteOn.beat);
        }
    }

    void stopPlayingNote(AKSequenceNote note, int offset, int index) {
        sendMidiData(note.noteOff.status, note.noteOff.data1, note.noteOff.data2, offset, note.noteOff.beat);
        playingNotes.erase(playingNotes.begin() + index);
    }

    void setParameter(AUParameterAddress address, AUValue value, bool immediate) override {
        switch (address) {
            case AKSequencerEngineParameterTempo:
                setTempo(value);
                break;
            case AKSequencerEngineParameterLength:
                length = value;
                break;
            case AKSequencerEngineParameterMaximumPlayCount:
                maximumPlayCount = value;
                break;
            case AKSequencerEngineParameterPosition:
                seekTo(value);
                break;
            case AKSequencerEngineParameterLoopEnabled:
                loopEnabled = value > 0.5f;
                break;
        }
    }

    AUValue getParameter(AUParameterAddress address) override {
        switch (address) {
            case AKSequencerEngineParameterTempo:
                return tempo;
            case AKSequencerEngineParameterLength:
                return length;
            case AKSequencerEngineParameterMaximumPlayCount:
                return maximumPlayCount;
                break;
            case AKSequencerEngineParameterPosition:
                return currentPositionInBeats();
                break;
            case AKSequencerEngineParameterLoopEnabled:
                return loopEnabled ? 1.f : 0.f;
            default:
                return 0.f;
        }
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        if(notesOff) {
            while (playingNotes.size() > 0) {
                stopPlayingNote(playingNotes[0], 0, 0);
            }
            notesOff = false;
        }

        if (isStarted) {
            if (positionInSamples >= lengthInSamples()){
                if (!loopEnabled) { //stop if played enough
                    stop();
                    return;
                }
            }
            long currentStartSample = positionModulo();
            long currentEndSample = currentStartSample + frameCount;
            auto seq = getDSPSequence();
            if(seq) {

                const auto& events = seq->events;
                const auto& notes = seq->notes;

                for (int i = 0; i < events.size(); i++) {
                    // go through every event
                    int triggerTime = beatToSamples(seq->events[i].beat);
                    if (currentStartSample <= triggerTime && triggerTime < currentEndSample) {
                        // this event is supposed to trigger between currentStartSample and currentEndSample
                        int offset = (int)(triggerTime - currentStartSample);
                        sendMidiData(events[i].status, events[i].data1, events[i].data2,
                                     offset, events[i].beat);
                    } else if (currentEndSample > lengthInSamples() && loopEnabled) {
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

                    if (currentEndSample > lengthInSamples() && loopEnabled) {
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
                    } else if (currentEndSample > lengthInSamples() && loopEnabled) {
                        int loopRestartInBuffer = (int)(lengthInSamples() - currentStartSample);
                        int samplesOfBufferForNewLoop = frameCount - loopRestartInBuffer;
                        if (triggerTime < samplesOfBufferForNewLoop) {
                            int offset = (int)triggerTime + loopRestartInBuffer;
                            addPlayingNote(notes[i], offset);
                        }
                    }
                }
            }

            positionInSamples += frameCount;
        }
        framesCounted += frameCount;

        // Zero the output.
        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            for (int channel = 0; channel < channelCount; ++channel) {
                float *out = (float *)outputBufferLists[0]->mBuffers[channel].mData + frameOffset;
                *out = 0.0;
            }
        }
    }

    void updateSequence(const AKSequenceEvent* events, size_t eventCount,
                        const AKSequenceNote* notes, size_t noteCount) {

        sequence.events.resize(eventCount);
        sequence.notes.resize(noteCount);

        std::copy(events, events+eventCount, sequence.events.begin());
        std::copy(notes, notes+noteCount, sequence.notes.begin());

        updateDSPSequence();
    }

    void clear() {
        sequence.notes.clear();
        sequence.events.clear();
        updateDSPSequence();
    }

    void stopPlayingNotes() {
        notesOff = true;
    }

    void sendMidiData(UInt8 status, UInt8 data1, UInt8 data2, double offset, double time) {
//        printf("%p: sending: %i %i %i at offset %f (%f beats)\n", &midiEndpoint, status, data1, data2, offset, time);
        if (midiPort == 0 || midiEndpoint == 0) {
            MusicDeviceMIDIEvent(targetAU, status, data1, data2, offset);
        } else {
            MIDIPacketList packetList;
            packetList.numPackets = 1;
            MIDIPacket* firstPacket = &packetList.packet[0];
            firstPacket->length = 3;
            firstPacket->data[0] = status;
            firstPacket->data[1] = data1;
            firstPacket->data[2] = data2;
            firstPacket->timeStamp = offset;
            MIDISend(midiPort, midiEndpoint, &packetList);
        }
    }

    long lengthInSamples() {
        return beatToSamples(length);
    }

    int beatToSamples(double beat) {
        return (int)(beat / tempo * 60 * sampleRate);
    }

    long positionModulo() {
        long length = lengthInSamples();
        if (positionInSamples == 0 || length == 0) {
            return 0;
        } else if (positionInSamples < 0) {
            return positionInSamples;
        } else {
            return positionInSamples % length;
        }
    }

    double currentPositionInBeats() {
        return (double)positionModulo() / sampleRate * (tempo / 60);
    }

    bool validTriggerTime(double beat) {
        return true;
    }

private:

    Sequence* getDSPSequence() {
        auto seq = nextSequence.load();
        if(seq != dspSequence) {
            if(dspSequence) { dspSequence->collect = true; }
            dspSequence = seq;
        }
        return seq;
    }

    void updateDSPSequence() {

        auto seqPtr = new Sequence(sequence);

        // Ensure program is disposed of on this
        // thread, not the DSP thread.
        sequenceReleasePool.emplace_back(seqPtr);

        // Transmit sequence to DSP thread.
        nextSequence = seqPtr;

        // Start from the end. Once we find a finished
        // sequence, delete all programs before and including.
        for(auto it=sequenceReleasePool.end(); it > sequenceReleasePool.begin(); --it) {
          if ((*(it-1))->collect) {
            // Remove the programs from the vector.
            sequenceReleasePool.erase(sequenceReleasePool.begin(), it);
            break;
          }
        }

    }

    float startPoint = 0;
    AudioUnit targetAU;
    UInt64 framesCounted = 0;
    long positionInSamples = 0;

    MIDIPortRef midiPort = NULL;
    MIDIEndpointRef midiEndpoint = NULL;

    // DSP thread only.
    std::vector<AKSequenceNote> playingNotes;
    Sequence* dspSequence = nullptr;

    // For communicating a sequence update to DSP thread.
    std::atomic<Sequence*> nextSequence{nullptr};

    // Tell the DSP thread to turn off notes.
    std::atomic<bool> notesOff{false};

    // Sequence as seen by the main thread.
    Sequence sequence;

    // Older sequences we will collect.
    std::vector<std::unique_ptr<Sequence>> sequenceReleasePool;

    int maximumPlayCount = 0;
    double length = 4.0;
    double tempo = 120.0;
    bool loopEnabled = true;
    uint numberOfLoops = 0;
};

AKDSPRef createAKSequencerEngineDSP() {
    return new AKSequencerEngineDSP();
}

void sequencerEngineUpdateSequence(AKDSPRef dsp,
                                   const AKSequenceEvent* events,
                                   size_t eventCount,
                                   const AKSequenceNote* notes,
                                   size_t noteCount) {
    ((AKSequencerEngineDSP*)dsp)->updateSequence(events, eventCount, notes, noteCount);
}

void sequencerEngineStopPlayingNotes(AKDSPRef dsp) {
    ((AKSequencerEngineDSP*)dsp)->stopPlayingNotes();
}

void sequencerEngineClear(AKDSPRef dsp) {
    ((AKSequencerEngineDSP*)dsp)->clear();
}

void sequencerEngineSetAUTarget(AKDSPRef dsp, AudioUnit audioUnit) {
    ((AKSequencerEngineDSP*)dsp)->setTargetAU(audioUnit);
}

#endif
