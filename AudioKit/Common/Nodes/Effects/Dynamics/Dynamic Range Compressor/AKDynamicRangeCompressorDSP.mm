// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKDynamicRangeCompressorDSP.hpp"
#include "ParameterRamper.hpp"

#import "AKSoundpipeDSPBase.hpp"

class AKDynamicRangeCompressorDSP : public AKSoundpipeDSPBase {
private:
    sp_compressor *compressor0;
    sp_compressor *compressor1;
    ParameterRamper ratioRamp;
    ParameterRamper thresholdRamp;
    ParameterRamper attackDurationRamp;
    ParameterRamper releaseDurationRamp;

public:
    AKDynamicRangeCompressorDSP() {
        parameters[AKDynamicRangeCompressorParameterRatio] = &ratioRamp;
        parameters[AKDynamicRangeCompressorParameterThreshold] = &thresholdRamp;
        parameters[AKDynamicRangeCompressorParameterAttackDuration] = &attackDurationRamp;
        parameters[AKDynamicRangeCompressorParameterReleaseDuration] = &releaseDurationRamp;
    }

    void init(int channelCount, double sampleRate) {
        AKSoundpipeDSPBase::init(channelCount, sampleRate);
        sp_compressor_create(&compressor0);
        sp_compressor_init(sp, compressor0);
        sp_compressor_create(&compressor1);
        sp_compressor_init(sp, compressor1);
    }

    void deinit() {
        AKSoundpipeDSPBase::deinit();
        sp_compressor_destroy(&compressor0);
        sp_compressor_destroy(&compressor1);
    }

    void reset() {
        AKSoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_compressor_init(sp, compressor0);
        sp_compressor_init(sp, compressor1);
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

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
                    sp_compressor_compute(sp, compressor0, in, out);
                } else {
                    sp_compressor_compute(sp, compressor1, in, out);
                }
            }
        }
    }
};

extern "C" AKDSPRef createDynamicRangeCompressorDSP() {
    return new AKDynamicRangeCompressorDSP();
}
