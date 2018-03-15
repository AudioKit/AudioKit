//
//  AKFlatFrequencyResponseReverbDSP.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import <Foundation/Foundation.h>

typedef NS_ENUM(int64_t, AKFlatFrequencyResponseReverbParameter) {
    AKFlatFrequencyResponseReverbParameterReverbDuration,
    AKFlatFrequencyResponseReverbParameterRampTime
};

#import "AKLinearParameterRamp.hpp"  // have to put this here to get it included in umbrella header

#ifndef __cplusplus

void* createFlatFrequencyResponseReverbDSP(int nChannels, double sampleRate);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKFlatFrequencyResponseReverbDSP : public AKSoundpipeDSPBase {

    sp_allpass *_allpass0;
    sp_allpass *_allpass1;

private:
    AKLinearParameterRamp reverbDurationRamp;
    float _loopDuration = 0.1;

public:
    AKFlatFrequencyResponseReverbDSP() {
        reverbDurationRamp.setTarget(0.5, true);
        reverbDurationRamp.setDurationInSamples(10000);
    }

    void initializeConstant(float duration) override {
        _loopDuration = duration;
    }

    /** Uses the ParameterAddress as a key */
    void setParameter(AUParameterAddress address, float value, bool immediate) override {
        switch (address) {
            case AKFlatFrequencyResponseReverbParameterReverbDuration:
                reverbDurationRamp.setTarget(value, immediate);
                break;
            case AKFlatFrequencyResponseReverbParameterRampTime:
                reverbDurationRamp.setRampTime(value, _sampleRate);
                break;
        }
    }

    /** Uses the ParameterAddress as a key */
    float getParameter(AUParameterAddress address) override {
        switch (address) {
            case AKFlatFrequencyResponseReverbParameterReverbDuration:
                return reverbDurationRamp.getTarget();
            case AKFlatFrequencyResponseReverbParameterRampTime:
                return reverbDurationRamp.getRampTime(_sampleRate);
        }
        return 0;
    }

    void init(int _channels, double _sampleRate) override {
        AKSoundpipeDSPBase::init(_channels, _sampleRate);
        sp_allpass_create(&_allpass0);
        sp_allpass_create(&_allpass1);
        sp_allpass_init(_sp, _allpass0, _loopDuration);
        sp_allpass_init(_sp, _allpass1, _loopDuration);
        _allpass0->revtime = 0.5;
        _allpass1->revtime = 0.5;
    }

    void destroy() {
        sp_allpass_destroy(&_allpass0);
        sp_allpass_destroy(&_allpass1);
        AKSoundpipeDSPBase::destroy();
    }

    void process(uint32_t frameCount, uint32_t bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            // do gain ramping every 8 samples
            if ((frameOffset & 0x7) == 0) {
                reverbDurationRamp.advanceTo(_now + frameOffset);
            }
            _allpass0->revtime = reverbDurationRamp.getValue();
            _allpass1->revtime = reverbDurationRamp.getValue();            

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
                    sp_allpass_compute(_sp, _allpass0, in, out);
                } else {
                    sp_allpass_compute(_sp, _allpass1, in, out);
                }
            }
            if (_playing) {
            }
        }
    }
};

#endif
