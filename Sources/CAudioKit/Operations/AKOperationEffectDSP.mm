// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKSoundpipeDSPBase.hpp"
#include "ParameterRamper.hpp"
#include "soundpipe.h"
#include "plumber.h"

enum AKOperationEffectParameter : AUParameterAddress {
    AKOperationEffectParameter1,
    AKOperationEffectParameter2,
    AKOperationEffectParameter3,
    AKOperationEffectParameter4,
    AKOperationEffectParameter5,
    AKOperationEffectParameter6,
    AKOperationEffectParameter7,
    AKOperationEffectParameter8,
    AKOperationEffectParameter9,
    AKOperationEffectParameter10,
    AKOperationEffectParameter11,
    AKOperationEffectParameter12,
    AKOperationEffectParameter13,
    AKOperationEffectParameter14,
};

class AKOperationEffectDSP : public AKSoundpipeDSPBase {
private:
    plumber_data pd;
    char *sporthCode = nil;
    ParameterRamper parameter1Ramp;
    ParameterRamper parameter2Ramp;
    ParameterRamper parameter3Ramp;
    ParameterRamper parameter4Ramp;
    ParameterRamper parameter5Ramp;
    ParameterRamper parameter6Ramp;
    ParameterRamper parameter7Ramp;
    ParameterRamper parameter8Ramp;
    ParameterRamper parameter9Ramp;
    ParameterRamper parameter10Ramp;
    ParameterRamper parameter11Ramp;
    ParameterRamper parameter12Ramp;
    ParameterRamper parameter13Ramp;
    ParameterRamper parameter14Ramp;

public:
    AKOperationEffectDSP() {
        parameters[AKOperationEffectParameter1] = &parameter1Ramp;
        parameters[AKOperationEffectParameter2] = &parameter2Ramp;
        parameters[AKOperationEffectParameter3] = &parameter3Ramp;
        parameters[AKOperationEffectParameter4] = &parameter4Ramp;
        parameters[AKOperationEffectParameter5] = &parameter5Ramp;
        parameters[AKOperationEffectParameter6] = &parameter6Ramp;
        parameters[AKOperationEffectParameter7] = &parameter7Ramp;
        parameters[AKOperationEffectParameter8] = &parameter8Ramp;
        parameters[AKOperationEffectParameter9] = &parameter9Ramp;
        parameters[AKOperationEffectParameter10] = &parameter10Ramp;
        parameters[AKOperationEffectParameter11] = &parameter11Ramp;
        parameters[AKOperationEffectParameter12] = &parameter12Ramp;
        parameters[AKOperationEffectParameter13] = &parameter13Ramp;
        parameters[AKOperationEffectParameter14] = &parameter14Ramp;
        bCanProcessInPlace = false;
    }

    void setSporth(const char *sporth, int length) {
        if (sporthCode) {
            free(sporthCode);
            sporthCode = NULL;
        }
        if (length) {
            sporthCode = (char *)malloc(length);
            memcpy(sporthCode, sporth, length);
        }
    }

    void init(int channelCount, double sampleRate) override {
        AKSoundpipeDSPBase::init(channelCount, sampleRate);
        plumber_register(&pd);
        plumber_init(&pd);

        pd.sp = sp;
        if (sporthCode != nil) {
            plumber_parse_string(&pd, sporthCode);
            plumber_compute(&pd, PLUMBER_INIT);
        }
    }

    void deinit() override {
        AKSoundpipeDSPBase::deinit();
        plumber_clean(&pd);
    }

    void reset() override {
        AKSoundpipeDSPBase::reset();
        if (!isInitialized) return;
        plumber_init(&pd);

        pd.sp = sp;
        if (sporthCode != nil) {
            plumber_parse_string(&pd, sporthCode);
            plumber_compute(&pd, PLUMBER_INIT);
        }
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {

            int frameOffset = int(frameIndex + bufferOffset);

            for (int channel = 0; channel < channelCount; ++channel) {
                float *in  = (float *)inputBufferLists[0]->mBuffers[channel].mData  + frameOffset;
                if (channel < 2) {
                    pd.p[channel+14] = *in;
                }
            }

            pd.p[0] = parameter1Ramp.getAndStep();
            pd.p[1] = parameter2Ramp.getAndStep();
            pd.p[2] = parameter3Ramp.getAndStep();
            pd.p[3] = parameter4Ramp.getAndStep();
            pd.p[4] = parameter5Ramp.getAndStep();
            pd.p[5] = parameter6Ramp.getAndStep();
            pd.p[6] = parameter7Ramp.getAndStep();
            pd.p[7] = parameter8Ramp.getAndStep();
            pd.p[8] = parameter9Ramp.getAndStep();
            pd.p[9] = parameter10Ramp.getAndStep();
            pd.p[10] = parameter11Ramp.getAndStep();
            pd.p[11] = parameter12Ramp.getAndStep();
            pd.p[12] = parameter13Ramp.getAndStep();
            pd.p[13] = parameter14Ramp.getAndStep();

            plumber_compute(&pd, PLUMBER_COMPUTE);

            for (int channel = 0; channel < channelCount; ++channel) {
                float *out = (float *)outputBufferList->mBuffers[channel].mData + frameOffset;
                *out = sporth_stack_pop_float(&pd.sporth.stack);
            }
        }
    }
};

AK_API void akOperationEffectSetSporth(AKDSPRef dspRef, const char *sporth, int length) {
    auto dsp = dynamic_cast<AKOperationEffectDSP *>(dspRef);
    assert(dsp);
    dsp->setSporth(sporth, length);
}

AK_REGISTER_DSP(AKOperationEffectDSP)
AK_REGISTER_PARAMETER(AKOperationEffectParameter1)
AK_REGISTER_PARAMETER(AKOperationEffectParameter2)
AK_REGISTER_PARAMETER(AKOperationEffectParameter3)
AK_REGISTER_PARAMETER(AKOperationEffectParameter4)
AK_REGISTER_PARAMETER(AKOperationEffectParameter5)
AK_REGISTER_PARAMETER(AKOperationEffectParameter6)
AK_REGISTER_PARAMETER(AKOperationEffectParameter7)
AK_REGISTER_PARAMETER(AKOperationEffectParameter8)
AK_REGISTER_PARAMETER(AKOperationEffectParameter9)
AK_REGISTER_PARAMETER(AKOperationEffectParameter10)
AK_REGISTER_PARAMETER(AKOperationEffectParameter11)
AK_REGISTER_PARAMETER(AKOperationEffectParameter12)
AK_REGISTER_PARAMETER(AKOperationEffectParameter13)
AK_REGISTER_PARAMETER(AKOperationEffectParameter14)
