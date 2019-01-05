//
//  AKDynaRageCompressorDSPKernel.mm
//  AudioKit
//
//  Created by Stéphane Peter, revision history on Githbub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKDynaRageCompressorDSPKernel.hpp"

#import "Compressor.h"
#import "RageProcessor.h"

struct AKDynaRageCompressorDSPKernel::InternalData {
    Compressor *left_compressor;
    Compressor *right_compressor;

    RageProcessor *left_rageprocessor;
    RageProcessor *right_rageprocessor;

    float ratio = 1.0;
    float threshold = 0.0;
    float attackDuration = 0.1;
    float releaseDuration = 0.1;
    float rage = 0.1;
    BOOL rageIsOn = true;
};

AKDynaRageCompressorDSPKernel::AKDynaRageCompressorDSPKernel() : data(new InternalData) {}
AKDynaRageCompressorDSPKernel::~AKDynaRageCompressorDSPKernel() = default;

void AKDynaRageCompressorDSPKernel::init(int channelCount, double sampleRate) {
    AKDSPKernel::init(channelCount, sampleRate);
    data->left_compressor = new Compressor(data->threshold, data->ratio,
                                               data->attackDuration, data->releaseDuration, (int)sampleRate);
    data->right_compressor = new Compressor(data->threshold, data->ratio, data->attackDuration,
                                                data->releaseDuration, (int)sampleRate);

    data->left_rageprocessor = new RageProcessor((int)sampleRate);
    data->right_rageprocessor = new RageProcessor((int)sampleRate);

    ratioRamper.init();
    thresholdRamper.init();
    attackDurationRamper.init();
    releaseDurationRamper.init();
    rageRamper.init();
}

void AKDynaRageCompressorDSPKernel::reset() {
    resetted = true;
    ratioRamper.reset();
    thresholdRamper.reset();
    attackDurationRamper.reset();
    releaseDurationRamper.reset();
    rageRamper.reset();
}

void AKDynaRageCompressorDSPKernel::setRatio(float value) {
    data->ratio = clamp(value, 1.0f, 20.0f);
    ratioRamper.setImmediate(data->ratio);
}

void AKDynaRageCompressorDSPKernel::setThreshold(float value) {
    data->threshold = clamp(value, -100.0f, 0.0f);
    thresholdRamper.setImmediate(data->threshold);
}

void AKDynaRageCompressorDSPKernel::setAttackDuration(float value) {
    data->attackDuration = clamp(value, 20.0f, 500.0f);
    attackDurationRamper.setImmediate(data->attackDuration);
}

void AKDynaRageCompressorDSPKernel::setReleaseDuration(float value) {
    data->releaseDuration = clamp(value, 20.0f, 500.0f);
    releaseDurationRamper.setImmediate(data->releaseDuration);
}

void AKDynaRageCompressorDSPKernel::setRage(float value) {
    data->rage = clamp(value, 0.1f, 20.0f);
    rageRamper.setImmediate(data->rage);
}

void AKDynaRageCompressorDSPKernel::setRageIsOn(bool value) {
    data->rageIsOn = value;
}

void AKDynaRageCompressorDSPKernel::setParameter(AUParameterAddress address, AUValue value) {
    switch (address) {
        case ratioAddress:
            ratioRamper.setUIValue(clamp(value, 1.0f, 20.0f));
            break;

        case thresholdAddress:
            thresholdRamper.setUIValue(clamp(value, -100.0f, 0.0f));
            break;

        case attackDurationAddress:
            attackDurationRamper.setUIValue(clamp(value, 0.1f, 500.0f));
            break;

        case releaseDurationAddress:
            releaseDurationRamper.setUIValue(clamp(value, 0.1f, 500.0f));
            break;

        case rageAddress:
            rageRamper.setUIValue(clamp(value, 0.1f, 20.0f));
            break;

            break;
    }
}

AUValue AKDynaRageCompressorDSPKernel::getParameter(AUParameterAddress address) {
    switch (address) {
        case ratioAddress:
            return ratioRamper.getUIValue();

        case thresholdAddress:
            return thresholdRamper.getUIValue();

        case attackDurationAddress:
            return attackDurationRamper.getUIValue();

        case releaseDurationAddress:
            return releaseDurationRamper.getUIValue();

        case rageAddress:
            return rageRamper.getUIValue();

        default: return 0.0f;
    }
}

void AKDynaRageCompressorDSPKernel::startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) {
    switch (address) {
        case ratioAddress:
            ratioRamper.startRamp(clamp(value, 1.0f, 20.0f), duration);
            break;

        case thresholdAddress:
            thresholdRamper.startRamp(clamp(value, -100.0f, 0.0f), duration);
            break;

        case attackDurationAddress:
            attackDurationRamper.startRamp(clamp(value, 0.1f, 500.0f), duration);
            break;

        case releaseDurationAddress:
            releaseDurationRamper.startRamp(clamp(value, 0.1f, 500.0f), duration);
            break;

        case rageAddress:
            rageRamper.startRamp(clamp(value, 0.1f, 20.0f), duration);
            break;
    }
}

void AKDynaRageCompressorDSPKernel::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {

        int frameOffset = int(frameIndex + bufferOffset);

        data->ratio = ratioRamper.getAndStep();
        data->threshold = thresholdRamper.getAndStep();
        data->attackDuration = attackDurationRamper.getAndStep();
        data->releaseDuration = releaseDurationRamper.getAndStep();
        data->rage = rageRamper.getAndStep();

        data->left_compressor->setParameters(data->threshold, data->ratio,
                                                 data->attackDuration, data->releaseDuration);
        data->right_compressor->setParameters(data->threshold, data->ratio,
                                                  data->attackDuration, data->releaseDuration);

        for (int channel = 0; channel < channels; ++channel) {
            float *in  = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
            float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;

            if (started) {
                if (channel == 0) {

                    float rageSignal = data->left_rageprocessor->doRage(*in, data->rage, data->rage);
                    float compSignal = data->left_compressor->Process((bool)data->rageIsOn ? rageSignal : *in, false, 1);
                    *out = compSignal;
                } else {
                    float rageSignal = data->right_rageprocessor->doRage(*in, data->rage, data->rage);
                    float compSignal = data->right_compressor->Process((bool)data->rageIsOn ? rageSignal : *in, false, 1);
                    *out = compSignal;
                }
            } else {
                *out = *in;
            }
        }
    }
}
