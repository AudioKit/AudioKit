// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKTanhDistortionDSP.hpp"
#include "ParameterRamper.hpp"

#import "AKSoundpipeDSPBase.hpp"

class AKTanhDistortionDSP : public AKSoundpipeDSPBase {
private:
    sp_dist *dist0;
    sp_dist *dist1;
    ParameterRamper pregainRamp;
    ParameterRamper postgainRamp;
    ParameterRamper positiveShapeParameterRamp;
    ParameterRamper negativeShapeParameterRamp;

public:
    AKTanhDistortionDSP() {
        parameters[AKTanhDistortionParameterPregain] = &pregainRamp;
        parameters[AKTanhDistortionParameterPostgain] = &postgainRamp;
        parameters[AKTanhDistortionParameterPositiveShapeParameter] = &positiveShapeParameterRamp;
        parameters[AKTanhDistortionParameterNegativeShapeParameter] = &negativeShapeParameterRamp;
    }

    void init(int channelCount, double sampleRate) {
        AKSoundpipeDSPBase::init(channelCount, sampleRate);
        sp_dist_create(&dist0);
        sp_dist_init(sp, dist0);
        sp_dist_create(&dist1);
        sp_dist_init(sp, dist1);
    }

    void deinit() {
        AKSoundpipeDSPBase::deinit();
        sp_dist_destroy(&dist0);
        sp_dist_destroy(&dist1);
    }

    void reset() {
        AKSoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_dist_init(sp, dist0);
        sp_dist_init(sp, dist1);
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            float pregain = pregainRamp.getAndStep();
            dist0->pregain = pregain;
            dist1->pregain = pregain;

            float postgain = postgainRamp.getAndStep();
            dist0->postgain = postgain;
            dist1->postgain = postgain;

            float positiveShapeParameter = positiveShapeParameterRamp.getAndStep();
            dist0->shape1 = positiveShapeParameter;
            dist1->shape1 = positiveShapeParameter;

            float negativeShapeParameter = negativeShapeParameterRamp.getAndStep();
            dist0->shape2 = negativeShapeParameter;
            dist1->shape2 = negativeShapeParameter;

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
                    sp_dist_compute(sp, dist0, in, out);
                } else {
                    sp_dist_compute(sp, dist1, in, out);
                }
            }
        }
    }
};

extern "C" AKDSPRef createTanhDistortionDSP() {
    return new AKTanhDistortionDSP();
}