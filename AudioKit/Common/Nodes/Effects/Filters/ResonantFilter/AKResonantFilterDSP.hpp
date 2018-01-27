//
//  AKResonantFilterDSP.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKResonantFilterParameter) {
    AKResonantFilterParameterFrequency,
    AKResonantFilterParameterBandwidth,
    AKResonantFilterParameterRampTime
};

#import "AKLinearParameterRamp.hpp"  // have to put this here to get it included in umbrella header

#ifndef __cplusplus

void* createResonantFilterDSP(int nChannels, double sampleRate);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKResonantFilterDSP : public AKSoundpipeDSPBase {

    sp_reson *_reson0;
    sp_reson *_reson1;

private:
    AKLinearParameterRamp frequencyRamp;
    AKLinearParameterRamp bandwidthRamp;
   
public:
    AKResonantFilterDSP() {
        frequencyRamp.setTarget(4000.0, true);
        frequencyRamp.setDurationInSamples(10000);
        bandwidthRamp.setTarget(1000.0, true);
        bandwidthRamp.setDurationInSamples(10000);
    }

    /** Uses the ParameterAddress as a key */
    void setParameter(AUParameterAddress address, float value, bool immediate) override {
        switch (address) {
            case AKResonantFilterParameterFrequency:
                frequencyRamp.setTarget(value, immediate);
                break;
            case AKResonantFilterParameterBandwidth:
                bandwidthRamp.setTarget(value, immediate);
                break;
            case AKResonantFilterParameterRampTime:
                frequencyRamp.setRampTime(value, _sampleRate);
                bandwidthRamp.setRampTime(value, _sampleRate);
                break;
        }
    }

    /** Uses the ParameterAddress as a key */
    float getParameter(AUParameterAddress address) override {
        switch (address) {
            case AKResonantFilterParameterFrequency:
                return frequencyRamp.getTarget();
            case AKResonantFilterParameterBandwidth:
                return bandwidthRamp.getTarget();
            case AKResonantFilterParameterRampTime:
                return frequencyRamp.getRampTime(_sampleRate);
        }
        return 0;
    }

    void init(int _channels, double _sampleRate) override {
        AKSoundpipeDSPBase::init(_channels, _sampleRate);
        sp_reson_create(&_reson0);
        sp_reson_create(&_reson1);
        sp_reson_init(_sp, _reson0);
        sp_reson_init(_sp, _reson1);
        _reson0->freq = 4000.0;
        _reson1->freq = 4000.0;
        _reson0->bw = 1000.0;
        _reson1->bw = 1000.0;
    }

    void destroy() {
        sp_reson_destroy(&_reson0);
        sp_reson_destroy(&_reson1);
        AKSoundpipeDSPBase::destroy();
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            // do gain ramping every 8 samples
            if ((frameOffset & 0x7) == 0) {
                frequencyRamp.advanceTo(_now + frameOffset);
                bandwidthRamp.advanceTo(_now + frameOffset);
            }
            _reson0->freq = frequencyRamp.getValue();
            _reson1->freq = frequencyRamp.getValue();            
            _reson0->bw = bandwidthRamp.getValue();
            _reson1->bw = bandwidthRamp.getValue();            

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
                    sp_reson_compute(_sp, _reson0, in, out);
                } else {
                    sp_reson_compute(_sp, _reson1, in, out);
                }
            }
            if (_playing) {
            }
        }
    }
};

#endif
