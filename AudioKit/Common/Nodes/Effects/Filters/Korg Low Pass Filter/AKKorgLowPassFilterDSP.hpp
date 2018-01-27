//
//  AKKorgLowPassFilterDSP.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKKorgLowPassFilterParameter) {
    AKKorgLowPassFilterParameterCutoffFrequency,
    AKKorgLowPassFilterParameterResonance,
    AKKorgLowPassFilterParameterSaturation,
    AKKorgLowPassFilterParameterRampTime
};

#import "AKLinearParameterRamp.hpp"  // have to put this here to get it included in umbrella header

#ifndef __cplusplus

void* createKorgLowPassFilterDSP(int nChannels, double sampleRate);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKKorgLowPassFilterDSP : public AKSoundpipeDSPBase {

    sp_wpkorg35 *_wpkorg350;
    sp_wpkorg35 *_wpkorg351;

private:
    AKLinearParameterRamp cutoffFrequencyRamp;
    AKLinearParameterRamp resonanceRamp;
    AKLinearParameterRamp saturationRamp;
   
public:
    AKKorgLowPassFilterDSP() {
        cutoffFrequencyRamp.setTarget(1000.0, true);
        cutoffFrequencyRamp.setDurationInSamples(10000);
        resonanceRamp.setTarget(1.0, true);
        resonanceRamp.setDurationInSamples(10000);
        saturationRamp.setTarget(0.0, true);
        saturationRamp.setDurationInSamples(10000);
    }

    /** Uses the ParameterAddress as a key */
    void setParameter(AUParameterAddress address, float value, bool immediate) override {
        switch (address) {
            case AKKorgLowPassFilterParameterCutoffFrequency:
                cutoffFrequencyRamp.setTarget(value, immediate);
                break;
            case AKKorgLowPassFilterParameterResonance:
                resonanceRamp.setTarget(value, immediate);
                break;
            case AKKorgLowPassFilterParameterSaturation:
                saturationRamp.setTarget(value, immediate);
                break;
            case AKKorgLowPassFilterParameterRampTime:
                cutoffFrequencyRamp.setRampTime(value, _sampleRate);
                resonanceRamp.setRampTime(value, _sampleRate);
                saturationRamp.setRampTime(value, _sampleRate);
                break;
        }
    }

    /** Uses the ParameterAddress as a key */
    float getParameter(AUParameterAddress address) override {
        switch (address) {
            case AKKorgLowPassFilterParameterCutoffFrequency:
                return cutoffFrequencyRamp.getTarget();
            case AKKorgLowPassFilterParameterResonance:
                return resonanceRamp.getTarget();
            case AKKorgLowPassFilterParameterSaturation:
                return saturationRamp.getTarget();
            case AKKorgLowPassFilterParameterRampTime:
                return cutoffFrequencyRamp.getRampTime(_sampleRate);
        }
        return 0;
    }

    void init(int _channels, double _sampleRate) override {
        AKSoundpipeDSPBase::init(_channels, _sampleRate);
        sp_wpkorg35_create(&_wpkorg350);
        sp_wpkorg35_create(&_wpkorg351);
        sp_wpkorg35_init(_sp, _wpkorg350);
        sp_wpkorg35_init(_sp, _wpkorg351);
        _wpkorg350->cutoff = 1000.0;
        _wpkorg351->cutoff = 1000.0;
        _wpkorg350->res = 1.0;
        _wpkorg351->res = 1.0;
        _wpkorg350->saturation = 0.0;
        _wpkorg351->saturation = 0.0;
    }

    void destroy() {
        sp_wpkorg35_destroy(&_wpkorg350);
        sp_wpkorg35_destroy(&_wpkorg351);
        AKSoundpipeDSPBase::destroy();
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            // do gain ramping every 8 samples
            if ((frameOffset & 0x7) == 0) {
                cutoffFrequencyRamp.advanceTo(_now + frameOffset);
                resonanceRamp.advanceTo(_now + frameOffset);
                saturationRamp.advanceTo(_now + frameOffset);
            }
            _wpkorg350->cutoff = cutoffFrequencyRamp.getValue() - 0.0001;
            _wpkorg351->cutoff = cutoffFrequencyRamp.getValue() - 0.0001;            
            _wpkorg350->res = resonanceRamp.getValue();
            _wpkorg351->res = resonanceRamp.getValue();            
            _wpkorg350->saturation = saturationRamp.getValue();
            _wpkorg351->saturation = saturationRamp.getValue();            

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
                    sp_wpkorg35_compute(_sp, _wpkorg350, in, out);
                } else {
                    sp_wpkorg35_compute(_sp, _wpkorg351, in, out);
                }
            }
            if (_playing) {
            }
        }
    }
};

#endif
