// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKTanhDistortionDSP.hpp"
#include "ParameterRamper.hpp"

extern "C" AKDSPRef createTanhDistortionDSP() {
    return new AKTanhDistortionDSP();
}

struct AKTanhDistortionDSP::InternalData {
    sp_dist *dist0;
    sp_dist *dist1;
    ParameterRamper pregainRamp;
    ParameterRamper postgainRamp;
    ParameterRamper positiveShapeParameterRamp;
    ParameterRamper negativeShapeParameterRamp;
};

AKTanhDistortionDSP::AKTanhDistortionDSP() : data(new InternalData) {
    parameters[AKTanhDistortionParameterPregain] = &data->pregainRamp;
    parameters[AKTanhDistortionParameterPostgain] = &data->postgainRamp;
    parameters[AKTanhDistortionParameterPositiveShapeParameter] = &data->positiveShapeParameterRamp;
    parameters[AKTanhDistortionParameterNegativeShapeParameter] = &data->negativeShapeParameterRamp;
}

void AKTanhDistortionDSP::init(int channelCount, double sampleRate) {
    AKSoundpipeDSPBase::init(channelCount, sampleRate);
    sp_dist_create(&data->dist0);
    sp_dist_init(sp, data->dist0);
    sp_dist_create(&data->dist1);
    sp_dist_init(sp, data->dist1);
}

void AKTanhDistortionDSP::deinit() {
    AKSoundpipeDSPBase::deinit();
    sp_dist_destroy(&data->dist0);
    sp_dist_destroy(&data->dist1);
}

void AKTanhDistortionDSP::reset() {
    AKSoundpipeDSPBase::reset();
    if (!isInitialized) return;
    sp_dist_init(sp, data->dist0);
    sp_dist_init(sp, data->dist1);
}

void AKTanhDistortionDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        float pregain = data->pregainRamp.getAndStep();
        data->dist0->pregain = pregain;
        data->dist1->pregain = pregain;

        float postgain = data->postgainRamp.getAndStep();
        data->dist0->postgain = postgain;
        data->dist1->postgain = postgain;

        float positiveShapeParameter = data->positiveShapeParameterRamp.getAndStep();
        data->dist0->shape1 = positiveShapeParameter;
        data->dist1->shape1 = positiveShapeParameter;

        float negativeShapeParameter = data->negativeShapeParameterRamp.getAndStep();
        data->dist0->shape2 = negativeShapeParameter;
        data->dist1->shape2 = negativeShapeParameter;

        float *tmpin[2];
        float *tmpout[2];
        for (int channel = 0; channel < channelCount; ++channel) {
            float *in  = (float *)inputBufferLists[0]->mBuffers[channel].mData  + frameOffset;
            float *out = (float *)outputBufferLists[0]->mBuffers[channel].mData + frameOffset;
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
