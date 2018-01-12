//
//  AKBandRejectButterworthFilterDSP.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import <Foundation/Foundation.h>

typedef NS_ENUM(int64_t, AKBandRejectButterworthFilterParameter) {
    AKBandRejectButterworthFilterParameterCenterFrequency,
    AKBandRejectButterworthFilterParameterBandwidth,
    AKBandRejectButterworthFilterParameterRampTime
};

#import "AKLinearParameterRamp.hpp"  // have to put this here to get it included in umbrella header

#ifndef __cplusplus

void* createBandRejectButterworthFilterDSP(int nChannels, double sampleRate);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKBandRejectButterworthFilterDSP : public AKSoundpipeDSPBase {

    sp_butbr *_butbr0;
    sp_butbr *_butbr1;
    sp_revsc* _revsc;


private:
    AKLinearParameterRamp centerFrequencyRamp;
    AKLinearParameterRamp bandwidthRamp;
   
public:
    AKBandRejectButterworthFilterDSP() {
        centerFrequencyRamp.setTarget(3000.0, true);
        centerFrequencyRamp.setDurationInSamples(10000);
        bandwidthRamp.setTarget(2000.0, true);
        bandwidthRamp.setDurationInSamples(10000);
    }

    /** Uses the ParameterAddress as a key */
    void setParameter(uint64_t address, float value, bool immediate) override {
        switch (address) {
            case AKBandRejectButterworthFilterParameterCenterFrequency:
                centerFrequencyRamp.setTarget(value, immediate);
                break;
            case AKBandRejectButterworthFilterParameterBandwidth:
                bandwidthRamp.setTarget(value, immediate);
                break;
            case AKBandRejectButterworthFilterParameterRampTime:
                centerFrequencyRamp.setRampTime(value, _sampleRate);
                bandwidthRamp.setRampTime(value, _sampleRate);
                break;
        }
    }

    /** Uses the ParameterAddress as a key */
    float getParameter(uint64_t address) override {
        switch (address) {
            case AKBandRejectButterworthFilterParameterCenterFrequency:
                return centerFrequencyRamp.getTarget();
            case AKBandRejectButterworthFilterParameterBandwidth:
                return bandwidthRamp.getTarget();
            case AKBandRejectButterworthFilterParameterRampTime:
                return centerFrequencyRamp.getRampTime(_sampleRate);
                return bandwidthRamp.getRampTime(_sampleRate);
        }
        return 0;
    }

    void init(int _channels, double _sampleRate) override {
        AKSoundpipeDSPBase::init(_channels, _sampleRate);
        sp_butbr_create(&_butbr0);
        sp_butbr_create(&_butbr1);
        sp_butbr_init(_sp, _butbr0);
        sp_butbr_init(_sp, _butbr1);
        _butbr0->freq = 3000.0;
        _butbr1->freq = 3000.0;
        _butbr0->bw = 2000.0;
        _butbr1->bw = 2000.0;
    }

    void destroy() {
        sp_butbr_destroy(&_butbr0);
        sp_butbr_destroy(&_butbr1);
        AKSoundpipeDSPBase::destroy();
    }

    void process(uint32_t frameCount, uint32_t bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            // do gain ramping every 8 samples
            if ((frameOffset & 0x7) == 0) {
                centerFrequencyRamp.advanceTo(_now + frameOffset);
                bandwidthRamp.advanceTo(_now + frameOffset);
            }
            _butbr0->freq = centerFrequencyRamp.getValue();
            _butbr1->freq = centerFrequencyRamp.getValue();            
            _butbr0->bw = bandwidthRamp.getValue();
            _butbr1->bw = bandwidthRamp.getValue();            

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
                    sp_butbr_compute(_sp, _butbr0, in, out);
                } else {
                    sp_butbr_compute(_sp, _butbr1, in, out);
                }
            }
            if (_playing) {
            }
        }
    }
};

#endif
