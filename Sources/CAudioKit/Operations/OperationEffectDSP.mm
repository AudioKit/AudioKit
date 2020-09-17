// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"
#include "soundpipe.h"
#include "plumber.h"

enum OperationEffectParameter : AUParameterAddress {
    OperationEffectParameter1,
    OperationEffectParameter2,
    OperationEffectParameter3,
    OperationEffectParameter4,
    OperationEffectParameter5,
    OperationEffectParameter6,
    OperationEffectParameter7,
    OperationEffectParameter8,
    OperationEffectParameter9,
    OperationEffectParameter10,
    OperationEffectParameter11,
    OperationEffectParameter12,
    OperationEffectParameter13,
    OperationEffectParameter14,
};

class OperationEffectDSP : public SoundpipeDSPBase {
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
    OperationEffectDSP() {
        parameters[OperationEffectParameter1] = &parameter1Ramp;
        parameters[OperationEffectParameter2] = &parameter2Ramp;
        parameters[OperationEffectParameter3] = &parameter3Ramp;
        parameters[OperationEffectParameter4] = &parameter4Ramp;
        parameters[OperationEffectParameter5] = &parameter5Ramp;
        parameters[OperationEffectParameter6] = &parameter6Ramp;
        parameters[OperationEffectParameter7] = &parameter7Ramp;
        parameters[OperationEffectParameter8] = &parameter8Ramp;
        parameters[OperationEffectParameter9] = &parameter9Ramp;
        parameters[OperationEffectParameter10] = &parameter10Ramp;
        parameters[OperationEffectParameter11] = &parameter11Ramp;
        parameters[OperationEffectParameter12] = &parameter12Ramp;
        parameters[OperationEffectParameter13] = &parameter13Ramp;
        parameters[OperationEffectParameter14] = &parameter14Ramp;
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
        SoundpipeDSPBase::init(channelCount, sampleRate);
        plumber_register(&pd);
        plumber_init(&pd);

        pd.sp = sp;
        if (sporthCode != nil) {
            plumber_parse_string(&pd, sporthCode);
            plumber_compute(&pd, PLUMBER_INIT);
        }
    }

    void deinit() override {
        SoundpipeDSPBase::deinit();
        plumber_clean(&pd);
    }

    void reset() override {
        SoundpipeDSPBase::reset();
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

AK_API void akOperationEffectSetSporth(DSPRef dspRef, const char *sporth, int length) {
    auto dsp = dynamic_cast<OperationEffectDSP *>(dspRef);
    assert(dsp);
    dsp->setSporth(sporth, length);
}

AK_REGISTER_DSP(OperationEffectDSP)
AK_REGISTER_PARAMETER(OperationEffectParameter1)
AK_REGISTER_PARAMETER(OperationEffectParameter2)
AK_REGISTER_PARAMETER(OperationEffectParameter3)
AK_REGISTER_PARAMETER(OperationEffectParameter4)
AK_REGISTER_PARAMETER(OperationEffectParameter5)
AK_REGISTER_PARAMETER(OperationEffectParameter6)
AK_REGISTER_PARAMETER(OperationEffectParameter7)
AK_REGISTER_PARAMETER(OperationEffectParameter8)
AK_REGISTER_PARAMETER(OperationEffectParameter9)
AK_REGISTER_PARAMETER(OperationEffectParameter10)
AK_REGISTER_PARAMETER(OperationEffectParameter11)
AK_REGISTER_PARAMETER(OperationEffectParameter12)
AK_REGISTER_PARAMETER(OperationEffectParameter13)
AK_REGISTER_PARAMETER(OperationEffectParameter14)
