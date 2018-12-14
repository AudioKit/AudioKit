//
//  AKCallbackInstrumentDSPKernel.hpp
//  AudioKit
//
//  Created by Jeff Cooper, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once
#import "AKSoundpipeKernel.hpp"

class AKCallbackInstrumentDSPKernel : public AKSoundpipeKernel, public AKOutputBuffered {
public:
    // MARK: Member Functions

    AKCallbackInstrumentDSPKernel() {}

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
        for (int i = 0; i < frameCount; i++) {
            count += 1;
            if (updateTime) {
                int diff = count - lastFrameCount;
                printf("deboog: time is %i diff is %i\n", count, diff);
                lastFrameCount = count;
                updateTime = false;
            }
        }
    }

    void startNote(int note, int velocity) {
        doCallback(0x90, note, velocity);
    }

    void stopNote(int note) {
        doCallback(0x80, note, 0);
    }

    virtual void handleMIDIEvent(AUMIDIEvent const& midiEvent) override {
        if (midiEvent.length != 3) return;
        uint8_t status = midiEvent.data[0];
        uint8_t data1 = midiEvent.data[1];
        uint8_t data2 = midiEvent.data[2];
        doCallback(status, data1, data2);
    }

    void doCallback(int status, int data1, int data2) {
        if (callback != NULL){
            callback(status, data1, data2);
        }
    }
    
private:
    int count = 0;
    int lastFrameCount = 0;
    bool updateTime = false;

public:
    bool started = false;
    bool resetted = false;
    AKCMIDICallback callback = nullptr;
};
