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
    
    void process(FrameRange range) override {

        for (int i : range) {

            float amount = amountRamp.getAndStep();
            
            float leftIn = inputSample(0, i);
            float rightIn = inputSample(1, i);

            float &leftOut = outputSample(0, i);
            float &rightOut = outputSample(1, i);
            
            leftOut = leftIn * (1.0f - amount / 2.0) + rightIn * amount / 2.0;
            rightOut = rightIn * (1.0f - amount / 2.0) + leftIn * amount / 2.0;
        }

    }

};

DSPRef akStereoFieldLimiterCreateDSP() {
    return new StereoFieldLimiterDSP();
}
AK_REGISTER_DSP(StereoFieldLimiterDSP, "sflm")
AK_REGISTER_PARAMETER(StereoFieldLimiterParameterAmount)
