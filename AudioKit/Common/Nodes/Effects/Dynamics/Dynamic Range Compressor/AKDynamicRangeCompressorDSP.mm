// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKDynamicRangeCompressorDSP.hpp"
#include "AKLinearParameterRamp.hpp"

extern "C" AKDSPRef createDynamicRangeCompressorDSP() {
    return new AKDynamicRangeCompressorDSP();
}

struct AKDynamicRangeCompressorDSP::InternalData {
    sp_compressor *compressor0;
    sp_compressor *compressor1;
    AKLinearParameterRamp ratioRamp;
    AKLinearParameterRamp thresholdRamp;
    AKLinearParameterRamp attackTimeRamp;
    AKLinearParameterRamp releaseTimeRamp;
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

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            data->ratioRamp.advanceTo(now + frameOffset);
            data->thresholdRamp.advanceTo(now + frameOffset);
            data->attackTimeRamp.advanceTo(now + frameOffset);
            data->releaseTimeRamp.advanceTo(now + frameOffset);
        }

        *data->compressor0->ratio = data->ratioRamp.getValue();
        *data->compressor1->ratio = data->ratioRamp.getValue();
        *data->compressor0->thresh = data->thresholdRamp.getValue();
        *data->compressor1->thresh = data->thresholdRamp.getValue();
        *data->compressor0->atk = data->attackTimeRamp.getValue();
        *data->compressor1->atk = data->attackTimeRamp.getValue();
        *data->compressor0->rel = data->releaseTimeRamp.getValue();
        *data->compressor1->rel = data->releaseTimeRamp.getValue();

        float *tmpin[2];
        float *tmpout[2];
        for (int channel = 0; channel < channelCount; ++channel) {
            float *in  = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
            float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;
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
