// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKSoundpipeDSPBase.hpp"
#include "ParameterRamper.hpp"
#include "soundpipe.h"

enum AKAutoWahParameter : AUParameterAddress {
    AKAutoWahParameterWah,
    AKAutoWahParameterMix,
    AKAutoWahParameterAmplitude,
};

class AKAutoWahDSP : public AKSoundpipeDSPBase {
private:
    sp_autowah *autowah0;
    sp_autowah *autowah1;
    ParameterRamper wahRamp;
    ParameterRamper mixRamp;
    ParameterRamper amplitudeRamp;

public:
    AKAutoWahDSP() {
        parameters[AKAutoWahParameterWah] = &wahRamp;
        parameters[AKAutoWahParameterMix] = &mixRamp;
        parameters[AKAutoWahParameterAmplitude] = &amplitudeRamp;
    }

    void init(int channelCount, double sampleRate) override {
        AKSoundpipeDSPBase::init(channelCount, sampleRate);
        sp_autowah_create(&autowah0);
        sp_autowah_init(sp, autowah0);
        sp_autowah_create(&autowah1);
        sp_autowah_init(sp, autowah1);
    }

    void deinit() override {
        AKSoundpipeDSPBase::deinit();
        sp_autowah_destroy(&autowah0);
        sp_autowah_destroy(&autowah1);
    }

    void reset() override {
        AKSoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_autowah_init(sp, autowah0);
        sp_autowah_init(sp, autowah1);
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            float wah = wahRamp.getAndStep();
            *autowah0->wah = wah;
            *autowah1->wah = wah;

            float mix = mixRamp.getAndStep() * 100.f;
            *autowah0->mix = mix;
            *autowah1->mix = mix;

            float amplitude = amplitudeRamp.getAndStep();
            *autowah0->level = amplitude;
            *autowah1->level = amplitude;

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
                    sp_autowah_compute(sp, autowah0, in, out);
                } else {
                    sp_autowah_compute(sp, autowah1, in, out);
                }
            }
        }
    }
};

AK_REGISTER_DSP(AKAutoWahDSP)
AK_REGISTER_PARAMETER(AKAutoWahParameterWah)
AK_REGISTER_PARAMETER(AKAutoWahParameterMix)
AK_REGISTER_PARAMETER(AKAutoWahParameterAmplitude)
