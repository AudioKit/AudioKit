// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKTanhDistortionDSP.hpp"
#include "AKLinearParameterRamp.hpp"

extern "C" AKDSPRef createTanhDistortionDSP() {
    return new AKTanhDistortionDSP();
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
