//
//  AKDCBlockDSP.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import <Foundation/Foundation.h>

#import "AKLinearParameterRamp.hpp"  // have to put this here to get it included in umbrella header

#ifndef __cplusplus

void* createDCBlockDSP(int nChannels, double sampleRate);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKDCBlockDSP : public AKSoundpipeDSPBase {

    sp_dcblock *_dcblock0;
    sp_dcblock *_dcblock1;
public:
    AKDCBlockDSP() {}

    void init(int _channels, double _sampleRate) override {
        AKSoundpipeDSPBase::init(_channels, _sampleRate);
        sp_dcblock_create(&_dcblock0);
        sp_dcblock_create(&_dcblock1);
        sp_dcblock_init(_sp, _dcblock0);
        sp_dcblock_init(_sp, _dcblock1);
    }

    void destroy() {
        sp_dcblock_destroy(&_dcblock0);
        sp_dcblock_destroy(&_dcblock1);
        AKSoundpipeDSPBase::destroy();
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            float *tmpin[2];
            float *tmpout[2];
            for (int channel = 0; channel < _nChannels; ++channel) {
                float* in  = (float*)_inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                float* out = (float*)_outBufferListPtr->mBuffers[channel].mData + frameOffset;

                if (channel < 2) {
                    tmpin[channel] = in;
                    tmpout[channel] = out;
                }
                if (!_playing) {
                    *out = *in;
                }
                if (channel == 0) {
                    sp_dcblock_compute(_sp, _dcblock0, in, out);
                } else {
                    sp_dcblock_compute(_sp, _dcblock1, in, out);
                }
            }
            if (_playing) {
            }
        }
    }
};

#endif
