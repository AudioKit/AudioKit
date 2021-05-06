// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"
#include "soundpipe.h"

enum DynamicRangeCompressorParameter : AUParameterAddress {
    DynamicRangeCompressorParameterRatio,
    DynamicRangeCompressorParameterThreshold,
    DynamicRangeCompressorParameterAttackDuration,
    DynamicRangeCompressorParameterReleaseDuration,
};

class DynamicRangeCompressorDSP : public SoundpipeDSPBase {
private:
    sp_compressor *compressor0;
    sp_compressor *compressor1;
    ParameterRamper ratioRamp;
    ParameterRamper thresholdRamp;
    ParameterRamper attackDurationRamp;
    ParameterRamper releaseDurationRamp;

public:
    DynamicRangeCompressorDSP() {
        parameters[DynamicRangeCompressorParameterRatio] = &ratioRamp;
        parameters[DynamicRangeCompressorParameterThreshold] = &thresholdRamp;
        parameters[DynamicRangeCompressorParameterAttackDuration] = &attackDurationRamp;
        parameters[DynamicRangeCompressorParameterReleaseDuration] = &releaseDurationRamp;
    }

    void init(int channelCount, double sampleRate) override {
        SoundpipeDSPBase::init(channelCount, sampleRate);
        sp_compressor_create(&compressor0);
        sp_compressor_init(sp, compressor0);
        sp_compressor_create(&compressor1);
        sp_compressor_init(sp, compressor1);
    }

    void deinit() override {
        SoundpipeDSPBase::deinit();
        sp_compressor_destroy(&compressor0);
        sp_compressor_destroy(&compressor1);
    }

    void reset() override {
        SoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_compressor_init(sp, compressor0);
        sp_compressor_init(sp, compressor1);
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            float ratio = ratioRamp.getAndStep();
            *compressor0->ratio = ratio;
            *compressor1->ratio = ratio;

            float threshold = thresholdRamp.getAndStep();
            *compressor0->thresh = threshold;
            *compressor1->thresh = threshold;

            float attackDuration = attackDurationRamp.getAndStep();
            *compressor0->atk = attackDuration;
            *compressor1->atk = attackDuration;

            float releaseDuration = releaseDurationRamp.getAndStep();
            *compressor0->rel = releaseDuration;
            *compressor1->rel = releaseDuration;

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
                    sp_compressor_compute(sp, compressor0, in, out);
                } else {
                    sp_compressor_compute(sp, compressor1, in, out);
                }
            }
        }
    }
};

AK_REGISTER_DSP(DynamicRangeCompressorDSP, "cpsr")
AK_REGISTER_PARAMETER(DynamicRangeCompressorParameterRatio)
AK_REGISTER_PARAMETER(DynamicRangeCompressorParameterThreshold)
AK_REGISTER_PARAMETER(DynamicRangeCompressorParameterAttackDuration)
AK_REGISTER_PARAMETER(DynamicRangeCompressorParameterReleaseDuration)
