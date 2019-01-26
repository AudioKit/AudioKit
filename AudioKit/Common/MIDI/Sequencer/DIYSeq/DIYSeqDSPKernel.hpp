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
        sequenceStartedAt = framesCounted;
        started = true;
        isPlaying = true;
        printf("deboog: started diyseqengine at %lu\n", sequenceStartedAt);
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

        UInt64 currentStartSample = framesCounted - sequenceStartedAt;
        UInt64 currentEndSample = currentStartSample + frameCount;
        if (isPlaying) {
            for (int i = 0; i < eventCount; i++) {
                int triggerTime = events[i].beat / bpm * 60 * sampleRate;
                if (currentStartSample <= triggerTime && triggerTime < currentEndSample) {
                    int offset = (int)(triggerTime - currentStartSample);
                    sendMidiData(events[i].status, events[i].data1, events[i].data2,
                                 offset, events[i].beat);
                    printf("deboog event %i will fire at %i offset %i \n", i, triggerTime, offset);
                }
                //            double triggerTime = events[i].beat / *beatsPerSample;
                //            if (((startSample <= triggerTime && triggerTime <= endSample)) && *stopAfterCurrentNotes == false)
                //            {
                //                int time = triggerTime - startSample + offset;
                //                if (self->_eventCallback != NULL) {
                //                    self->_eventCallback(events[i].status, events[i].data1, events[i].data2);
                //                }

                //            }
            }
        }
        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            framesCounted++;
        }
    }

    int addMIDIEvent(uint8_t status, uint8_t data1, uint8_t data2, double beat) {
        events[eventCount].status = status;
        events[eventCount].data1 = data1;
        events[eventCount].data2 = data2;
        events[eventCount].beat = beat;

        eventCount += 1;
        return eventCount;
    }

private:
    void sendMidiData(UInt8 status, UInt8 data1, UInt8 data2, double offset, double time) {
//        printf("deboog: sending: %i %i at %f\n", status, data1, time);
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

private:

    float startPoint = 0;
    AudioUnit targetAU;
    UInt64 framesCounted = 0;
    UInt64 positionInSamples = 0;
    UInt64 sequenceStartedAt = 0;

public:
    bool started = false;
    bool resetted = false;
    ParameterRamper startPointRamper = 1;

    bool isPlaying = false;
    MIDIPortRef midiPort;
    MIDIEndpointRef midiEndpoint;
    AKCCallback loopCallback = nullptr;
    MIDIEvent events[512];
    int eventCount = 0;
    double lengthInBeats = 4.0;
    double bpm = 120.0;
};
