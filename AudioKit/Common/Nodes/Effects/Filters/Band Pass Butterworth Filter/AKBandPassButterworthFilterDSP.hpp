//
//  AKBandPassButterworthFilterDSP.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import <Foundation/Foundation.h>

typedef NS_ENUM(int64_t, AKBandPassButterworthFilterParameter) {
    AKBandPassButterworthFilterParameterCenterFrequency,
    AKBandPassButterworthFilterParameterBandwidth,
    AKBandPassButterworthFilterParameterRampTime
};

#import "AKLinearParameterRamp.hpp"  // have to put this here to get it included in umbrella header

#ifndef __cplusplus

void* createBandPassButterworthFilterDSP(int nChannels, double sampleRate);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKBandPassButterworthFilterDSP : public AKSoundpipeDSPBase {

    sp_butbp *_butbp0;
    sp_butbp *_butbp1;

private:
    AKLinearParameterRamp centerFrequencyRamp;
    AKLinearParameterRamp bandwidthRamp;
   
public:
    AKBandPassButterworthFilterDSP() {
        centerFrequencyRamp.setTarget(2000.0, true);
        centerFrequencyRamp.setDurationInSamples(10000);
        bandwidthRamp.setTarget(100.0, true);
        bandwidthRamp.setDurationInSamples(10000);
    }

    /** Uses the ParameterAddress as a key */
    void setParameter(uint64_t address, float value, bool immediate) override {
        switch (address) {
            case AKBandPassButterworthFilterParameterCenterFrequency:
                centerFrequencyRamp.setTarget(value, immediate);
                break;
            case AKBandPassButterworthFilterParameterBandwidth:
                bandwidthRamp.setTarget(value, immediate);
                break;
            case AKBandPassButterworthFilterParameterRampTime:
                centerFrequencyRamp.setRampTime(value, _sampleRate);
                bandwidthRamp.setRampTime(value, _sampleRate);
                break;
        }
    }

    /** Uses the ParameterAddress as a key */
    float getParameter(uint64_t address) override {
        switch (address) {
            case AKBandPassButterworthFilterParameterCenterFrequency:
                return centerFrequencyRamp.getTarget();
            case AKBandPassButterworthFilterParameterBandwidth:
                return bandwidthRamp.getTarget();
            case AKBandPassButterworthFilterParameterRampTime:
                return centerFrequencyRamp.getRampTime(_sampleRate);
                return bandwidthRamp.getRampTime(_sampleRate);
        }
        return 0;
    }

    void init(int _channels, double _sampleRate) override {
        AKSoundpipeDSPBase::init(_channels, _sampleRate);
        sp_butbp_create(&_butbp0);
        sp_butbp_create(&_butbp1);
        sp_butbp_init(_sp, _butbp0);
        sp_butbp_init(_sp, _butbp1);
        _butbp0->freq = 2000.0;
        _butbp1->freq = 2000.0;
        _butbp0->bw = 100.0;
        _butbp1->bw = 100.0;
    }

    void destroy() {
        sp_butbp_destroy(&_butbp0);
        sp_butbp_destroy(&_butbp1);
        AKSoundpipeDSPBase::destroy();
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            // do gain ramping every 8 samples
            if ((frameOffset & 0x7) == 0) {
                centerFrequencyRamp.advanceTo(_now + frameOffset);
                bandwidthRamp.advanceTo(_now + frameOffset);
            }
            _butbp0->freq = centerFrequencyRamp.getValue();
            _butbp1->freq = centerFrequencyRamp.getValue();            
            _butbp0->bw = bandwidthRamp.getValue();
            _butbp1->bw = bandwidthRamp.getValue();            

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
                    sp_butbp_compute(_sp, _butbp0, in, out);
                } else {
                    sp_butbp_compute(_sp, _butbp1, in, out);
                }
            }
            if (_playing) {
            }
        }
    }
};

#endif
