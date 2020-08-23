// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKSoundpipeDSPBase.hpp"
#include "ParameterRamper.hpp"
#include "soundpipe.h"
#include "plumber.h"

enum AKOperationGeneratorParameter : AUParameterAddress {
    AKOperationGeneratorParameter1,
    AKOperationGeneratorParameter2,
    AKOperationGeneratorParameter3,
    AKOperationGeneratorParameter4,
    AKOperationGeneratorParameter5,
    AKOperationGeneratorParameter6,
    AKOperationGeneratorParameter7,
    AKOperationGeneratorParameter8,
    AKOperationGeneratorParameter9,
    AKOperationGeneratorParameter10,
    AKOperationGeneratorParameter11,
    AKOperationGeneratorParameter12,
    AKOperationGeneratorParameter13,
    AKOperationGeneratorParameter14,
};

class AKOperationGeneratorDSP : public AKSoundpipeDSPBase {
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
    int internalTrigger = 0;

public:
    AKOperationGeneratorDSP() {
        parameters[AKOperationGeneratorParameter1] = &parameter1Ramp;
        parameters[AKOperationGeneratorParameter2] = &parameter2Ramp;
        parameters[AKOperationGeneratorParameter3] = &parameter3Ramp;
        parameters[AKOperationGeneratorParameter4] = &parameter4Ramp;
        parameters[AKOperationGeneratorParameter5] = &parameter5Ramp;
        parameters[AKOperationGeneratorParameter6] = &parameter6Ramp;
        parameters[AKOperationGeneratorParameter7] = &parameter7Ramp;
        parameters[AKOperationGeneratorParameter8] = &parameter8Ramp;
        parameters[AKOperationGeneratorParameter9] = &parameter9Ramp;
        parameters[AKOperationGeneratorParameter10] = &parameter10Ramp;
        parameters[AKOperationGeneratorParameter11] = &parameter11Ramp;
        parameters[AKOperationGeneratorParameter12] = &parameter12Ramp;
        parameters[AKOperationGeneratorParameter13] = &parameter13Ramp;
        parameters[AKOperationGeneratorParameter14] = &parameter14Ramp;
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

    void trigger() override {
        internalTrigger = 1;
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

            parameters[AKOperationGeneratorParameter1] = &parameter1Ramp;
            parameters[AKOperationGeneratorParameter2] = &parameter2Ramp;
            parameters[AKOperationGeneratorParameter3] = &parameter3Ramp;
            parameters[AKOperationGeneratorParameter4] = &parameter4Ramp;
            parameters[AKOperationGeneratorParameter5] = &parameter5Ramp;
            parameters[AKOperationGeneratorParameter6] = &parameter6Ramp;
            parameters[AKOperationGeneratorParameter7] = &parameter7Ramp;
            parameters[AKOperationGeneratorParameter8] = &parameter8Ramp;
            parameters[AKOperationGeneratorParameter9] = &parameter9Ramp;
            parameters[AKOperationGeneratorParameter10] = &parameter10Ramp;
            parameters[AKOperationGeneratorParameter11] = &parameter11Ramp;
            parameters[AKOperationGeneratorParameter12] = &parameter12Ramp;
            parameters[AKOperationGeneratorParameter13] = &parameter13Ramp;
            parameters[AKOperationGeneratorParameter14] = &parameter14Ramp;

            if (internalTrigger == 1) {
                pd.p[15] = 1.0;
            }

            plumber_compute(&pd, PLUMBER_COMPUTE);

            for (int channel = 0; channel < channelCount; ++channel) {
                float *out = (float *)outputBufferList->mBuffers[channel].mData + frameOffset;
                *out = sporth_stack_pop_float(&pd.sporth.stack);
            }

            internalTrigger = 0;
        }
    }
};

AK_API void akOperationGeneratorSetSporth(AKDSPRef dspRef, const char *sporth, int length) {
    auto dsp = dynamic_cast<AKOperationGeneratorDSP *>(dspRef);
    assert(dsp);
    dsp->setSporth(sporth, length);
}

AK_API float* akOperationGeneratorTrigger(AKDSPRef dspRef) {
    auto dsp = dynamic_cast<AKOperationGeneratorDSP *>(dspRef);
    assert(dsp);
    dsp->trigger();
}

AK_REGISTER_DSP(AKOperationGeneratorDSP)
AK_REGISTER_PARAMETER(AKOperationGeneratorParameter1)
AK_REGISTER_PARAMETER(AKOperationGeneratorParameter2)
AK_REGISTER_PARAMETER(AKOperationGeneratorParameter3)
AK_REGISTER_PARAMETER(AKOperationGeneratorParameter4)
AK_REGISTER_PARAMETER(AKOperationGeneratorParameter5)
AK_REGISTER_PARAMETER(AKOperationGeneratorParameter6)
AK_REGISTER_PARAMETER(AKOperationGeneratorParameter7)
AK_REGISTER_PARAMETER(AKOperationGeneratorParameter8)
AK_REGISTER_PARAMETER(AKOperationGeneratorParameter9)
AK_REGISTER_PARAMETER(AKOperationGeneratorParameter10)
AK_REGISTER_PARAMETER(AKOperationGeneratorParameter11)
AK_REGISTER_PARAMETER(AKOperationGeneratorParameter12)
AK_REGISTER_PARAMETER(AKOperationGeneratorParameter13)
AK_REGISTER_PARAMETER(AKOperationGeneratorParameter14)
