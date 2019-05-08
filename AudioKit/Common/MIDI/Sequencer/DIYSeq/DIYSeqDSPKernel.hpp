//
//  DIYSeqEngine.cpp
//  AudioKit
//
//  Created by Jeff Cooper on 1/25/19.
//  Copyright © 2019 AudioKit. All rights reserved.
//

#include <stdio.h>
#pragma once

#define NOTEON 0x90
#define NOTEOFF 0x80
#define INITVALUE -1.0
#define MIDINOTECOUNT 128
#define MAXNUMBEROFEVENTS 512

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

class AKDIYSeqEngineDSPKernel : public AKDSPKernel, public AKOutputBuffered {
public:
    // MARK: Member Functions

    AKDIYSeqEngineDSPKernel() {}

    void init(int channelCount, double sampleRate) override {
        printf("deboog: inited diyseqengine\n");
    }

    void setTargetAU(AudioUnit target) {
        targetAU = target;
    }

    void start() {
        resetPlaybackVariables();
        started = true;
        isPlaying = true;
    }

//    void playFrom(double beat) {
//        int position = beat;
//    }

    void stop() {
        started = false;
        isPlaying = false;
    }

    void reset() {
        printf("deboog: resetted diyseqengine\n");
        resetted = true;
        startPointRamper.reset();
    }

    void destroy() {

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
        if (isPlaying) {
            if (positionInSamples >= lengthInSamples()){
                if (!loopEnabled) { //stop if played enough
                    printf("deboog: seq finished %i \n", lengthInSamples());
                    stop();
                    return;
                }
            }
            int currentStartSample = positionModulo();
            int currentEndSample = currentStartSample + frameCount;
            for (int i = 0; i < eventCount; i++) {
                // go through every event
                int triggerTime = beatToSamples(events[i].beat);
                if ((currentStartSample <= triggerTime && triggerTime < currentEndSample)
                    && stopAfterCurrentNotes == false) {
                    // this event is supposed to trigger between currentStartSample and currentEndSample
                    int offset = (int)(triggerTime - currentStartSample);
                    sendMidiData(events[i].status, events[i].data1, events[i].data2,
                                 offset, events[i].beat);
                } else if (currentEndSample > lengthInSamples() && loopEnabled) {
                    // this buffer extends beyond the length of the loop and looping is on
                    int loopRestartInBuffer = lengthInSamples() - currentStartSample;
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
            positionInSamples += frameCount;
        }
        framesCounted += frameCount;
    }

    int addMIDIEvent(uint8_t status, uint8_t data1, uint8_t data2, double beat) {
        events[eventCount].status = status;
        events[eventCount].data1 = data1;
        events[eventCount].data2 = data2;
        events[eventCount].beat = beat;

        eventCount += 1;
        return eventCount;
    }

    void clear() {
        eventCount = 0;
    }

    void sendMidiData(UInt8 status, UInt8 data1, UInt8 data2, double offset, double time) {
//        printf("deboog: sending: %i %i %i at offset %f (%f beats)\n", status, data1, data2, offset, time);
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

    int lengthInSamples() {
        return beatToSamples(lengthInBeats);
    }

    void resetPlaybackVariables() {
        positionInSamples = 0;
    }

    int beatToSamples(double beat) {
        return (int)(beat / bpm * 60 * sampleRate);
    }

    int positionModulo() {
        return positionInSamples % lengthInSamples();
    }

    double currentPositionInBeats() {
        return (double)positionModulo() / sampleRate * (bpm / 60);
    }

    bool validTriggerTime(double beat){
        return true;
    }

private:

    float startPoint = 0;
    AudioUnit targetAU;
    UInt64 framesCounted = 0;
    UInt64 positionInSamples = 0;

public:
    bool started = false;
    bool resetted = false;
    ParameterRamper startPointRamper = 1;

    bool isPlaying = false;
    MIDIPortRef midiPort;
    MIDIEndpointRef midiEndpoint;
    AKCCallback loopCallback = nullptr;
    MIDIEvent events[MAXNUMBEROFEVENTS];
    int eventCount = 0;
    int maximumPlayCount = 0;
    double lengthInBeats = 4.0;
    double bpm = 120.0;
    bool stopAfterCurrentNotes = false;
    bool loopEnabled = true;
};
