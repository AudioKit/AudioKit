// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKDCBlockDSP.hpp"

#import "AKSoundpipeDSPBase.hpp"

class AKDCBlockDSP : public AKSoundpipeDSPBase {
private:
    sp_dcblock *dcblock0;
    sp_dcblock *dcblock1;

public:
    AKDCBlockDSP() {
    }

    void init(int channelCount, double sampleRate) {
        AKSoundpipeDSPBase::init(channelCount, sampleRate);
        sp_dcblock_create(&dcblock0);
        sp_dcblock_init(sp, dcblock0);
        sp_dcblock_create(&dcblock1);
        sp_dcblock_init(sp, dcblock1);
    }

    void deinit() {
        AKSoundpipeDSPBase::deinit();
        sp_dcblock_destroy(&dcblock0);
        sp_dcblock_destroy(&dcblock1);
    }

    void reset() {
        AKSoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_dcblock_init(sp, dcblock0);
        sp_dcblock_init(sp, dcblock1);
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

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
                    sp_dcblock_compute(sp, dcblock0, in, out);
                } else {
                    sp_dcblock_compute(sp, dcblock1, in, out);
                }
            }
        }
    }
};

extern "C" AKDSPRef createDCBlockDSP() {
    return new AKDCBlockDSP();
}