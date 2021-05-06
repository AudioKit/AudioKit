// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"
#include "soundpipe.h"

enum ModalResonanceFilterParameter : AUParameterAddress {
    ModalResonanceFilterParameterFrequency,
    ModalResonanceFilterParameterQualityFactor,
};

class ModalResonanceFilterDSP : public SoundpipeDSPBase {
private:
    sp_mode *mode0;
    sp_mode *mode1;
    ParameterRamper frequencyRamp;
    ParameterRamper qualityFactorRamp;

public:
    ModalResonanceFilterDSP() {
        parameters[ModalResonanceFilterParameterFrequency] = &frequencyRamp;
        parameters[ModalResonanceFilterParameterQualityFactor] = &qualityFactorRamp;
    }

    void init(int channelCount, double sampleRate) override {
        SoundpipeDSPBase::init(channelCount, sampleRate);
        sp_mode_create(&mode0);
        sp_mode_init(sp, mode0);
        sp_mode_create(&mode1);
        sp_mode_init(sp, mode1);
    }

    void deinit() override {
        SoundpipeDSPBase::deinit();
        sp_mode_destroy(&mode0);
        sp_mode_destroy(&mode1);
    }

    void reset() override {
        SoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_mode_init(sp, mode0);
        sp_mode_init(sp, mode1);
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            float frequency = frequencyRamp.getAndStep();
            mode0->freq = frequency;
            mode1->freq = frequency;

            float qualityFactor = qualityFactorRamp.getAndStep();
            mode0->q = qualityFactor;
            mode1->q = qualityFactor;

            float *tmpin[2];
            float *tmpout[2];
            for (int channel = 0; channel < channelCount; ++channel) {
                float *in  = (float *)inputBufferLists[0]->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)outputBufferList->mBuffers[channel].mData + frameOffset;
                if (channel < 2) {
                    tmpin[channel] = in;
                    tmpout[channel] = out;
                }
                if (!isStarted) {
                    *out = *in;
                    continue;
                }

                if (channel == 0) {
                    sp_mode_compute(sp, mode0, in, out);
                } else {
                    sp_mode_compute(sp, mode1, in, out);
                }
            }
        }
    }
};

AK_REGISTER_DSP(ModalResonanceFilterDSP, "modf")
AK_REGISTER_PARAMETER(ModalResonanceFilterParameterFrequency)
AK_REGISTER_PARAMETER(ModalResonanceFilterParameterQualityFactor)
