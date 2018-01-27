//
//  AKClipperDSP.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKClipperParameter) {
    AKClipperParameterLimit,
    AKClipperParameterRampTime
};

#import "AKLinearParameterRamp.hpp"  // have to put this here to get it included in umbrella header

#ifndef __cplusplus

void* createClipperDSP(int nChannels, double sampleRate);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKClipperDSP : public AKSoundpipeDSPBase {

    sp_clip *_clip0;
    sp_clip *_clip1;

private:
    AKLinearParameterRamp limitRamp;
   
public:
    AKClipperDSP() {
        limitRamp.setTarget(1.0, true);
        limitRamp.setDurationInSamples(10000);
    }

    /** Uses the ParameterAddress as a key */
    void setParameter(AUParameterAddress address, float value, bool immediate) override {
        switch (address) {
            case AKClipperParameterLimit:
                limitRamp.setTarget(value, immediate);
                break;
            case AKClipperParameterRampTime:
                limitRamp.setRampTime(value, _sampleRate);
                break;
        }
    }

    /** Uses the ParameterAddress as a key */
    float getParameter(AUParameterAddress address) override {
        switch (address) {
            case AKClipperParameterLimit:
                return limitRamp.getTarget();
            case AKClipperParameterRampTime:
                return limitRamp.getRampTime(_sampleRate);
        }
        return 0;
    }

    void init(int _channels, double _sampleRate) override {
        AKSoundpipeDSPBase::init(_channels, _sampleRate);
        sp_clip_create(&_clip0);
        sp_clip_create(&_clip1);
        sp_clip_init(_sp, _clip0);
        sp_clip_init(_sp, _clip1);
        _clip0->lim = 1.0;
        _clip1->lim = 1.0;
    }

    void destroy() {
        sp_clip_destroy(&_clip0);
        sp_clip_destroy(&_clip1);
        AKSoundpipeDSPBase::destroy();
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            // do gain ramping every 8 samples
            if ((frameOffset & 0x7) == 0) {
                limitRamp.advanceTo(_now + frameOffset);
            }
            _clip0->lim = limitRamp.getValue();
            _clip1->lim = limitRamp.getValue();            

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
                    sp_clip_compute(_sp, _clip0, in, out);
                } else {
                    sp_clip_compute(_sp, _clip1, in, out);
                }
            }
            if (_playing) {
            }
        }
    }
};

#endif
