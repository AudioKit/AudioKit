// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKSoundpipeDSPBase.hpp"
#include "ParameterRamper.hpp"
#include "soundpipe.h"

enum AKBitCrusherParameter : AUParameterAddress {
    AKBitCrusherParameterBitDepth,
    AKBitCrusherParameterSampleRate,
};

class AKBitCrusherDSP : public AKSoundpipeDSPBase {
private:
    sp_bitcrush *bitcrush0;
    sp_bitcrush *bitcrush1;
    ParameterRamper bitDepthRamp;
    ParameterRamper sampleRateRamp;

public:
    AKBitCrusherDSP() {
        parameters[AKBitCrusherParameterBitDepth] = &bitDepthRamp;
        parameters[AKBitCrusherParameterSampleRate] = &sampleRateRamp;
    }

    void init(int channelCount, double sampleRate) override {
        AKSoundpipeDSPBase::init(channelCount, sampleRate);
        sp_bitcrush_create(&bitcrush0);
        sp_bitcrush_init(sp, bitcrush0);
        sp_bitcrush_create(&bitcrush1);
        sp_bitcrush_init(sp, bitcrush1);
    }

    void deinit() override {
        AKSoundpipeDSPBase::deinit();
        sp_bitcrush_destroy(&bitcrush0);
        sp_bitcrush_destroy(&bitcrush1);
    }

    void reset() override {
        AKSoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_bitcrush_init(sp, bitcrush0);
        sp_bitcrush_init(sp, bitcrush1);
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            float bitDepth = bitDepthRamp.getAndStep();
            bitcrush0->bitdepth = bitDepth;
            bitcrush1->bitdepth = bitDepth;

            float sampleRate = sampleRateRamp.getAndStep();
            bitcrush0->srate = sampleRate;
            bitcrush1->srate = sampleRate;

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
                    sp_bitcrush_compute(sp, bitcrush0, in, out);
                } else {
                    sp_bitcrush_compute(sp, bitcrush1, in, out);
                }
            }
        }
    }
};

AK_REGISTER_DSP(AKBitCrusherDSP)
AK_REGISTER_PARAMETER(AKBitCrusherParameterBitDepth)
AK_REGISTER_PARAMETER(AKBitCrusherParameterSampleRate)
