// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKSequencerEngineParameter) {
    AKSequencerEngineParameterTempo,
    AKSequencerEngineParameterLength,
    AKSequencerEngineParameterMaximumPlayCount,
    AKSequencerEngineParameterPosition,
    AKSequencerEngineParameterLoopEnabled
};

#ifndef __cplusplus

AKDSPRef createAKSequencerEngineDSP(void);

void sequencerEngineAddMIDIEvent(AKDSPRef dsp, uint8_t status, uint8_t data1, uint8_t data2, double beat);
void sequencerEngineAddMIDINote(AKDSPRef dsp, uint8_t noteNumber, uint8_t velocity, double beat, double duration);
void sequencerEngineRemoveMIDIEvent(AKDSPRef dsp, double beat);
void sequencerEngineRemoveMIDINote(AKDSPRef dsp, double beat);
void sequencerEngineRemoveSpecificMIDINote(AKDSPRef dsp, double beat, uint8_t noteNumber);
void sequencerEngineRemoveAllInstancesOf(AKDSPRef dsp, uint8_t noteNumber);

void sequencerEngineStopPlayingNotes(AKDSPRef dsp);
void sequencerEngineClear(AKDSPRef dsp);

void sequencerEngineSetAUTarget(AKDSPRef dsp, AudioUnit audioUnit);

#else

#include "AKDSPBase.hpp"
#include <vector>
#include <stdio.h>

#define NOTEON 0x90
#define NOTEOFF 0x80

class AKSequencerEngineDSP : public AKDSPBase {
    
    struct MIDIEvent {
        uint8_t status;
        uint8_t data1;
        uint8_t data2;
        double beat;
    };

    struct MIDINote {
        struct MIDIEvent noteOn;
        struct MIDIEvent noteOff;
    };
    
public:

    AKSequencerEngineDSP() {}

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

    void addPlayingNote(MIDINote note, int offset) {
        if (note.noteOn.data2 > 0) {
            sendMidiData(note.noteOn.status, note.noteOn.data1, note.noteOn.data2, offset, note.noteOn.beat);
            playingNotes.push_back(note);
        } else {
            sendMidiData(note.noteOff.status, note.noteOff.data1, note.noteOff.data2, offset, note.noteOn.beat);
        }
    }

    void stopPlayingNote(MIDINote note, int offset, int index) {
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
        if (isStarted) {
            if (positionInSamples >= lengthInSamples()){
                if (!loopEnabled) { //stop if played enough
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

            positionInSamples += frameCount;
        }
        framesCounted += frameCount;
    }

    void removeNoteAt(double beat) {
        for (int i = 0; i < notes.size(); i++) {
            MIDINote note = notes[i];
            if (note.noteOn.beat == beat) {
                notes.erase(notes.begin()+i);
            }
        }
    }
    
    void removeNoteAt(uint8_t noteToRemove, double beat) {
        
        for (int i = 0; i < notes.size(); i++) {
            MIDINote note = notes[i];
            if (note.noteOn.beat == beat && note.noteOn.data1 == noteToRemove) {
                notes.erase(notes.begin()+i);
            }
        }
    }
    
    void removeAllInstancesOf(uint8_t noteToRemove) {
        
         for (auto itr1 = notes.rbegin(); itr1 < notes.rend(); itr1++) {
             if (itr1->noteOn.data1 == noteToRemove) {
                   notes.erase((itr1 + 1).base());
               }
           }
    }

    void removeEventAt(double beat) {
        for (int i = 0; i < events.size(); i++) {
            MIDIEvent event = events[i];
            if (event.beat == beat) {
                events.erase(events.begin()+i);
            }
        }
    }

    void addMIDIEvent(uint8_t status, uint8_t data1, uint8_t data2, double beat) {
        MIDIEvent newEvent;
        newEvent.status = status;
        newEvent.data1 = data1;
        newEvent.data2 = data2;
        newEvent.beat = beat;
        events.push_back(newEvent);
    }

    void addMIDINote(uint8_t number, uint8_t velocity, double beat, double duration) {
        MIDINote newNote;

        newNote.noteOn.status = NOTEON;
        newNote.noteOn.data1 = number;
        newNote.noteOn.data2 = velocity;
        newNote.noteOn.beat = beat;

        newNote.noteOff.status = NOTEOFF;
        newNote.noteOff.data1 = number;
        newNote.noteOff.data2 = velocity;
        newNote.noteOff.beat = beat + duration;

        notes.push_back(newNote);
    }

    void clear() {
        notes.clear();
        events.clear();
    }

    void stopPlayingNotes() {
        while (playingNotes.size() > 0) {
            stopPlayingNote(playingNotes[0], 0, 0);
        }
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

    float startPoint = 0;
    AudioUnit targetAU;
    UInt64 framesCounted = 0;
    long positionInSamples = 0;

public:
    MIDIPortRef midiPort;
    MIDIEndpointRef midiEndpoint;
    std::vector<MIDIEvent> events;
    std::vector<MIDINote> notes;
    std::vector<MIDINote> playingNotes;
    int maximumPlayCount = 0;
    double length = 4.0;
    double tempo = 120.0;
    bool loopEnabled = true;
    uint numberOfLoops = 0;
};

#endif
