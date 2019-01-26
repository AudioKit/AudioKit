//
//  DIYSeqEngine.cpp
//  AudioKit
//
//  Created by Jeff Cooper on 1/25/19.
//  Copyright © 2019 AudioKit. All rights reserved.
//

#include <stdio.h>
#import <Foundation/Foundation.h>
#pragma once
#import "AKSoundpipeKernel.hpp"

#define NOTEON 0x90
#define NOTEOFF 0x80
#define INITVALUE -1.0
#define MIDINOTECOUNT 128

struct MIDIEvent {
    uint8_t status;
    uint8_t data1;
    uint8_t data2;
    double beat;
    double duration;
};

struct MIDINote {
    struct MIDIEvent noteOn;
    struct MIDIEvent noteOff;
};

enum {
    startPointAddress = 0,
};

class AKDIYSeqEngineDSPKernel : public AKSoundpipeKernel, public AKOutputBuffered {
public:
    // MARK: Member Functions

    AKDIYSeqEngineDSPKernel() {}

    void init(int channelCount, double sampleRate) override {
        printf("deboog: inited diyseqengine\n");
        AKSoundpipeKernel::init(channelCount, sampleRate);
    }

    void setTargetAU(AudioUnit target) {
        targetAU = target;
    }

    void start() {
        printf("deboog: started diyseqengine\n");
        started = true;
        isPlaying = true;
    }

    void stop() {
        printf("deboog: stopped diyseqengine\n");
        started = false;
        isPlaying = false;
    }
    
    void reset() {
        printf("deboog: resetted diyseqengine\n");
        resetted = true;
        startPointRamper.reset();
    }

    void destroy() {
        AKSoundpipeKernel::destroy();
    }

    void setStartPoint(float value) {
        startPoint = value;
    }

    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case startPointAddress:
                startPointRamper.setUIValue(clamp(value, 0.0f, 10.0f));
                break;
        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case startPointAddress:
                return startPointRamper.getUIValue();

            default: return 0.0f;
        }
    }

    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
            case startPointAddress:
                startPointRamper.startRamp(clamp(value, 0.0f, 10.0f), duration);
                break;
        }
    }
    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        if (!isPlaying) {
            return;
        }

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);
            if (framesCounted % 44100 == 0) {
                sendMidiData(targetAU, midiPort, midiEndpoint,
                             0x90, 60, 100,
                             frameIndex, 0);
            }
            framesCounted++;
        }
    }
    
    void sendMidiData(AudioUnit audioUnit, MIDIPortRef midiPort, MIDIEndpointRef midiEndpoint, UInt8 status, UInt8 data1, UInt8 data2, double offset, double time) {
        printf("deboog: sending: %i %i at %f\n", status, data1, time);
        if (midiPort == 0 || midiEndpoint == 0) {
            MusicDeviceMIDIEvent(audioUnit, status, data1, data2, offset);
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

private:

    float startPoint = 0;
    AudioUnit targetAU;
    UInt64 framesCounted = 0;

public:
    bool started = false;
    bool resetted = false;
    ParameterRamper startPointRamper = 1;

    bool isPlaying = false;
    MIDIPortRef midiPort;
    MIDIEndpointRef midiEndpoint;
    AKCCallback loopCallback = nullptr;
};
