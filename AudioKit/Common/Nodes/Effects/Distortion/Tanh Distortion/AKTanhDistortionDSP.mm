//
//  AKTanhDistortionDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKTanhDistortionDSP.hpp"
#import "AKLinearParameterRamp.hpp"

extern "C" AKDSPRef createTanhDistortionDSP(int nChannels, double sampleRate) {
    AKTanhDistortionDSP *dsp = new AKTanhDistortionDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}

struct AKTanhDistortionDSP::InternalData {
    sp_dist *_dist0;
    sp_dist *_dist1;
    AKLinearParameterRamp pregainRamp;
    AKLinearParameterRamp postgainRamp;
    AKLinearParameterRamp positiveShapeParameterRamp;
    AKLinearParameterRamp negativeShapeParameterRamp;
};

AKTanhDistortionDSP::AKTanhDistortionDSP() : data(new InternalData) {
    data->pregainRamp.setTarget(defaultPregain, true);
    data->pregainRamp.setDurationInSamples(defaultRampDurationSamples);
    data->postgainRamp.setTarget(defaultPostgain, true);
    data->postgainRamp.setDurationInSamples(defaultRampDurationSamples);
    data->positiveShapeParameterRamp.setTarget(defaultPositiveShapeParameter, true);
    data->positiveShapeParameterRamp.setDurationInSamples(defaultRampDurationSamples);
    data->negativeShapeParameterRamp.setTarget(defaultNegativeShapeParameter, true);
    data->negativeShapeParameterRamp.setDurationInSamples(defaultRampDurationSamples);
}

// Uses the ParameterAddress as a key
void AKTanhDistortionDSP::setParameter(AUParameterAddress address, AUValue value, bool immediate) {
    switch (address) {
        case AKTanhDistortionParameterPregain:
            data->pregainRamp.setTarget(clamp(value, pregainLowerBound, pregainUpperBound), immediate);
            break;
        case AKTanhDistortionParameterPostgain:
            data->postgainRamp.setTarget(clamp(value, postgainLowerBound, postgainUpperBound), immediate);
            break;
        case AKTanhDistortionParameterPositiveShapeParameter:
            data->positiveShapeParameterRamp.setTarget(clamp(value, positiveShapeParameterLowerBound, positiveShapeParameterUpperBound), immediate);
            break;
        case AKTanhDistortionParameterNegativeShapeParameter:
            data->negativeShapeParameterRamp.setTarget(clamp(value, negativeShapeParameterLowerBound, negativeShapeParameterUpperBound), immediate);
            break;
        case AKTanhDistortionParameterRampDuration:
            data->pregainRamp.setRampDuration(value, _sampleRate);
            data->postgainRamp.setRampDuration(value, _sampleRate);
            data->positiveShapeParameterRamp.setRampDuration(value, _sampleRate);
            data->negativeShapeParameterRamp.setRampDuration(value, _sampleRate);
            break;
    }
}

// Uses the ParameterAddress as a key
float AKTanhDistortionDSP::getParameter(uint64_t address) {
    switch (address) {
        case AKTanhDistortionParameterPregain:
            return data->pregainRamp.getTarget();
        case AKTanhDistortionParameterPostgain:
            return data->postgainRamp.getTarget();
        case AKTanhDistortionParameterPositiveShapeParameter:
            return data->positiveShapeParameterRamp.getTarget();
        case AKTanhDistortionParameterNegativeShapeParameter:
            return data->negativeShapeParameterRamp.getTarget();
        case AKTanhDistortionParameterRampDuration:
            return data->pregainRamp.getRampDuration(_sampleRate);
    }
    return 0;
}

void AKTanhDistortionDSP::init(int _channels, double _sampleRate) {
    AKSoundpipeDSPBase::init(_channels, _sampleRate);
    sp_dist_create(&data->_dist0);
    sp_dist_init(_sp, data->_dist0);
    sp_dist_create(&data->_dist1);
    sp_dist_init(_sp, data->_dist1);
    data->_dist0->pregain = defaultPregain;
    data->_dist1->pregain = defaultPregain;
    data->_dist0->postgain = defaultPostgain;
    data->_dist1->postgain = defaultPostgain;
    data->_dist0->shape1 = defaultPositiveShapeParameter;
    data->_dist1->shape1 = defaultPositiveShapeParameter;
    data->_dist0->shape2 = defaultNegativeShapeParameter;
    data->_dist1->shape2 = defaultNegativeShapeParameter;
}

void AKTanhDistortionDSP::deinit() {
    sp_dist_destroy(&data->_dist0);
    sp_dist_destroy(&data->_dist1);
}

void AKTanhDistortionDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            data->pregainRamp.advanceTo(_now + frameOffset);
            data->postgainRamp.advanceTo(_now + frameOffset);
            data->positiveShapeParameterRamp.advanceTo(_now + frameOffset);
            data->negativeShapeParameterRamp.advanceTo(_now + frameOffset);
        }

        data->_dist0->pregain = data->pregainRamp.getValue();
        data->_dist1->pregain = data->pregainRamp.getValue();
        data->_dist0->postgain = data->postgainRamp.getValue();
        data->_dist1->postgain = data->postgainRamp.getValue();
        data->_dist0->shape1 = data->positiveShapeParameterRamp.getValue();
        data->_dist1->shape1 = data->positiveShapeParameterRamp.getValue();
        data->_dist0->shape2 = data->negativeShapeParameterRamp.getValue();
        data->_dist1->shape2 = data->negativeShapeParameterRamp.getValue();

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
                sp_dist_compute(_sp, data->_dist0, in, out);
            } else {
                sp_dist_compute(_sp, data->_dist1, in, out);
            }
        }
    }
}
