// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"
#include "soundpipe.h"
#include <vector>

enum ConvolutionParameter : AUParameterAddress {
};

class ConvolutionDSP : public SoundpipeDSPBase {
private:
    sp_conv *conv0;
    sp_conv *conv1;
    sp_ftbl *ftbl;
    std::vector<float> wavetable;
    int partitionLength = 2048;

public:
    ConvolutionDSP() {}

    void setWavetable(const float *table, size_t length, int index) override {
        wavetable = std::vector<float>(table, table + length);
        if (!isInitialized) return;
        sp_ftbl_destroy(&ftbl);
        sp_ftbl_create(sp, &ftbl, wavetable.size());
        std::copy(wavetable.cbegin(), wavetable.cend(), ftbl->tbl);
        reset();
    }

    void init(int channelCount, double sampleRate) override {
        SoundpipeDSPBase::init(channelCount, sampleRate);
        sp_ftbl_create(sp, &ftbl, wavetable.size());
        std::copy(wavetable.cbegin(), wavetable.cend(), ftbl->tbl);
        sp_conv_create(&conv0);
        sp_conv_init(sp, conv0, ftbl, (float)partitionLength);
        sp_conv_create(&conv1);
        sp_conv_init(sp, conv1, ftbl, (float)partitionLength);
    }

    void setPartitionLength(int partLength) {
        partitionLength = partLength;
        reset();
    }

    void deinit() override {
        SoundpipeDSPBase::deinit();
        sp_conv_destroy(&conv0);
        sp_conv_destroy(&conv1);
    }

    void reset() override {
        SoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_conv_init(sp, conv0, ftbl, (float)partitionLength);
        sp_conv_init(sp, conv1, ftbl, (float)partitionLength);
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

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
                    sp_conv_compute(sp, conv0, in, out);
                } else {
                    sp_conv_compute(sp, conv1, in, out);
                }
                *out = *out * 0.05; // Hack
            }
        }
    }
};

AK_API void akConvolutionSetPartitionLength(DSPRef dsp, int length) {
    ((ConvolutionDSP*)dsp)->setPartitionLength(length);
}

AK_REGISTER_DSP(ConvolutionDSP, "conv")
