//
//  AKEqualizerFilterDSP.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import <Foundation/Foundation.h>

typedef NS_ENUM(int64_t, AKEqualizerFilterParameter) {
    AKEqualizerFilterParameterCenterFrequency,
    AKEqualizerFilterParameterBandwidth,
    AKEqualizerFilterParameterGain,
    AKEqualizerFilterParameterRampTime
};

#import "AKLinearParameterRamp.hpp"  // have to put this here to get it included in umbrella header

#ifndef __cplusplus

void* createEqualizerFilterDSP(int nChannels, double sampleRate);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKEqualizerFilterDSP : public AKSoundpipeDSPBase {

    sp_eqfil *_eqfil0;
    sp_eqfil *_eqfil1;

private:
    AKLinearParameterRamp centerFrequencyRamp;
    AKLinearParameterRamp bandwidthRamp;
    AKLinearParameterRamp gainRamp;
   
public:
    AKEqualizerFilterDSP() {
        centerFrequencyRamp.setTarget(1000.0, true);
        centerFrequencyRamp.setDurationInSamples(10000);
        bandwidthRamp.setTarget(100.0, true);
        bandwidthRamp.setDurationInSamples(10000);
        gainRamp.setTarget(10.0, true);
        gainRamp.setDurationInSamples(10000);
    }

    /** Uses the ParameterAddress as a key */
    void setParameter(uint64_t address, float value, bool immediate) override {
        switch (address) {
            case AKEqualizerFilterParameterCenterFrequency:
                centerFrequencyRamp.setTarget(value, immediate);
                break;
            case AKEqualizerFilterParameterBandwidth:
                bandwidthRamp.setTarget(value, immediate);
                break;
            case AKEqualizerFilterParameterGain:
                gainRamp.setTarget(value, immediate);
                break;
            case AKEqualizerFilterParameterRampTime:
                centerFrequencyRamp.setRampTime(value, _sampleRate);
                bandwidthRamp.setRampTime(value, _sampleRate);
                gainRamp.setRampTime(value, _sampleRate);
                break;
        }
    }

    /** Uses the ParameterAddress as a key */
    float getParameter(uint64_t address) override {
        switch (address) {
            case AKEqualizerFilterParameterCenterFrequency:
                return centerFrequencyRamp.getTarget();
            case AKEqualizerFilterParameterBandwidth:
                return bandwidthRamp.getTarget();
            case AKEqualizerFilterParameterGain:
                return gainRamp.getTarget();
            case AKEqualizerFilterParameterRampTime:
                return centerFrequencyRamp.getRampTime(_sampleRate);
                return bandwidthRamp.getRampTime(_sampleRate);
                return gainRamp.getRampTime(_sampleRate);
        }
        return 0;
    }

    void init(int _channels, double _sampleRate) override {
        AKSoundpipeDSPBase::init(_channels, _sampleRate);
        sp_eqfil_create(&_eqfil0);
        sp_eqfil_create(&_eqfil1);
        sp_eqfil_init(_sp, _eqfil0);
        sp_eqfil_init(_sp, _eqfil1);
        _eqfil0->freq = 1000.0;
        _eqfil1->freq = 1000.0;
        _eqfil0->bw = 100.0;
        _eqfil1->bw = 100.0;
        _eqfil0->gain = 10.0;
        _eqfil1->gain = 10.0;
    }

    void destroy() {
        sp_eqfil_destroy(&_eqfil0);
        sp_eqfil_destroy(&_eqfil1);
        AKSoundpipeDSPBase::destroy();
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            // do gain ramping every 8 samples
            if ((frameOffset & 0x7) == 0) {
                centerFrequencyRamp.advanceTo(_now + frameOffset);
                bandwidthRamp.advanceTo(_now + frameOffset);
                gainRamp.advanceTo(_now + frameOffset);
            }
            _eqfil0->freq = centerFrequencyRamp.getValue();
            _eqfil1->freq = centerFrequencyRamp.getValue();            
            _eqfil0->bw = bandwidthRamp.getValue();
            _eqfil1->bw = bandwidthRamp.getValue();            
            _eqfil0->gain = gainRamp.getValue();
            _eqfil1->gain = gainRamp.getValue();            

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
                    sp_eqfil_compute(_sp, _eqfil0, in, out);
                } else {
                    sp_eqfil_compute(_sp, _eqfil1, in, out);
                }
            }
            if (_playing) {
            }
        }
    }
};

#endif
