// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKBitCrusherDSP.hpp"
#include "AKLinearParameterRamp.hpp"

extern "C" AKDSPRef createBitCrusherDSP() {
    return new AKBitCrusherDSP();
}

struct AKBitCrusherDSP::InternalData {
    sp_bitcrush *bitcrush0;
    sp_bitcrush *bitcrush1;
    AKLinearParameterRamp bitDepthRamp;
    AKLinearParameterRamp sampleRateRamp;
};

AKBitCrusherDSP::AKBitCrusherDSP() : data(new InternalData) {
    parameters[AKBitCrusherParameterBitDepth] = &data->bitDepthRamp;
    parameters[AKBitCrusherParameterSampleRate] = &data->sampleRateRamp;
}

void AKBitCrusherDSP::init(int channelCount, double sampleRate) {
    AKSoundpipeDSPBase::init(channelCount, sampleRate);
    sp_bitcrush_create(&data->bitcrush0);
    sp_bitcrush_init(sp, data->bitcrush0);
    sp_bitcrush_create(&data->bitcrush1);
    sp_bitcrush_init(sp, data->bitcrush1);
}

void AKBitCrusherDSP::deinit() {
    AKSoundpipeDSPBase::deinit();
    sp_bitcrush_destroy(&data->bitcrush0);
    sp_bitcrush_destroy(&data->bitcrush1);
}

void AKBitCrusherDSP::reset() {
    AKSoundpipeDSPBase::reset();
    if (!isInitialized) return;
    sp_bitcrush_init(sp, data->bitcrush0);
    sp_bitcrush_init(sp, data->bitcrush1);
}

void AKBitCrusherDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            data->bitDepthRamp.advanceTo(now + frameOffset);
            data->sampleRateRamp.advanceTo(now + frameOffset);
        }

        data->bitcrush0->bitdepth = data->bitDepthRamp.getValue();
        data->bitcrush1->bitdepth = data->bitDepthRamp.getValue();
        data->bitcrush0->srate = data->sampleRateRamp.getValue();
        data->bitcrush1->srate = data->sampleRateRamp.getValue();

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
                sp_bitcrush_compute(sp, data->bitcrush0, in, out);
            } else {
                sp_bitcrush_compute(sp, data->bitcrush1, in, out);
            }
        }
    }
}
