// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKDynamicRangeCompressorDSP.hpp"
#include "ParameterRamper.hpp"

extern "C" AKDSPRef createDynamicRangeCompressorDSP() {
    return new AKDynamicRangeCompressorDSP();
}

struct AKDynamicRangeCompressorDSP::InternalData {
    sp_compressor *compressor0;
    sp_compressor *compressor1;
    ParameterRamper ratioRamp;
    ParameterRamper thresholdRamp;
    ParameterRamper attackTimeRamp;
    ParameterRamper releaseTimeRamp;
};

AKDynamicRangeCompressorDSP::AKDynamicRangeCompressorDSP() : data(new InternalData) {
    parameters[AKDynamicRangeCompressorParameterRatio] = &data->ratioRamp;
    parameters[AKDynamicRangeCompressorParameterThreshold] = &data->thresholdRamp;
    parameters[AKDynamicRangeCompressorParameterAttackTime] = &data->attackTimeRamp;
    parameters[AKDynamicRangeCompressorParameterReleaseTime] = &data->releaseTimeRamp;
}

void AKDynamicRangeCompressorDSP::init(int channelCount, double sampleRate) {
    AKSoundpipeDSPBase::init(channelCount, sampleRate);
    sp_compressor_create(&data->compressor0);
    sp_compressor_init(sp, data->compressor0);
    sp_compressor_create(&data->compressor1);
    sp_compressor_init(sp, data->compressor1);
}

void AKDynamicRangeCompressorDSP::deinit() {
    AKSoundpipeDSPBase::deinit();
    sp_compressor_destroy(&data->compressor0);
    sp_compressor_destroy(&data->compressor1);
}

void AKDynamicRangeCompressorDSP::reset() {
    AKSoundpipeDSPBase::reset();
    if (!isInitialized) return;
    sp_compressor_init(sp, data->compressor0);
    sp_compressor_init(sp, data->compressor1);
}

void AKDynamicRangeCompressorDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        float ratio = data->ratioRamp.getAndStep();
        *data->compressor0->ratio = ratio;
        *data->compressor1->ratio = ratio;

        float threshold = data->thresholdRamp.getAndStep();
        *data->compressor0->thresh = threshold;
        *data->compressor1->thresh = threshold;

        float attackTime = data->attackTimeRamp.getAndStep();
        *data->compressor0->atk = attackTime;
        *data->compressor1->atk = attackTime;

        float releaseTime = data->releaseTimeRamp.getAndStep();
        *data->compressor0->rel = releaseTime;
        *data->compressor1->rel = releaseTime;

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
                sp_compressor_compute(sp, data->compressor0, in, out);
            } else {
                sp_compressor_compute(sp, data->compressor1, in, out);
            }
        }
    }
}
