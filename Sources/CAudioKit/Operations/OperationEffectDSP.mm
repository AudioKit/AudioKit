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
    ParameterCount
};

class OperationEffectDSP : public SoundpipeDSPBase {
private:
    plumber_data pd;
    char *sporthCode = nil;
    ParameterRamper rampers[ParameterCount];

public:
    OperationEffectDSP() : SoundpipeDSPBase(1, false) {
        for(int i=0;i<ParameterCount;++i) {
            parameters[i] = &rampers[i];
        }
    }

    ~OperationEffectDSP() { free(sporthCode); }

    void setSporth(const char *sporth) {
        free(sporthCode);
        sporthCode = strdup(sporth);
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

            for(int i=0;i<ParameterCount;++i) {
                pd.p[i] = rampers[i].getAndStep();
            }


            plumber_compute(&pd, PLUMBER_COMPUTE);

            for (int channel = 0; channel < channelCount; ++channel) {
                float *out = (float *)outputBufferList->mBuffers[channel].mData + frameOffset;
                *out = sporth_stack_pop_float(&pd.sporth.stack);
            }
        }
    }
};

AK_API void akOperationEffectSetSporth(DSPRef dspRef, const char *sporth) {
    auto dsp = dynamic_cast<OperationEffectDSP *>(dspRef);
    assert(dsp);
    dsp->setSporth(sporth);
}

AK_REGISTER_DSP(OperationEffectDSP, "cstm")
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
