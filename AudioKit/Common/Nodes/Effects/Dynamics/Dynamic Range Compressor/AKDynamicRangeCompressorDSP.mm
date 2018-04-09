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
    AKLinearParameterRamp attackTimeRamp;
    AKLinearParameterRamp releaseTimeRamp;
};

AKDynamicRangeCompressorDSP::AKDynamicRangeCompressorDSP() : _private(new _Internal) {
    _private->ratioRamp.setTarget(defaultRatio, true);
    _private->ratioRamp.setDurationInSamples(defaultRampTimeSamples);
    _private->thresholdRamp.setTarget(defaultThreshold, true);
    _private->thresholdRamp.setDurationInSamples(defaultRampTimeSamples);
    _private->attackTimeRamp.setTarget(defaultAttackTime, true);
    _private->attackTimeRamp.setDurationInSamples(defaultRampTimeSamples);
    _private->releaseTimeRamp.setTarget(defaultReleaseTime, true);
    _private->releaseTimeRamp.setDurationInSamples(defaultRampTimeSamples);
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
            _private->attackTimeRamp.setTarget(clamp(value, attackTimeLowerBound, attackTimeUpperBound), immediate);
            break;
        case AKDynamicRangeCompressorParameterReleaseTime:
            _private->releaseTimeRamp.setTarget(clamp(value, releaseTimeLowerBound, releaseTimeUpperBound), immediate);
            break;
        case AKDynamicRangeCompressorParameterRampTime:
            _private->ratioRamp.setRampTime(value, _sampleRate);
            _private->thresholdRamp.setRampTime(value, _sampleRate);
            _private->attackTimeRamp.setRampTime(value, _sampleRate);
            _private->releaseTimeRamp.setRampTime(value, _sampleRate);
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
            return _private->attackTimeRamp.getTarget();
        case AKDynamicRangeCompressorParameterReleaseTime:
            return _private->releaseTimeRamp.getTarget();
        case AKDynamicRangeCompressorParameterRampTime:
            return _private->ratioRamp.getRampTime(_sampleRate);
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
    *_private->_compressor0->atk = defaultAttackTime;
    *_private->_compressor1->atk = defaultAttackTime;
    *_private->_compressor0->rel = defaultReleaseTime;
    *_private->_compressor1->rel = defaultReleaseTime;
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
            _private->attackTimeRamp.advanceTo(_now + frameOffset);
            _private->releaseTimeRamp.advanceTo(_now + frameOffset);
        }

        *_private->_compressor0->ratio = _private->ratioRamp.getValue();
        *_private->_compressor1->ratio = _private->ratioRamp.getValue();
        *_private->_compressor0->thresh = _private->thresholdRamp.getValue();
        *_private->_compressor1->thresh = _private->thresholdRamp.getValue();
        *_private->_compressor0->atk = _private->attackTimeRamp.getValue();
        *_private->_compressor1->atk = _private->attackTimeRamp.getValue();
        *_private->_compressor0->rel = _private->releaseTimeRamp.getValue();
        *_private->_compressor1->rel = _private->releaseTimeRamp.getValue();

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
