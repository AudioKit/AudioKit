//
//  AKTanhDistortionDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKTanhDistortionDSP.hpp"
#import "AKLinearParameterRamp.hpp"

extern "C" AKDSPRef createTanhDistortionDSP(int channelCount, double sampleRate) {
    AKTanhDistortionDSP *dsp = new AKTanhDistortionDSP();
    dsp->init(channelCount, sampleRate);
    return dsp;
}

struct AKTanhDistortionDSP::InternalData {
    sp_dist *dist0;
    sp_dist *dist1;
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
            data->pregainRamp.setRampDuration(value, sampleRate);
            data->postgainRamp.setRampDuration(value, sampleRate);
            data->positiveShapeParameterRamp.setRampDuration(value, sampleRate);
            data->negativeShapeParameterRamp.setRampDuration(value, sampleRate);
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
            return data->pregainRamp.getRampDuration(sampleRate);
    }
    return 0;
}

void AKTanhDistortionDSP::init(int channelCount, double sampleRate) {
    AKSoundpipeDSPBase::init(channelCount, sampleRate);
    sp_dist_create(&data->dist0);
    sp_dist_init(sp, data->dist0);
    sp_dist_create(&data->dist1);
    sp_dist_init(sp, data->dist1);
    data->dist0->pregain = defaultPregain;
    data->dist1->pregain = defaultPregain;
    data->dist0->postgain = defaultPostgain;
    data->dist1->postgain = defaultPostgain;
    data->dist0->shape1 = defaultPositiveShapeParameter;
    data->dist1->shape1 = defaultPositiveShapeParameter;
    data->dist0->shape2 = defaultNegativeShapeParameter;
    data->dist1->shape2 = defaultNegativeShapeParameter;
}

void AKTanhDistortionDSP::deinit() {
    sp_dist_destroy(&data->dist0);
    sp_dist_destroy(&data->dist1);
}

void AKTanhDistortionDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            data->pregainRamp.advanceTo(now + frameOffset);
            data->postgainRamp.advanceTo(now + frameOffset);
            data->positiveShapeParameterRamp.advanceTo(now + frameOffset);
            data->negativeShapeParameterRamp.advanceTo(now + frameOffset);
        }

        data->dist0->pregain = data->pregainRamp.getValue();
        data->dist1->pregain = data->pregainRamp.getValue();
        data->dist0->postgain = data->postgainRamp.getValue();
        data->dist1->postgain = data->postgainRamp.getValue();
        data->dist0->shape1 = data->positiveShapeParameterRamp.getValue();
        data->dist1->shape1 = data->positiveShapeParameterRamp.getValue();
        data->dist0->shape2 = data->negativeShapeParameterRamp.getValue();
        data->dist1->shape2 = data->negativeShapeParameterRamp.getValue();

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
                sp_dist_compute(sp, data->dist0, in, out);
            } else {
                sp_dist_compute(sp, data->dist1, in, out);
            }
        }
    }
}
