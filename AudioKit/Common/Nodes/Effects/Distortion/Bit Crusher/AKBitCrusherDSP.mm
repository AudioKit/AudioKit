// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKBitCrusherDSP.hpp"
#include "ParameterRamper.hpp"

extern "C" AKDSPRef createBitCrusherDSP() {
    return new AKBitCrusherDSP();
}

struct AKBitCrusherDSP::InternalData {
    sp_bitcrush *bitcrush0;
    sp_bitcrush *bitcrush1;
    ParameterRamper bitDepthRamp;
    ParameterRamper sampleRateRamp;
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

        float bitDepth = data->bitDepthRamp.getAndStep();
        data->bitcrush0->bitdepth = bitDepth;
        data->bitcrush1->bitdepth = bitDepth;

        float sampleRate = data->sampleRateRamp.getAndStep();
        data->bitcrush0->srate = sampleRate;
        data->bitcrush1->srate = sampleRate;

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
                sp_bitcrush_compute(sp, data->bitcrush0, in, out);
            } else {
                sp_bitcrush_compute(sp, data->bitcrush1, in, out);
            }
        }
    }
}
