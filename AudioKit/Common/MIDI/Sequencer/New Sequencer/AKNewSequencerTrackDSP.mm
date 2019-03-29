//
//  AKNewSequencerTrackDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka on 1/31/19.
//  Copyright © 2019 AudioKit. All rights reserved.
//

#include "AKNewSequencerTrackDSP.hpp"
#import "AKLinearParameterRamp.hpp"
#import "DSPKernel.hpp" // for the clamp

#define NOTEON 0x90
#define NOTEOFF 0x80
#define INITVALUE -1.0
#define MIDINOTECOUNT 128

extern "C" AKDSPRef createNewSequencerTrackDSP(int channelCount, double sampleRate) {
    AKNewSequencerTrackDSP *dsp = new AKNewSequencerTrackDSP();
    dsp->init(channelCount, sampleRate);
    return dsp;
}

struct AKNewSequencerTrackDSP::InternalData {
    AKLinearParameterRamp startPointRamp;
    AKLinearParameterRamp amplitudeRamp;
};


AKNewSequencerTrackDSP::AKNewSequencerTrackDSP() : data(new InternalData) {
    data->startPointRamp.setTarget(defaultStartPoint, true);
}

// Uses the ParameterAddress as a key
void AKNewSequencerTrackDSP::setParameter(AUParameterAddress address, AUValue value, bool immediate) {
    switch (address) {
        case AKNewSequencerTrackParameterStartPoint:
            data->startPointRamp.setTarget(clamp(value, startPointLowerBound, startPointUpperBound), immediate);
            break;
        case AKNewSequencerTrackParameterRampDuration:
            data->startPointRamp.setRampDuration(value, sampleRate);
            break;
    }
}

// Uses the ParameterAddress as a key
float AKNewSequencerTrackDSP::getParameter(uint64_t address) {
    switch (address) {
        case AKNewSequencerTrackParameterStartPoint:
            return data->startPointRamp.getTarget();
        case AKNewSequencerTrackParameterRampDuration:
            return data->startPointRamp.getRampDuration(sampleRate);
    }
    return 0;
}

void AKNewSequencerTrackDSP::init(int channelCount, double sampleRate) {
    AKDSPBase::init(channelCount, sampleRate);
    isStarted = false;
}

double AKNewSequencerTrackDSP::getTempo() {
    return bpm;
}

void AKNewSequencerTrackDSP::deinit() {
    // Destroy Stuff
}

void AKNewSequencerTrackDSP::setTargetAU(AudioUnit target) {
    targetAU = target;
}

void AKNewSequencerTrackDSP::toggleLooping() {
    loopEnabled = !loopEnabled;
}

void AKNewSequencerTrackDSP::start() {
//    resetPlaybackVariables();
    positionInSamples = 0;

    isPlaying = true;
}

bool AKNewSequencerTrackDSP::isLooping() {
    return loopEnabled;
}

//void AKNewSequencerTrackDSP::setStartPoint(float value) {
//    startPoint = value;
//}

void AKNewSequencerTrackDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

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


void AKNewSequencerTrackDSP::addMIDIEvent(uint8_t status, uint8_t data1, uint8_t data2, double beat) {
    events[eventCount].status = status;
    events[eventCount].data1 = data1;
    events[eventCount].data2 = data2;
    events[eventCount].beat = beat;

    eventCount += 1;
//    return eventCount;
}

void AKNewSequencerTrackDSP::sendMidiData(UInt8 status, UInt8 data1, UInt8 data2, double offset, double time) {
    printf("deboog: sending: %i %i %i at offset %f (%f beats)\n", status, data1, data2, offset, time);
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

int AKNewSequencerTrackDSP::lengthInSamples() {
    return beatToSamples(lengthInBeats);
}

void AKNewSequencerTrackDSP::resetPlaybackVariables() {
    positionInSamples = 0;
}

int AKNewSequencerTrackDSP::beatToSamples(double beat) {
    return (int)(beat / bpm * 60 * sampleRate);
}

int AKNewSequencerTrackDSP::positionModulo() {
    return positionInSamples % lengthInSamples();
}

bool AKNewSequencerTrackDSP::validTriggerTime(double beat){
    return true;
}
