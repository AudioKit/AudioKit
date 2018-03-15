//
//  AKHighPassButterworthFilterDSP.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import <Foundation/Foundation.h>

typedef NS_ENUM(int64_t, AKHighPassButterworthFilterParameter) {
    AKHighPassButterworthFilterParameterCutoffFrequency,
    AKHighPassButterworthFilterParameterRampTime
};

#import "AKLinearParameterRamp.hpp"  // have to put this here to get it included in umbrella header

#ifndef __cplusplus

void* createHighPassButterworthFilterDSP(int nChannels, double sampleRate);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKHighPassButterworthFilterDSP : public AKSoundpipeDSPBase {

    sp_buthp *_buthp0;
    sp_buthp *_buthp1;

private:
    AKLinearParameterRamp cutoffFrequencyRamp;
   
public:
    AKHighPassButterworthFilterDSP() {
        cutoffFrequencyRamp.setTarget(500.0, true);
        cutoffFrequencyRamp.setDurationInSamples(10000);
    }

    /** Uses the ParameterAddress as a key */
    void setParameter(AUParameterAddress address, float value, bool immediate) override {
        switch (address) {
            case AKHighPassButterworthFilterParameterCutoffFrequency:
                cutoffFrequencyRamp.setTarget(value, immediate);
                break;
            case AKHighPassButterworthFilterParameterRampTime:
                cutoffFrequencyRamp.setRampTime(value, _sampleRate);
                break;
        }
    }

    /** Uses the ParameterAddress as a key */
    float getParameter(AUParameterAddress address) override {
        switch (address) {
            case AKHighPassButterworthFilterParameterCutoffFrequency:
                return cutoffFrequencyRamp.getTarget();
            case AKHighPassButterworthFilterParameterRampTime:
                return cutoffFrequencyRamp.getRampTime(_sampleRate);
        }
        return 0;
    }

    void init(int _channels, double _sampleRate) override {
        AKSoundpipeDSPBase::init(_channels, _sampleRate);
        sp_buthp_create(&_buthp0);
        sp_buthp_create(&_buthp1);
        sp_buthp_init(_sp, _buthp0);
        sp_buthp_init(_sp, _buthp1);
        _buthp0->freq = 500.0;
        _buthp1->freq = 500.0;
    }

    void destroy() {
        sp_buthp_destroy(&_buthp0);
        sp_buthp_destroy(&_buthp1);
        AKSoundpipeDSPBase::destroy();
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            // do gain ramping every 8 samples
            if ((frameOffset & 0x7) == 0) {
                cutoffFrequencyRamp.advanceTo(_now + frameOffset);
            }
            _buthp0->freq = cutoffFrequencyRamp.getValue();
            _buthp1->freq = cutoffFrequencyRamp.getValue();            

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
                    sp_buthp_compute(_sp, _buthp0, in, out);
                } else {
                    sp_buthp_compute(_sp, _buthp1, in, out);
                }
            }
            if (_playing) {
            }
        }
    }
};

#endif
