// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"
#include "soundpipe.h"

enum ToneFilterParameter : AUParameterAddress {
    ToneFilterParameterHalfPowerPoint,
};

class ToneFilterDSP : public SoundpipeDSPBase {
private:
    sp_tone *tone0;
    sp_tone *tone1;
    ParameterRamper halfPowerPointRamp;

public:
    ToneFilterDSP() {
        parameters[ToneFilterParameterHalfPowerPoint] = &halfPowerPointRamp;
    }

    void init(int channelCount, double sampleRate) override {
        SoundpipeDSPBase::init(channelCount, sampleRate);
        sp_tone_create(&tone0);
        sp_tone_init(sp, tone0);
        sp_tone_create(&tone1);
        sp_tone_init(sp, tone1);
    }

    void deinit() override {
        SoundpipeDSPBase::deinit();
        sp_tone_destroy(&tone0);
        sp_tone_destroy(&tone1);
    }

    void reset() override {
        SoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_tone_init(sp, tone0);
        sp_tone_init(sp, tone1);
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            float halfPowerPoint = halfPowerPointRamp.getAndStep();
            tone0->hp = halfPowerPoint;
            tone1->hp = halfPowerPoint;

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
                    sp_tone_compute(sp, tone0, in, out);
                } else {
                    sp_tone_compute(sp, tone1, in, out);
                }
            }
        }
    }
};

AK_REGISTER_DSP(ToneFilterDSP, "tone")
AK_REGISTER_PARAMETER(ToneFilterParameterHalfPowerPoint)
