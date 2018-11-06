//
//  AKDoNothingDSPKernel.hpp
//  AudioKit
//
//  Created by Jeff Cooper, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once
#import "AKSoundpipeKernel.hpp"

class AKDoNothingDSPKernel : public AKSoundpipeKernel, public AKOutputBuffered {
public:
    // MARK: Member Functions

    AKDoNothingDSPKernel() {}

    void init(int _channels, double _sampleRate) override {
        AKSoundpipeKernel::init(_channels, _sampleRate);
    }

    void destroy() {
        AKSoundpipeKernel::destroy();
    }
    void start() {
        started = true;
    }

    void stop() {
        started = false;
    }

    void reset() {
        resetted = true;
    }

    void setParameter(AUParameterAddress address, AUValue value) {

    }

    AUValue getParameter(AUParameterAddress address) {
        return 0.0f;
    }

    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {

    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        //do nothing
    }

    void startNote(int note, int velocity) {
        printf("starting note %i", note);
    }
    void stopNote(int note) {
        printf("stopping note %i", note);
    }

    virtual void handleMIDIEvent(AUMIDIEvent const& midiEvent) override {
        printf("deboog: handling midi\n");
    }
//        if (midiEvent.length != 3) return; \
//        uint8_t status = midiEvent.data[0] & 0xF0; \
//        switch (status) { \
//            case 0x80 : {  \
//                uint8_t note = midiEvent.data[1]; \
//                if (note > 127) break; \
//                noteStates[note].noteOn(note, 0); \
//                break; \
//            } \
//            case 0x90 : {  \
//                uint8_t note = midiEvent.data[1]; \
//                uint8_t veloc = midiEvent.data[2]; \
//                if (note > 127 || veloc > 127) break; \
//                noteStates[note].noteOn(note, veloc); \
//                break; \
//            } \
//            case 0xB0 : { \
//                uint8_t num = midiEvent.data[1]; \
//                if (num == 123) { \
//                    NoteState *noteState = playingNotes; \
//                    while (noteState) { \
//                        noteState->clear(); \
//                        noteState = noteState->next; \
//                    } \
//                    playingNotes = nullptr; \
//                    playingNotesCount = 0; \
//                } \
//                break; \
//            } \
//        } \
//    }
private:

public:
    bool started = false;
    bool resetted = false;
};


