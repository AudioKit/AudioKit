// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"
#include "Soundpipe.h"
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

    void process(FrameRange range) override {
        for (int i : range) {
            
            sp_conv_compute(sp, conv0, &inputSample(0, i), &outputSample(0, i));
            sp_conv_compute(sp, conv1, &inputSample(1, i), &outputSample(1, i));

            // Hack
            outputSample(0, i) *= 0.05;
            outputSample(1, i) *= 0.05;
        }
    }
};

AK_API void akConvolutionSetPartitionLength(DSPRef dsp, int length) {
    ((ConvolutionDSP*)dsp)->setPartitionLength(length);
}

AK_REGISTER_DSP(ConvolutionDSP, "conv")
