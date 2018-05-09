//
//  AKTanhDistortionDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKTanhDistortionDSP.hpp"
#import "AKLinearParameterRamp.hpp"

extern "C" void* createTanhDistortionDSP(int nChannels, double sampleRate) {
    AKTanhDistortionDSP* dsp = new AKTanhDistortionDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}

struct AKTanhDistortionDSP::_Internal {
    sp_dist *_dist0;
    sp_dist *_dist1;
    AKLinearParameterRamp pregainRamp;
    AKLinearParameterRamp postgainRamp;
    AKLinearParameterRamp positiveShapeParameterRamp;
    AKLinearParameterRamp negativeShapeParameterRamp;
};

AKTanhDistortionDSP::AKTanhDistortionDSP() : _private(new _Internal) {
    _private->pregainRamp.setTarget(defaultPregain, true);
    _private->pregainRamp.setDurationInSamples(defaultRampDurationSamples);
    _private->postgainRamp.setTarget(defaultPostgain, true);
    _private->postgainRamp.setDurationInSamples(defaultRampDurationSamples);
    _private->positiveShapeParameterRamp.setTarget(defaultPositiveShapeParameter, true);
    _private->positiveShapeParameterRamp.setDurationInSamples(defaultRampDurationSamples);
    _private->negativeShapeParameterRamp.setTarget(defaultNegativeShapeParameter, true);
    _private->negativeShapeParameterRamp.setDurationInSamples(defaultRampDurationSamples);
}

// Uses the ParameterAddress as a key
void AKTanhDistortionDSP::setParameter(AUParameterAddress address, AUValue value, bool immediate) {
    switch (address) {
        case AKTanhDistortionParameterPregain:
            _private->pregainRamp.setTarget(clamp(value, pregainLowerBound, pregainUpperBound), immediate);
            break;
        case AKTanhDistortionParameterPostgain:
            _private->postgainRamp.setTarget(clamp(value, postgainLowerBound, postgainUpperBound), immediate);
            break;
        case AKTanhDistortionParameterPositiveShapeParameter:
            _private->positiveShapeParameterRamp.setTarget(clamp(value, positiveShapeParameterLowerBound, positiveShapeParameterUpperBound), immediate);
            break;
        case AKTanhDistortionParameterNegativeShapeParameter:
            _private->negativeShapeParameterRamp.setTarget(clamp(value, negativeShapeParameterLowerBound, negativeShapeParameterUpperBound), immediate);
            break;
        case AKTanhDistortionParameterRampDuration:
            _private->pregainRamp.setRampDuration(value, _sampleRate);
            _private->postgainRamp.setRampDuration(value, _sampleRate);
            _private->positiveShapeParameterRamp.setRampDuration(value, _sampleRate);
            _private->negativeShapeParameterRamp.setRampDuration(value, _sampleRate);
            break;
    }
}

// Uses the ParameterAddress as a key
float AKTanhDistortionDSP::getParameter(uint64_t address) {
    switch (address) {
        case AKTanhDistortionParameterPregain:
            return _private->pregainRamp.getTarget();
        case AKTanhDistortionParameterPostgain:
            return _private->postgainRamp.getTarget();
        case AKTanhDistortionParameterPositiveShapeParameter:
            return _private->positiveShapeParameterRamp.getTarget();
        case AKTanhDistortionParameterNegativeShapeParameter:
            return _private->negativeShapeParameterRamp.getTarget();
        case AKTanhDistortionParameterRampDuration:
            return _private->pregainRamp.getRampDuration(_sampleRate);
    }
    return 0;
}

void AKTanhDistortionDSP::init(int _channels, double _sampleRate) {
    AKSoundpipeDSPBase::init(_channels, _sampleRate);
    sp_dist_create(&_private->_dist0);
    sp_dist_init(_sp, _private->_dist0);
    sp_dist_create(&_private->_dist1);
    sp_dist_init(_sp, _private->_dist1);
    _private->_dist0->pregain = defaultPregain;
    _private->_dist1->pregain = defaultPregain;
    _private->_dist0->postgain = defaultPostgain;
    _private->_dist1->postgain = defaultPostgain;
    _private->_dist0->shape1 = defaultPositiveShapeParameter;
    _private->_dist1->shape1 = defaultPositiveShapeParameter;
    _private->_dist0->shape2 = defaultNegativeShapeParameter;
    _private->_dist1->shape2 = defaultNegativeShapeParameter;
}

void AKTanhDistortionDSP::destroy() {
    sp_dist_destroy(&_private->_dist0);
    sp_dist_destroy(&_private->_dist1);
    AKSoundpipeDSPBase::destroy();
}

void AKTanhDistortionDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            _private->pregainRamp.advanceTo(_now + frameOffset);
            _private->postgainRamp.advanceTo(_now + frameOffset);
            _private->positiveShapeParameterRamp.advanceTo(_now + frameOffset);
            _private->negativeShapeParameterRamp.advanceTo(_now + frameOffset);
        }

        _private->_dist0->pregain = _private->pregainRamp.getValue();
        _private->_dist1->pregain = _private->pregainRamp.getValue();
        _private->_dist0->postgain = _private->postgainRamp.getValue();
        _private->_dist1->postgain = _private->postgainRamp.getValue();
        _private->_dist0->shape1 = _private->positiveShapeParameterRamp.getValue();
        _private->_dist1->shape1 = _private->positiveShapeParameterRamp.getValue();
        _private->_dist0->shape2 = _private->negativeShapeParameterRamp.getValue();
        _private->_dist1->shape2 = _private->negativeShapeParameterRamp.getValue();

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
                sp_dist_compute(_sp, _private->_dist0, in, out);
            } else {
                sp_dist_compute(_sp, _private->_dist1, in, out);
            }
        }
    }
}
