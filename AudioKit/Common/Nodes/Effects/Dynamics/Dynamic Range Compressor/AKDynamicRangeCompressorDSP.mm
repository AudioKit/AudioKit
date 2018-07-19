//
//  AKDynamicRangeCompressorDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKDynamicRangeCompressorDSP.hpp"
#import "AKLinearParameterRamp.hpp"

extern "C" void* createDynamicRangeCompressorDSP(int nChannels, double sampleRate) {
    AKDynamicRangeCompressorDSP* dsp = new AKDynamicRangeCompressorDSP();
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

AKDynamicRangeCompressorDSP::AKDynamicRangeCompressorDSP() : _private(new _Internal) {
    _private->ratioRamp.setTarget(defaultRatio, true);
    _private->ratioRamp.setDurationInSamples(defaultRampDurationSamples);
    _private->thresholdRamp.setTarget(defaultThreshold, true);
    _private->thresholdRamp.setDurationInSamples(defaultRampDurationSamples);
    _private->attackDurationRamp.setTarget(defaultAttackDuration, true);
    _private->attackDurationRamp.setDurationInSamples(defaultRampDurationSamples);
    _private->releaseDurationRamp.setTarget(defaultReleaseDuration, true);
    _private->releaseDurationRamp.setDurationInSamples(defaultRampDurationSamples);
}

// Uses the ParameterAddress as a key
void AKDynamicRangeCompressorDSP::setParameter(AUParameterAddress address, AUValue value, bool immediate) {
    switch (address) {
        case AKDynamicRangeCompressorParameterRatio:
            _private->ratioRamp.setTarget(clamp(value, ratioLowerBound, ratioUpperBound), immediate);
            break;
        case AKDynamicRangeCompressorParameterThreshold:
            _private->thresholdRamp.setTarget(clamp(value, thresholdLowerBound, thresholdUpperBound), immediate);
            break;
        case AKDynamicRangeCompressorParameterAttackTime:
            _private->attackDurationRamp.setTarget(clamp(value, attackDurationLowerBound, attackDurationUpperBound), immediate);
            break;
        case AKDynamicRangeCompressorParameterReleaseTime:
            _private->releaseDurationRamp.setTarget(clamp(value, releaseDurationLowerBound, releaseDurationUpperBound), immediate);
            break;
        case AKDynamicRangeCompressorParameterRampDuration:
            _private->ratioRamp.setRampDuration(value, _sampleRate);
            _private->thresholdRamp.setRampDuration(value, _sampleRate);
            _private->attackDurationRamp.setRampDuration(value, _sampleRate);
            _private->releaseDurationRamp.setRampDuration(value, _sampleRate);
            break;
    }
}

// Uses the ParameterAddress as a key
float AKDynamicRangeCompressorDSP::getParameter(uint64_t address) {
    switch (address) {
        case AKDynamicRangeCompressorParameterRatio:
            return _private->ratioRamp.getTarget();
        case AKDynamicRangeCompressorParameterThreshold:
            return _private->thresholdRamp.getTarget();
        case AKDynamicRangeCompressorParameterAttackTime:
            return _private->attackDurationRamp.getTarget();
        case AKDynamicRangeCompressorParameterReleaseTime:
            return _private->releaseDurationRamp.getTarget();
        case AKDynamicRangeCompressorParameterRampDuration:
            return _private->ratioRamp.getRampDuration(_sampleRate);
    }
    return 0;
}

void AKDynamicRangeCompressorDSP::init(int _channels, double _sampleRate) {
    AKSoundpipeDSPBase::init(_channels, _sampleRate);
    sp_compressor_create(&_private->_compressor0);
    sp_compressor_init(_sp, _private->_compressor0);
    sp_compressor_create(&_private->_compressor1);
    sp_compressor_init(_sp, _private->_compressor1);
    *_private->_compressor0->ratio = defaultRatio;
    *_private->_compressor1->ratio = defaultRatio;
    *_private->_compressor0->thresh = defaultThreshold;
    *_private->_compressor1->thresh = defaultThreshold;
    *_private->_compressor0->atk = defaultAttackDuration;
    *_private->_compressor1->atk = defaultAttackDuration;
    *_private->_compressor0->rel = defaultReleaseDuration;
    *_private->_compressor1->rel = defaultReleaseDuration;
}

void AKDynamicRangeCompressorDSP::destroy() {
    sp_compressor_destroy(&_private->_compressor0);
    sp_compressor_destroy(&_private->_compressor1);
    AKSoundpipeDSPBase::destroy();
}

void AKDynamicRangeCompressorDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            _private->ratioRamp.advanceTo(_now + frameOffset);
            _private->thresholdRamp.advanceTo(_now + frameOffset);
            _private->attackDurationRamp.advanceTo(_now + frameOffset);
            _private->releaseDurationRamp.advanceTo(_now + frameOffset);
        }

        *_private->_compressor0->ratio = _private->ratioRamp.getValue();
        *_private->_compressor1->ratio = _private->ratioRamp.getValue();
        *_private->_compressor0->thresh = _private->thresholdRamp.getValue();
        *_private->_compressor1->thresh = _private->thresholdRamp.getValue();
        *_private->_compressor0->atk = _private->attackDurationRamp.getValue();
        *_private->_compressor1->atk = _private->attackDurationRamp.getValue();
        *_private->_compressor0->rel = _private->releaseDurationRamp.getValue();
        *_private->_compressor1->rel = _private->releaseDurationRamp.getValue();

        float *tmpin[2];
        float *tmpout[2];
        for (int channel = 0; channel < _nChannels; ++channel) {
            float* in  = (float *)_inBufferListPtr->mBuffers[channel].mData  + frameOffset;
            float* out = (float *)_outBufferListPtr->mBuffers[channel].mData + frameOffset;
            if (channel < 2) {
                tmpin[channel] = in;
                tmpout[channel] = out;
            }
            if (!_playing) {
                *out = *in;
                continue;
            }

            if (channel == 0) {
                sp_compressor_compute(_sp, _private->_compressor0, in, out);
            } else {
                sp_compressor_compute(_sp, _private->_compressor1, in, out);
            }
        }
    }
}
