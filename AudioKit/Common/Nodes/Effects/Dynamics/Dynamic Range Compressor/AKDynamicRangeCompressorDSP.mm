//
//  AKDynamicRangeCompressorDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKDynamicRangeCompressorDSP.hpp"
#import "AKLinearParameterRamp.hpp"

extern "C" AKDSPRef createDynamicRangeCompressorDSP(int nChannels, double sampleRate) {
    AKDynamicRangeCompressorDSP *dsp = new AKDynamicRangeCompressorDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}

struct AKDynamicRangeCompressorDSP::_Internal {
    sp_compressor *_compressor0;
    sp_compressor *_compressor1;
    AKLinearParameterRamp ratioRamp;
    AKLinearParameterRamp thresholdRamp;
    AKLinearParameterRamp attackDurationRamp;
    AKLinearParameterRamp releaseDurationRamp;
};

AKDynamicRangeCompressorDSP::AKDynamicRangeCompressorDSP() : data(new _Internal) {
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
        case AKDynamicRangeCompressorParameterAttackTime:
            data->attackDurationRamp.setTarget(clamp(value, attackDurationLowerBound, attackDurationUpperBound), immediate);
            break;
        case AKDynamicRangeCompressorParameterReleaseTime:
            data->releaseDurationRamp.setTarget(clamp(value, releaseDurationLowerBound, releaseDurationUpperBound), immediate);
            break;
        case AKDynamicRangeCompressorParameterRampDuration:
            data->ratioRamp.setRampDuration(value, _sampleRate);
            data->thresholdRamp.setRampDuration(value, _sampleRate);
            data->attackDurationRamp.setRampDuration(value, _sampleRate);
            data->releaseDurationRamp.setRampDuration(value, _sampleRate);
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
        case AKDynamicRangeCompressorParameterAttackTime:
            return data->attackDurationRamp.getTarget();
        case AKDynamicRangeCompressorParameterReleaseTime:
            return data->releaseDurationRamp.getTarget();
        case AKDynamicRangeCompressorParameterRampDuration:
            return data->ratioRamp.getRampDuration(_sampleRate);
    }
    return 0;
}

void AKDynamicRangeCompressorDSP::init(int _channels, double _sampleRate) {
    AKSoundpipeDSPBase::init(_channels, _sampleRate);
    sp_compressor_create(&data->_compressor0);
    sp_compressor_init(_sp, data->_compressor0);
    sp_compressor_create(&data->_compressor1);
    sp_compressor_init(_sp, data->_compressor1);
    *data->_compressor0->ratio = defaultRatio;
    *data->_compressor1->ratio = defaultRatio;
    *data->_compressor0->thresh = defaultThreshold;
    *data->_compressor1->thresh = defaultThreshold;
    *data->_compressor0->atk = defaultAttackDuration;
    *data->_compressor1->atk = defaultAttackDuration;
    *data->_compressor0->rel = defaultReleaseDuration;
    *data->_compressor1->rel = defaultReleaseDuration;
}

void AKDynamicRangeCompressorDSP::deinit() {
    sp_compressor_destroy(&data->_compressor0);
    sp_compressor_destroy(&data->_compressor1);
}

void AKDynamicRangeCompressorDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            data->ratioRamp.advanceTo(_now + frameOffset);
            data->thresholdRamp.advanceTo(_now + frameOffset);
            data->attackDurationRamp.advanceTo(_now + frameOffset);
            data->releaseDurationRamp.advanceTo(_now + frameOffset);
        }

        *data->_compressor0->ratio = data->ratioRamp.getValue();
        *data->_compressor1->ratio = data->ratioRamp.getValue();
        *data->_compressor0->thresh = data->thresholdRamp.getValue();
        *data->_compressor1->thresh = data->thresholdRamp.getValue();
        *data->_compressor0->atk = data->attackDurationRamp.getValue();
        *data->_compressor1->atk = data->attackDurationRamp.getValue();
        *data->_compressor0->rel = data->releaseDurationRamp.getValue();
        *data->_compressor1->rel = data->releaseDurationRamp.getValue();

        float *tmpin[2];
        float *tmpout[2];
        for (int channel = 0; channel < _nChannels; ++channel) {
            float *in  = (float *)_inBufferListPtr->mBuffers[channel].mData  + frameOffset;
            float *out = (float *)_outBufferListPtr->mBuffers[channel].mData + frameOffset;
            if (channel < 2) {
                tmpin[channel] = in;
                tmpout[channel] = out;
            }
            if (!_playing) {
                *out = *in;
                continue;
            }

            if (channel == 0) {
                sp_compressor_compute(_sp, data->_compressor0, in, out);
            } else {
                sp_compressor_compute(_sp, data->_compressor1, in, out);
            }
        }
    }
}
