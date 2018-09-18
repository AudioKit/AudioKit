//
//  AKCombFilterReverbDSP.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKCombFilterReverbParameter) {
    AKCombFilterReverbParameterReverbDuration,
    AKCombFilterReverbParameterRampDuration
};

#import "AKLinearParameterRamp.hpp"  // have to put this here to get it included in umbrella header

#ifndef __cplusplus

void *createCombFilterReverbDSP(int nChannels, double sampleRate);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKCombFilterReverbDSP : public AKSoundpipeDSPBase {

    sp_comb *_comb0;
    sp_comb *_comb1;

private:
    AKLinearParameterRamp reverbDurationRamp;
    float _loopDuration = 0.1;

public:
    AKCombFilterReverbDSP() {
        reverbDurationRamp.setTarget(1.0, true);
        reverbDurationRamp.setDurationInSamples(10000);
    }

    void initializeConstant(float duration) override {
        _loopDuration = duration;
    }

    /** Uses the ParameterAddress as a key */
    void setParameter(AUParameterAddress address, float value, bool immediate) override {
        switch (address) {
            case AKCombFilterReverbParameterReverbDuration:
                reverbDurationRamp.setTarget(value, immediate);
                break;
            case AKCombFilterReverbParameterRampDuration:
                reverbDurationRamp.setRampDuration(value, _sampleRate);
                break;
        }
    }

    /** Uses the ParameterAddress as a key */
    float getParameter(AUParameterAddress address) override {
        switch (address) {
            case AKCombFilterReverbParameterReverbDuration:
                return reverbDurationRamp.getTarget();
            case AKCombFilterReverbParameterRampDuration:
                return reverbDurationRamp.getRampDuration(_sampleRate);
        }
        return 0;
    }

    void init(int _channels, double _sampleRate) override {
        AKSoundpipeDSPBase::init(_channels, _sampleRate);
        sp_comb_create(&_comb0);
        sp_comb_create(&_comb1);
        sp_comb_init(_sp, _comb0, _loopDuration);
        sp_comb_init(_sp, _comb1, _loopDuration);
        _comb0->revtime = 1.0;
        _comb1->revtime = 1.0;
    }

    void deinit() override {
        sp_comb_destroy(&_comb0);
        sp_comb_destroy(&_comb1);
    }

    void process(uint32_t frameCount, uint32_t bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            // do ramping every 8 samples
            if ((frameOffset & 0x7) == 0) {
                reverbDurationRamp.advanceTo(_now + frameOffset);
            }
            _comb0->revtime = reverbDurationRamp.getValue();
            _comb1->revtime = reverbDurationRamp.getValue();            

            float *tmpin[2];
            float *tmpout[2];
            for (int channel = 0; channel < _nChannels; ++channel) {
                float *in  = (float *)_inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)_outBufferListPtr->mBuffers[channel].mData + frameOffset;

                if (channel < 2) {
                    tmpin[channel] = in;
                    tmpout[channel] = out;
                }
                if (!_playing) {
                    *out = *in;
                    continue;
                }
                if (channel == 0) {
                    sp_comb_compute(_sp, _comb0, in, out);
                } else {
                    sp_comb_compute(_sp, _comb1, in, out);
                }
            }
            if (_playing) {
            }
        }
    }
};

#endif
