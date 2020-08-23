// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKSoundpipeDSPBase.hpp"
#include "ParameterRamper.hpp"
#include "soundpipe.h"
#include "plumber.h"

class AKOperationGeneratorDSP : public AKSoundpipeDSPBase {
private:
    plumber_data pd;
    char *sporthCode = nil;
    float params[14] = {0};
    int internalTriggers[14] = {0};

public:
    AKOperationGeneratorDSP() {
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

    float* getParameters() {
        return params;
    }

    void setParameters(float newParams[]) {
        for (int i = 0; i < 14; i++) {
            params[i] = newParams[i];
        }
    }

    void trigger(int trigger) {
        internalTriggers[trigger] = 1;
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

            for (int i = 0; i < 14; i++) {
                if (internalTriggers[i] == 1) {
                    pd.p[i] = 1.0;
                } else {
                    pd.p[i] = params[i];
                }
            }

            plumber_compute(&pd, PLUMBER_COMPUTE);

            for (int channel = 0; channel < channelCount; ++channel) {
                float *out = (float *)outputBufferList->mBuffers[channel].mData + frameOffset;
                *out = sporth_stack_pop_float(&pd.sporth.stack);
            }

            for (int i = 0; i < 14; i++) {
                if (internalTriggers[i] == 1) {
                    pd.p[i] = 0.0;
                }
                params[i] = pd.p[i];
                internalTriggers[i] = 0;
            }
        }
    }
};

AK_API void akOperationGeneratorSetSporth(AKDSPRef dspRef, const char *sporth, int length) {
    auto dsp = dynamic_cast<AKOperationGeneratorDSP *>(dspRef);
    assert(dsp);
    dsp->setSporth(sporth, length);
}

AK_API float* akOperationGeneratorGetParameters(AKDSPRef dspRef) {
    auto dsp = dynamic_cast<AKOperationGeneratorDSP *>(dspRef);
    assert(dsp);
    dsp->getParameters();
}

AK_API float* akOperationGeneratorSetParameters(AKDSPRef dspRef, float *params) {
    auto dsp = dynamic_cast<AKOperationGeneratorDSP *>(dspRef);
    assert(dsp);
    dsp->setParameters(params);
}

AK_API float* akOperationGeneratorTrigger(AKDSPRef dspRef, int trigger) {
    auto dsp = dynamic_cast<AKOperationGeneratorDSP *>(dspRef);
    assert(dsp);
    dsp->trigger(trigger);
}

AK_REGISTER_DSP(AKOperationGeneratorDSP)
