//
//  AKShakerDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka on 12/30/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import "AKShakerDSP.hpp"

#include "Shakers.h"

// "Constructor" function for interop with Swift

extern "C" AKDSPRef createShakerDSP(int channelCount, double sampleRate) {
    AKShakerDSP *dsp = new AKShakerDSP();
    dsp->init(channelCount, sampleRate);
    return dsp;
}

// AKShakerDSP method implementations

struct AKShakerDSP::InternalData
{
    float internalTrigger = 0;
    UInt8 type = 0;
    float amplitude = 0.5;
    stk::Shakers *shaker;
};

AKShakerDSP::AKShakerDSP() : data(new InternalData)
{
}

AKShakerDSP::~AKShakerDSP() = default;

/** Uses the ParameterAddress as a key */
void AKShakerDSP::setParameter(AUParameterAddress address, float value, bool immediate)  {
}

/** Uses the ParameterAddress as a key */
float AKShakerDSP::getParameter(AUParameterAddress address)  {
    return 0;
}

void AKShakerDSP::init(int channelCount, double sampleRate)  {
    AKDSPBase::init(channelCount, sampleRate);

    stk::Stk::setSampleRate(sampleRate);
    data->shaker = new stk::Shakers();
}

void AKShakerDSP::trigger() {
    data->internalTrigger = 1;
}

void AKShakerDSP::triggerTypeAmplitude(AUValue type, AUValue amp)  {
    data->type = type;
    data->amplitude = amp;
    trigger();
}

void AKShakerDSP::destroy() {
    delete data->shaker;
}

void AKShakerDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        for (int channel = 0; channel < channelCount; ++channel) {
            float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;

            if (isStarted) {
                if (data->internalTrigger == 1) {
                    data->shaker->noteOn(data->type, data->amplitude);
                }
                *out = data->shaker->tick();
            } else {
                *out = 0.0;
            }
        }
    }
    if (data->internalTrigger == 1) {
        data->internalTrigger = 0;
    }
}

