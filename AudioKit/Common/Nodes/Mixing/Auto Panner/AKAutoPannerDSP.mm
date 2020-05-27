// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#import "AKAutoPannerDSP.hpp"
#import "ParameterRamper.hpp"
#import <vector>

extern "C" AKDSPRef createAutoPannerDSP() {
    AKAutoPannerDSP *dsp = new AKAutoPannerDSP();
    return dsp;
}

struct AKAutoPannerDSP::InternalData {
    sp_osc *trem;
    sp_ftbl *tbl;
    sp_panst *panst;
    std::vector<float> wavetable;
    ParameterRamper frequencyRamp;
    ParameterRamper depthRamp;
};

AKAutoPannerDSP::AKAutoPannerDSP() : data(new InternalData) {
    parameters[AKAutoPannerParameterFrequency] = &data->frequencyRamp;
    parameters[AKAutoPannerParameterDepth] = &data->depthRamp;
    
    bCanProcessInPlace = true;
}

void AKAutoPannerDSP::setWavetable(const float* table, size_t length, int index) {
    data->wavetable = std::vector<float>(table, table + length);
}

void AKAutoPannerDSP::init(int channelCount, double sampleRate) {
    AKSoundpipeDSPBase::init(channelCount, sampleRate);
    sp_ftbl_create(sp, &data->tbl, data->wavetable.size());
    std::copy(data->wavetable.cbegin(), data->wavetable.cend(), data->tbl->tbl);
    sp_osc_create(&data->trem);
    sp_osc_init(sp, data->trem, data->tbl, 0);
    sp_panst_create(&data->panst);
    sp_panst_init(sp, data->panst);
}

void AKAutoPannerDSP::deinit() {
    AKSoundpipeDSPBase::deinit();
    sp_osc_destroy(&data->trem);
    sp_panst_destroy(&data->panst);
    sp_ftbl_destroy(&data->tbl);
}

void AKAutoPannerDSP::process(uint32_t frameCount, uint32_t bufferOffset) {
    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        data->trem->freq = data->frequencyRamp.getAndStep();
        data->trem->amp = 1;

        float temp = 0;
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
            }
        }
        if (isStarted) {
            sp_osc_compute(sp, data->trem, NULL, &temp);
            data->panst->pan = (2.0 * temp - 1.0) * data->depthRamp.getAndStep();
            sp_panst_compute(sp, data->panst, tmpin[0], tmpin[1], tmpout[0], tmpout[1]);
        }
    }
}
