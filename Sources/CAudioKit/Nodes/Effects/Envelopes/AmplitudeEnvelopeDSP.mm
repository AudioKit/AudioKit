// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"
#include "soundpipe.h"

enum AmplitudeEnvelopeParameter : AUParameterAddress {
    AmplitudeEnvelopeParameterAttackDuration,
    AmplitudeEnvelopeParameterDecayDuration,
    AmplitudeEnvelopeParameterSustainLevel,
    AmplitudeEnvelopeParameterReleaseDuration,
};

class AmplitudeEnvelopeDSP : public SoundpipeDSPBase {
private:
    sp_adsr *adsr;
    float amp = 0;
    ParameterRamper attackDurationRamp;
    ParameterRamper decayDurationRamp;
    ParameterRamper sustainLevelRamp;
    ParameterRamper releaseDurationRamp;

public:
    AmplitudeEnvelopeDSP() {
        parameters[AmplitudeEnvelopeParameterAttackDuration] = &attackDurationRamp;
        parameters[AmplitudeEnvelopeParameterDecayDuration] = &decayDurationRamp;
        parameters[AmplitudeEnvelopeParameterSustainLevel] = &sustainLevelRamp;
        parameters[AmplitudeEnvelopeParameterReleaseDuration] = &releaseDurationRamp;
    }

    void init(int channelCount, double sampleRate) override {
        SoundpipeDSPBase::init(channelCount, sampleRate);
        sp_adsr_create(&adsr);
        sp_adsr_init(sp, adsr);
    }

    void deinit() override {
        SoundpipeDSPBase::deinit();
        sp_adsr_destroy(&adsr);
    }

    void reset() override {
        SoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_adsr_init(sp, adsr);
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        float internalGate = isStarted ? 1 : 0;

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            adsr->atk = attackDurationRamp.getAndStep();
            adsr->dec = decayDurationRamp.getAndStep();
            adsr->sus = sustainLevelRamp.getAndStep();
            adsr->rel = releaseDurationRamp.getAndStep();

            sp_adsr_compute(sp, adsr, &internalGate, &amp);

            for (int channel = 0; channel < channelCount; ++channel) {
                float *in  = (float *)inputBufferLists[0]->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)outputBufferList->mBuffers[channel].mData + frameOffset;
                *out = *in * amp;
            }
        }
    }
};

AK_REGISTER_DSP(AmplitudeEnvelopeDSP, "adsr")
AK_REGISTER_PARAMETER(AmplitudeEnvelopeParameterAttackDuration)
AK_REGISTER_PARAMETER(AmplitudeEnvelopeParameterDecayDuration)
AK_REGISTER_PARAMETER(AmplitudeEnvelopeParameterSustainLevel)
AK_REGISTER_PARAMETER(AmplitudeEnvelopeParameterReleaseDuration)
