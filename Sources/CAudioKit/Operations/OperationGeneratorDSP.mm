// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"
#include "soundpipe.h"
#include "plumber.h"

enum OperationGeneratorParameter : AUParameterAddress {
    OperationGeneratorParameter1,
    OperationGeneratorParameter2,
    OperationGeneratorParameter3,
    OperationGeneratorParameter4,
    OperationGeneratorParameter5,
    OperationGeneratorParameter6,
    OperationGeneratorParameter7,
    OperationGeneratorParameter8,
    OperationGeneratorParameter9,
    OperationGeneratorParameter10,
    OperationGeneratorParameter11,
    OperationGeneratorParameter12,
    OperationGeneratorParameter13,
    OperationGeneratorParameter14,
};

class OperationGeneratorDSP : public SoundpipeDSPBase {
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
    OperationGeneratorDSP() : SoundpipeDSPBase(/*inputBusCount*/0) {
        parameters[OperationGeneratorParameter1] = &parameter1Ramp;
        parameters[OperationGeneratorParameter2] = &parameter2Ramp;
        parameters[OperationGeneratorParameter3] = &parameter3Ramp;
        parameters[OperationGeneratorParameter4] = &parameter4Ramp;
        parameters[OperationGeneratorParameter5] = &parameter5Ramp;
        parameters[OperationGeneratorParameter6] = &parameter6Ramp;
        parameters[OperationGeneratorParameter7] = &parameter7Ramp;
        parameters[OperationGeneratorParameter8] = &parameter8Ramp;
        parameters[OperationGeneratorParameter9] = &parameter9Ramp;
        parameters[OperationGeneratorParameter10] = &parameter10Ramp;
        parameters[OperationGeneratorParameter11] = &parameter11Ramp;
        parameters[OperationGeneratorParameter12] = &parameter12Ramp;
        parameters[OperationGeneratorParameter13] = &parameter13Ramp;
        parameters[OperationGeneratorParameter14] = &parameter14Ramp;
        isStarted = false;
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

            if (internalTrigger == 1) {
                pd.p[15] = 1.0;
            }

            if (isStarted)
                plumber_compute(&pd, PLUMBER_COMPUTE);

            for (int channel = 0; channel < channelCount; ++channel) {
                float *out = (float *)outputBufferList->mBuffers[channel].mData + frameOffset;
                if (isStarted) {
                    *out = sporth_stack_pop_float(&pd.sporth.stack);
                } else {
                    *out = 0;
                }
            }

            internalTrigger = 0;
        }
    }
};

AK_API void akOperationGeneratorSetSporth(DSPRef dspRef, const char *sporth, int length) {
    auto dsp = dynamic_cast<OperationGeneratorDSP *>(dspRef);
    assert(dsp);
    dsp->setSporth(sporth, length);
}

AK_API float* akOperationGeneratorTrigger(DSPRef dspRef) {
    auto dsp = dynamic_cast<OperationGeneratorDSP *>(dspRef);
    assert(dsp);
    dsp->trigger();
}

AK_REGISTER_DSP(OperationGeneratorDSP)
AK_REGISTER_PARAMETER(OperationGeneratorParameter1)
AK_REGISTER_PARAMETER(OperationGeneratorParameter2)
AK_REGISTER_PARAMETER(OperationGeneratorParameter3)
AK_REGISTER_PARAMETER(OperationGeneratorParameter4)
AK_REGISTER_PARAMETER(OperationGeneratorParameter5)
AK_REGISTER_PARAMETER(OperationGeneratorParameter6)
AK_REGISTER_PARAMETER(OperationGeneratorParameter7)
AK_REGISTER_PARAMETER(OperationGeneratorParameter8)
AK_REGISTER_PARAMETER(OperationGeneratorParameter9)
AK_REGISTER_PARAMETER(OperationGeneratorParameter10)
AK_REGISTER_PARAMETER(OperationGeneratorParameter11)
AK_REGISTER_PARAMETER(OperationGeneratorParameter12)
AK_REGISTER_PARAMETER(OperationGeneratorParameter13)
AK_REGISTER_PARAMETER(OperationGeneratorParameter14)
