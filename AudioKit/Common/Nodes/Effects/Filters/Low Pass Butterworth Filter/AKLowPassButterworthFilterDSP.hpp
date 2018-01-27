//
//  AKLowPassButterworthFilterDSP.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKLowPassButterworthFilterParameter) {
    AKLowPassButterworthFilterParameterCutoffFrequency,
    AKLowPassButterworthFilterParameterRampTime
};

#import "AKLinearParameterRamp.hpp"  // have to put this here to get it included in umbrella header

#ifndef __cplusplus

void* createLowPassButterworthFilterDSP(int nChannels, double sampleRate);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKLowPassButterworthFilterDSP : public AKSoundpipeDSPBase {

    sp_butlp *_butlp0;
    sp_butlp *_butlp1;

private:
    AKLinearParameterRamp cutoffFrequencyRamp;
   
public:
    AKLowPassButterworthFilterDSP() {
        cutoffFrequencyRamp.setTarget(1000.0, true);
        cutoffFrequencyRamp.setDurationInSamples(10000);
    }

    /** Uses the ParameterAddress as a key */
    void setParameter(AUParameterAddress address, float value, bool immediate) override {
        switch (address) {
            case AKLowPassButterworthFilterParameterCutoffFrequency:
                cutoffFrequencyRamp.setTarget(value, immediate);
                break;
            case AKLowPassButterworthFilterParameterRampTime:
                cutoffFrequencyRamp.setRampTime(value, _sampleRate);
                break;
        }
    }

    /** Uses the ParameterAddress as a key */
    float getParameter(AUParameterAddress address) override {
        switch (address) {
            case AKLowPassButterworthFilterParameterCutoffFrequency:
                return cutoffFrequencyRamp.getTarget();
            case AKLowPassButterworthFilterParameterRampTime:
                return cutoffFrequencyRamp.getRampTime(_sampleRate);
        }
        return 0;
    }

    void init(int _channels, double _sampleRate) override {
        AKSoundpipeDSPBase::init(_channels, _sampleRate);
        sp_butlp_create(&_butlp0);
        sp_butlp_create(&_butlp1);
        sp_butlp_init(_sp, _butlp0);
        sp_butlp_init(_sp, _butlp1);
        _butlp0->freq = 1000.0;
        _butlp1->freq = 1000.0;
    }

    void destroy() {
        sp_butlp_destroy(&_butlp0);
        sp_butlp_destroy(&_butlp1);
        AKSoundpipeDSPBase::destroy();
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            // do gain ramping every 8 samples
            if ((frameOffset & 0x7) == 0) {
                cutoffFrequencyRamp.advanceTo(_now + frameOffset);
            }
            _butlp0->freq = cutoffFrequencyRamp.getValue();
            _butlp1->freq = cutoffFrequencyRamp.getValue();            

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
                    sp_butlp_compute(_sp, _butlp0, in, out);
                } else {
                    sp_butlp_compute(_sp, _butlp1, in, out);
                }
            }
            if (_playing) {
            }
        }
    }
};

#endif
