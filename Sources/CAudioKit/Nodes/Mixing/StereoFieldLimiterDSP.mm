// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "DSPBase.h"
#include "ParameterRamper.h"

enum StereoFieldLimiterParameter : AUParameterAddress {
    StereoFieldLimiterParameterAmount,
};

struct StereoFieldLimiterDSP : DSPBase {
private:
    ParameterRamper amountRamp;

public:

    StereoFieldLimiterDSP() {
        parameters[StereoFieldLimiterParameterAmount] = &amountRamp;
    }
    
    void init(int channelCount, double sampleRate) override {
        DSPBase::init(channelCount, sampleRate);
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);
            
            float amount = amountRamp.getAndStep();

            if (!isStarted) {
                outputBufferList->mBuffers[0] = inputBufferLists[0]->mBuffers[0];
                outputBufferList->mBuffers[1] = inputBufferLists[0]->mBuffers[1];
                return;
            }

            float *tmpin[2];
            float *tmpout[2];
            for (int channel = 0; channel < channelCount; ++channel) {
                float *in  = (float *)inputBufferLists[0]->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)outputBufferList->mBuffers[channel].mData + frameOffset;
                if (channel < 2) {
                    tmpin[channel] = in;
                    tmpout[channel] = out;
                }
            }
            *tmpout[0] = *tmpin[0] * (1.0f - amount / 2.0) + *tmpin[1] * amount / 2.0;
            *tmpout[1] = *tmpin[1] * (1.0f - amount / 2.0) + *tmpin[0] * amount / 2.0;
        }
    }
};

DSPRef akStereoFieldLimiterCreateDSP() {
    return new StereoFieldLimiterDSP();
}
AK_REGISTER_DSP(StereoFieldLimiterDSP)
AK_REGISTER_PARAMETER(StereoFieldLimiterParameterAmount)
