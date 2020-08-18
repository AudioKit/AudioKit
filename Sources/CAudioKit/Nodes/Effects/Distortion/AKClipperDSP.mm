// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKSoundpipeDSPBase.hpp"
#include "ParameterRamper.hpp"
#include "soundpipe.h"

enum AKClipperParameter : AUParameterAddress {
    AKClipperParameterLimit,
};

class AKClipperDSP : public AKSoundpipeDSPBase {
private:
    sp_clip *clip0;
    sp_clip *clip1;
    ParameterRamper limitRamp;

public:
    AKClipperDSP() {
        parameters[AKClipperParameterLimit] = &limitRamp;
    }

    void init(int channelCount, double sampleRate) override {
        AKSoundpipeDSPBase::init(channelCount, sampleRate);
        sp_clip_create(&clip0);
        sp_clip_init(sp, clip0);
        sp_clip_create(&clip1);
        sp_clip_init(sp, clip1);
    }

    void deinit() override {
        AKSoundpipeDSPBase::deinit();
        sp_clip_destroy(&clip0);
        sp_clip_destroy(&clip1);
    }

    void reset() override {
        AKSoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_clip_init(sp, clip0);
        sp_clip_init(sp, clip1);
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            float limit = limitRamp.getAndStep();
            clip0->lim = limit;
            clip1->lim = limit;

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
                    sp_clip_compute(sp, clip0, in, out);
                } else {
                    sp_clip_compute(sp, clip1, in, out);
                }
            }
        }
    }
};

AK_REGISTER_DSP(AKClipperDSP)
AK_REGISTER_PARAMETER(AKClipperParameterLimit)
