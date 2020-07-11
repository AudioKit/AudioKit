// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKFormantFilterDSP.hpp"
#include "ParameterRamper.hpp"

#import "AKSoundpipeDSPBase.hpp"

class AKFormantFilterDSP : public AKSoundpipeDSPBase {
private:
    sp_fofilt *fofilt0;
    sp_fofilt *fofilt1;
    ParameterRamper centerFrequencyRamp;
    ParameterRamper attackDurationRamp;
    ParameterRamper decayDurationRamp;

public:
    AKFormantFilterDSP() {
        parameters[AKFormantFilterParameterCenterFrequency] = &centerFrequencyRamp;
        parameters[AKFormantFilterParameterAttackDuration] = &attackDurationRamp;
        parameters[AKFormantFilterParameterDecayDuration] = &decayDurationRamp;
    }

    void init(int channelCount, double sampleRate) {
        AKSoundpipeDSPBase::init(channelCount, sampleRate);
        sp_fofilt_create(&fofilt0);
        sp_fofilt_init(sp, fofilt0);
        sp_fofilt_create(&fofilt1);
        sp_fofilt_init(sp, fofilt1);
    }

    void deinit() {
        AKSoundpipeDSPBase::deinit();
        sp_fofilt_destroy(&fofilt0);
        sp_fofilt_destroy(&fofilt1);
    }

    void reset() {
        AKSoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_fofilt_init(sp, fofilt0);
        sp_fofilt_init(sp, fofilt1);
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

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
                float *out = (float *)outputBufferLists[0]->mBuffers[channel].mData + frameOffset;
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

extern "C" AKDSPRef createFormantFilterDSP() {
    return new AKFormantFilterDSP();
}