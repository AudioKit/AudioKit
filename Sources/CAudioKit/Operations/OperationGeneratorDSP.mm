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
    OperationGeneratorTrigger
};

class OperationGeneratorDSP : public SoundpipeDSPBase {
private:
    plumber_data pd;
    char *sporthCode = nil;
    ParameterRamper rampers[OperationGeneratorTrigger];
    int internalTrigger = 0;

public:
    OperationGeneratorDSP() : SoundpipeDSPBase(/*inputBusCount*/0) {
        for(int i=0;i<OperationGeneratorTrigger;++i) {
            parameters[i] = &rampers[i];
        }
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

            for(int i=0;i<OperationGeneratorTrigger;++i) {
                pd.p[i] = rampers[i].getAndStep();
            }

            if (internalTrigger == 1) {
                pd.p[OperationGeneratorTrigger] = 1.0;
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
            pd.p[OperationGeneratorTrigger] = 0.0;
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

AK_REGISTER_DSP(OperationGeneratorDSP, "cstg")
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
