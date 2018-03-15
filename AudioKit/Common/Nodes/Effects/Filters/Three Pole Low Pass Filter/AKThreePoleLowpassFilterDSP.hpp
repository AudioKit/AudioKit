//
//  AKThreePoleLowpassFilterDSP.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import <Foundation/Foundation.h>

typedef NS_ENUM(int64_t, AKThreePoleLowpassFilterParameter) {
    AKThreePoleLowpassFilterParameterDistortion,
    AKThreePoleLowpassFilterParameterCutoffFrequency,
    AKThreePoleLowpassFilterParameterResonance,
    AKThreePoleLowpassFilterParameterRampTime
};

#import "AKLinearParameterRamp.hpp"  // have to put this here to get it included in umbrella header

#ifndef __cplusplus

void* createThreePoleLowpassFilterDSP(int nChannels, double sampleRate);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKThreePoleLowpassFilterDSP : public AKSoundpipeDSPBase {

    sp_lpf18 *_lpf180;
    sp_lpf18 *_lpf181;

private:
    AKLinearParameterRamp distortionRamp;
    AKLinearParameterRamp cutoffFrequencyRamp;
    AKLinearParameterRamp resonanceRamp;
   
public:
    AKThreePoleLowpassFilterDSP() {
        distortionRamp.setTarget(0.5, true);
        distortionRamp.setDurationInSamples(10000);
        cutoffFrequencyRamp.setTarget(1500, true);
        cutoffFrequencyRamp.setDurationInSamples(10000);
        resonanceRamp.setTarget(0.5, true);
        resonanceRamp.setDurationInSamples(10000);
    }

    /** Uses the ParameterAddress as a key */
    void setParameter(AUParameterAddress address, float value, bool immediate) override {
        switch (address) {
            case AKThreePoleLowpassFilterParameterDistortion:
                distortionRamp.setTarget(value, immediate);
                break;
            case AKThreePoleLowpassFilterParameterCutoffFrequency:
                cutoffFrequencyRamp.setTarget(value, immediate);
                break;
            case AKThreePoleLowpassFilterParameterResonance:
                resonanceRamp.setTarget(value, immediate);
                break;
            case AKThreePoleLowpassFilterParameterRampTime:
                distortionRamp.setRampTime(value, _sampleRate);
                cutoffFrequencyRamp.setRampTime(value, _sampleRate);
                resonanceRamp.setRampTime(value, _sampleRate);
                break;
        }
    }

    /** Uses the ParameterAddress as a key */
    float getParameter(AUParameterAddress address) override {
        switch (address) {
            case AKThreePoleLowpassFilterParameterDistortion:
                return distortionRamp.getTarget();
            case AKThreePoleLowpassFilterParameterCutoffFrequency:
                return cutoffFrequencyRamp.getTarget();
            case AKThreePoleLowpassFilterParameterResonance:
                return resonanceRamp.getTarget();
            case AKThreePoleLowpassFilterParameterRampTime:
                return distortionRamp.getRampTime(_sampleRate);
        }
        return 0;
    }

    void init(int _channels, double _sampleRate) override {
        AKSoundpipeDSPBase::init(_channels, _sampleRate);
        sp_lpf18_create(&_lpf180);
        sp_lpf18_create(&_lpf181);
        sp_lpf18_init(_sp, _lpf180);
        sp_lpf18_init(_sp, _lpf181);
        _lpf180->dist = 0.5;
        _lpf181->dist = 0.5;
        _lpf180->cutoff = 1500;
        _lpf181->cutoff = 1500;
        _lpf180->res = 0.5;
        _lpf181->res = 0.5;
    }

    void destroy() {
        sp_lpf18_destroy(&_lpf180);
        sp_lpf18_destroy(&_lpf181);
        AKSoundpipeDSPBase::destroy();
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            // do gain ramping every 8 samples
            if ((frameOffset & 0x7) == 0) {
                distortionRamp.advanceTo(_now + frameOffset);
                cutoffFrequencyRamp.advanceTo(_now + frameOffset);
                resonanceRamp.advanceTo(_now + frameOffset);
            }
            _lpf180->dist = distortionRamp.getValue();
            _lpf181->dist = distortionRamp.getValue();            
            _lpf180->cutoff = cutoffFrequencyRamp.getValue();
            _lpf181->cutoff = cutoffFrequencyRamp.getValue();            
            _lpf180->res = resonanceRamp.getValue();
            _lpf181->res = resonanceRamp.getValue();            

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
                    sp_lpf18_compute(_sp, _lpf180, in, out);
                } else {
                    sp_lpf18_compute(_sp, _lpf181, in, out);
                }
            }
            if (_playing) {
            }
        }
    }
};

#endif
