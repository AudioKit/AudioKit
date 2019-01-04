//
//  AKDynamicRangeCompressorDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKDynamicRangeCompressorDSP.hpp"
#import "AKLinearParameterRamp.hpp"

extern "C" AKDSPRef createDynamicRangeCompressorDSP(int channelCount, double sampleRate) {
    AKDynamicRangeCompressorDSP *dsp = new AKDynamicRangeCompressorDSP();
    dsp->init(channelCount, sampleRate);
    return dsp;
}

struct AKDynamicRangeCompressorDSP::InternalData {
    sp_compressor *compressor0;
    sp_compressor *compressor1;
    AKLinearParameterRamp ratioRamp;
    AKLinearParameterRamp thresholdRamp;
    AKLinearParameterRamp attackDurationRamp;
    AKLinearParameterRamp releaseDurationRamp;
};

AKDynamicRangeCompressorDSP::AKDynamicRangeCompressorDSP() : data(new InternalData) {
    data->ratioRamp.setTarget(defaultRatio, true);
    data->ratioRamp.setDurationInSamples(defaultRampDurationSamples);
    data->thresholdRamp.setTarget(defaultThreshold, true);
    data->thresholdRamp.setDurationInSamples(defaultRampDurationSamples);
    data->attackDurationRamp.setTarget(defaultAttackDuration, true);
    data->attackDurationRamp.setDurationInSamples(defaultRampDurationSamples);
    data->releaseDurationRamp.setTarget(defaultReleaseDuration, true);
    data->releaseDurationRamp.setDurationInSamples(defaultRampDurationSamples);
}

// Uses the ParameterAddress as a key
void AKDynamicRangeCompressorDSP::setParameter(AUParameterAddress address, AUValue value, bool immediate) {
    switch (address) {
        case AKDynamicRangeCompressorParameterRatio:
            data->ratioRamp.setTarget(clamp(value, ratioLowerBound, ratioUpperBound), immediate);
            break;
        case AKDynamicRangeCompressorParameterThreshold:
            data->thresholdRamp.setTarget(clamp(value, thresholdLowerBound, thresholdUpperBound), immediate);
            break;
        case AKDynamicRangeCompressorParameterAttackDuration:
            data->attackDurationRamp.setTarget(clamp(value, attackDurationLowerBound, attackDurationUpperBound), immediate);
            break;
        case AKDynamicRangeCompressorParameterReleaseDuration:
            data->releaseDurationRamp.setTarget(clamp(value, releaseDurationLowerBound, releaseDurationUpperBound), immediate);
            break;
        case AKDynamicRangeCompressorParameterRampDuration:
            data->ratioRamp.setRampDuration(value, sampleRate);
            data->thresholdRamp.setRampDuration(value, sampleRate);
            data->attackDurationRamp.setRampDuration(value, sampleRate);
            data->releaseDurationRamp.setRampDuration(value, sampleRate);
            break;
    }
}

// Uses the ParameterAddress as a key
float AKDynamicRangeCompressorDSP::getParameter(uint64_t address) {
    switch (address) {
        case AKDynamicRangeCompressorParameterRatio:
            return data->ratioRamp.getTarget();
        case AKDynamicRangeCompressorParameterThreshold:
            return data->thresholdRamp.getTarget();
        case AKDynamicRangeCompressorParameterAttackDuration:
            return data->attackDurationRamp.getTarget();
        case AKDynamicRangeCompressorParameterReleaseDuration:
            return data->releaseDurationRamp.getTarget();
        case AKDynamicRangeCompressorParameterRampDuration:
            return data->ratioRamp.getRampDuration(sampleRate);
    }
    return 0;
}

void AKDynamicRangeCompressorDSP::init(int channelCount, double sampleRate) {
    AKSoundpipeDSPBase::init(channelCount, sampleRate);
    sp_compressor_create(&data->compressor0);
    sp_compressor_init(sp, data->compressor0);
    sp_compressor_create(&data->compressor1);
    sp_compressor_init(sp, data->compressor1);
    *data->compressor0->ratio = defaultRatio;
    *data->compressor1->ratio = defaultRatio;
    *data->compressor0->thresh = defaultThreshold;
    *data->compressor1->thresh = defaultThreshold;
    *data->compressor0->atk = defaultAttackDuration;
    *data->compressor1->atk = defaultAttackDuration;
    *data->compressor0->rel = defaultReleaseDuration;
    *data->compressor1->rel = defaultReleaseDuration;
}

void AKDynamicRangeCompressorDSP::deinit() {
    sp_compressor_destroy(&data->compressor0);
    sp_compressor_destroy(&data->compressor1);
}

void AKDynamicRangeCompressorDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            data->ratioRamp.advanceTo(now + frameOffset);
            data->thresholdRamp.advanceTo(now + frameOffset);
            data->attackDurationRamp.advanceTo(now + frameOffset);
            data->releaseDurationRamp.advanceTo(now + frameOffset);
        }

        *data->compressor0->ratio = data->ratioRamp.getValue();
        *data->compressor1->ratio = data->ratioRamp.getValue();
        *data->compressor0->thresh = data->thresholdRamp.getValue();
        *data->compressor1->thresh = data->thresholdRamp.getValue();
        *data->compressor0->atk = data->attackDurationRamp.getValue();
        *data->compressor1->atk = data->attackDurationRamp.getValue();
        *data->compressor0->rel = data->releaseDurationRamp.getValue();
        *data->compressor1->rel = data->releaseDurationRamp.getValue();

        float *tmpin[2];
        float *tmpout[2];
        for (int channel = 0; channel < channelCount; ++channel) {
            float *in  = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
            float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;
            if (channel < 2) {
                tmpin[channel] = in;
                tmpout[channel] = out;
            }
            if (!isStarted) {
                *out = *in;
                continue;
            }

            if (channel == 0) {
                sp_compressor_compute(sp, data->compressor0, in, out);
            } else {
                sp_compressor_compute(sp, data->compressor1, in, out);
            }
        }
    }
}
