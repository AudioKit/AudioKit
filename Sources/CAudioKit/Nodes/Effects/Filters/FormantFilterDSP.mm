// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"
#include "soundpipe.h"

enum FormantFilterParameter : AUParameterAddress {
    FormantFilterParameterCenterFrequency,
    FormantFilterParameterAttackDuration,
    FormantFilterParameterDecayDuration,
};

class FormantFilterDSP : public SoundpipeDSPBase {
private:
    sp_fofilt *fofilt0;
    sp_fofilt *fofilt1;
    ParameterRamper centerFrequencyRamp;
    ParameterRamper attackDurationRamp;
    ParameterRamper decayDurationRamp;

public:
    FormantFilterDSP() {
        parameters[FormantFilterParameterCenterFrequency] = &centerFrequencyRamp;
        parameters[FormantFilterParameterAttackDuration] = &attackDurationRamp;
        parameters[FormantFilterParameterDecayDuration] = &decayDurationRamp;
    }

    void init(int channelCount, double sampleRate) override {
        SoundpipeDSPBase::init(channelCount, sampleRate);
        sp_fofilt_create(&fofilt0);
        sp_fofilt_init(sp, fofilt0);
        sp_fofilt_create(&fofilt1);
        sp_fofilt_init(sp, fofilt1);
    }

    void deinit() override {
        SoundpipeDSPBase::deinit();
        sp_fofilt_destroy(&fofilt0);
        sp_fofilt_destroy(&fofilt1);
    }

    void reset() override {
        SoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_fofilt_init(sp, fofilt0);
        sp_fofilt_init(sp, fofilt1);
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            float centerFrequency = centerFrequencyRamp.getAndStep();
            fofilt0->freq = centerFrequency;
            fofilt1->freq = centerFrequency;

            float attackDuration = attackDurationRamp.getAndStep();
            fofilt0->atk = attackDuration;
            fofilt1->atk = attackDuration;

            float decayDuration = decayDurationRamp.getAndStep();
            fofilt0->dec = decayDuration;
            fofilt1->dec = decayDuration;

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
                    sp_fofilt_compute(sp, fofilt0, in, out);
                } else {
                    sp_fofilt_compute(sp, fofilt1, in, out);
                }
            }
        }
    }
};

AK_REGISTER_DSP(FormantFilterDSP, "fofi")
AK_REGISTER_PARAMETER(FormantFilterParameterCenterFrequency)
AK_REGISTER_PARAMETER(FormantFilterParameterAttackDuration)
AK_REGISTER_PARAMETER(FormantFilterParameterDecayDuration)
