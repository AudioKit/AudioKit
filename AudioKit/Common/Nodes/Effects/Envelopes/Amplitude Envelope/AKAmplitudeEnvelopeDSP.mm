// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKAmplitudeEnvelopeDSP.hpp"
#include "ParameterRamper.hpp"

#import "AKSoundpipeDSPBase.hpp"

class AKAmplitudeEnvelopeDSP : public AKSoundpipeDSPBase {
private:
    sp_adsr *adsr;
    float internalGate = 0;
    float amp = 0;
    ParameterRamper attackDurationRamp;
    ParameterRamper decayDurationRamp;
    ParameterRamper sustainLevelRamp;
    ParameterRamper releaseDurationRamp;

public:
    AKAmplitudeEnvelopeDSP() {
        parameters[AKAmplitudeEnvelopeParameterAttackDuration] = &attackDurationRamp;
        parameters[AKAmplitudeEnvelopeParameterDecayDuration] = &decayDurationRamp;
        parameters[AKAmplitudeEnvelopeParameterSustainLevel] = &sustainLevelRamp;
        parameters[AKAmplitudeEnvelopeParameterReleaseDuration] = &releaseDurationRamp;
    }

    void init(int channelCount, double sampleRate) {
        AKSoundpipeDSPBase::init(channelCount, sampleRate);
        sp_adsr_create(&adsr);
        sp_adsr_init(sp, adsr);
    }

    void deinit() {
        AKSoundpipeDSPBase::deinit();
        sp_adsr_destroy(&adsr);
    }

    void reset() {
        AKSoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_adsr_init(sp, adsr);
    }

    void start() {
        AKSoundpipeDSPBase::start();
        internalGate = 1;
    }

    void stop() {
        AKSoundpipeDSPBase::stop();
        internalGate = 0;
    }


    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            adsr->atk = attackDurationRamp.getAndStep();
            adsr->dec = decayDurationRamp.getAndStep();
            adsr->sus = sustainLevelRamp.getAndStep();
            adsr->rel = releaseDurationRamp.getAndStep();

            sp_adsr_compute(sp, adsr, &internalGate, &amp);

            for (int channel = 0; channel < channelCount; ++channel) {
                float *in  = (float *)inputBufferLists[0]->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)outputBufferLists[0]->mBuffers[channel].mData + frameOffset;
                *out = *in * amp;
            }
        }
    }
};

extern "C" AKDSPRef createAmplitudeEnvelopeDSP() {
    return new AKAmplitudeEnvelopeDSP();
}
