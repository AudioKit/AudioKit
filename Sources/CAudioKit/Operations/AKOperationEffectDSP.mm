// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKSoundpipeDSPBase.hpp"
#include "ParameterRamper.hpp"
#include "soundpipe.h"
#include "plumber.h"

enum AKOperationEffectParameter : AUParameterAddress {
    AKOperationEffectParameter1,
    AKOperationEffectParameter2,
};

class AKOperationEffectDSP : public AKSoundpipeDSPBase {
private:
    plumber_data pd;
    char *sporthCode = nil;
    float params[14] = {0};
    ParameterRamper parameter1Ramp;
    ParameterRamper parameter2Ramp;
    ParameterRamper parameter3Ramp;
    ParameterRamper parameter4Ramp;

public:
    AKOperationEffectDSP() {
        parameters[AKOperationEffectParameter1] = &parameter1Ramp;
        parameters[AKOperationEffectParameter2] = &parameter2Ramp;
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

            for (int i = 0; i < 14; i++) {
                pd.p[i] = params[i];
            }
            pd.p[0] = parameter1Ramp.get();
            pd.p[1] = parameter2Ramp.get();

            plumber_compute(&pd, PLUMBER_COMPUTE);

            for (int channel = 0; channel < channelCount; ++channel) {
                float *out = (float *)outputBufferList->mBuffers[channel].mData + frameOffset;
                *out = sporth_stack_pop_float(&pd.sporth.stack);
            }

            for (int i = 0; i < 14; i++) {
                params[i] = pd.p[i];
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
