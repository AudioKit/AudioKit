// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKPannerDSP.hpp"
#include "ParameterRamper.hpp"

extern "C" AKDSPRef createPannerDSP() {
    return new AKPannerDSP();
}

struct AKPannerDSP::InternalData {
    sp_panst *panst;
    ParameterRamper panRamp;
};

AKPannerDSP::AKPannerDSP() : data(new InternalData) {
    parameters[AKPannerParameterPan] = &data->panRamp;
}

void AKPannerDSP::init(int channelCount, double sampleRate) {
    AKSoundpipeDSPBase::init(channelCount, sampleRate);
    sp_panst_create(&data->panst);
    sp_panst_init(sp, data->panst);
}

void AKPannerDSP::deinit() {
    AKSoundpipeDSPBase::deinit();
    sp_panst_destroy(&data->panst);
}

void AKPannerDSP::reset() {
    AKSoundpipeDSPBase::reset();
    if (!isInitialized) return;
    sp_panst_init(sp, data->panst);
}

void AKPannerDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        data->panst->pan = data->panRamp.getAndStep();

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
            
        }
        if (isStarted) {
            sp_panst_compute(sp, data->panst, tmpin[0], tmpin[1], tmpout[0], tmpout[1]);
        }
    }
}
