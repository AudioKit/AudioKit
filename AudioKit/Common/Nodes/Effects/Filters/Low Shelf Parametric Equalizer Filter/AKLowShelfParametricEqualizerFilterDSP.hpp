//
//  AKLowShelfParametricEqualizerFilterDSP.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKLowShelfParametricEqualizerFilterParameter) {
    AKLowShelfParametricEqualizerFilterParameterCornerFrequency,
    AKLowShelfParametricEqualizerFilterParameterGain,
    AKLowShelfParametricEqualizerFilterParameterQ,
    AKLowShelfParametricEqualizerFilterParameterRampTime
};

#import "AKLinearParameterRamp.hpp"  // have to put this here to get it included in umbrella header

#ifndef __cplusplus

void* createLowShelfParametricEqualizerFilterDSP(int nChannels, double sampleRate);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKLowShelfParametricEqualizerFilterDSP : public AKSoundpipeDSPBase {

    sp_pareq *_pareq0;
    sp_pareq *_pareq1;

private:
    AKLinearParameterRamp cornerFrequencyRamp;
    AKLinearParameterRamp gainRamp;
    AKLinearParameterRamp qRamp;
   
public:
    AKLowShelfParametricEqualizerFilterDSP() {
        cornerFrequencyRamp.setTarget(1000, true);
        cornerFrequencyRamp.setDurationInSamples(10000);
        gainRamp.setTarget(1.0, true);
        gainRamp.setDurationInSamples(10000);
        qRamp.setTarget(0.707, true);
        qRamp.setDurationInSamples(10000);
    }

    /** Uses the ParameterAddress as a key */
    void setParameter(AUParameterAddress address, float value, bool immediate) override {
        switch (address) {
            case AKLowShelfParametricEqualizerFilterParameterCornerFrequency:
                cornerFrequencyRamp.setTarget(value, immediate);
                break;
            case AKLowShelfParametricEqualizerFilterParameterGain:
                gainRamp.setTarget(value, immediate);
                break;
            case AKLowShelfParametricEqualizerFilterParameterQ:
                qRamp.setTarget(value, immediate);
                break;
            case AKLowShelfParametricEqualizerFilterParameterRampTime:
                cornerFrequencyRamp.setRampTime(value, _sampleRate);
                gainRamp.setRampTime(value, _sampleRate);
                qRamp.setRampTime(value, _sampleRate);
                break;
        }
    }

    /** Uses the ParameterAddress as a key */
    float getParameter(AUParameterAddress address) override {
        switch (address) {
            case AKLowShelfParametricEqualizerFilterParameterCornerFrequency:
                return cornerFrequencyRamp.getTarget();
            case AKLowShelfParametricEqualizerFilterParameterGain:
                return gainRamp.getTarget();
            case AKLowShelfParametricEqualizerFilterParameterQ:
                return qRamp.getTarget();
            case AKLowShelfParametricEqualizerFilterParameterRampTime:
                return cornerFrequencyRamp.getRampTime(_sampleRate);
        }
        return 0;
    }

    void init(int _channels, double _sampleRate) override {
        AKSoundpipeDSPBase::init(_channels, _sampleRate);
        sp_pareq_create(&_pareq0);
        sp_pareq_create(&_pareq1);
        sp_pareq_init(_sp, _pareq0);
        sp_pareq_init(_sp, _pareq1);
        _pareq0->fc = 1000;
        _pareq1->fc = 1000;
        _pareq0->v = 1.0;
        _pareq1->v = 1.0;
        _pareq0->q = 0.707;
        _pareq1->q = 0.707;
        _pareq0->mode = 1;
        _pareq1->mode = 1;
    }

    void destroy() {
        sp_pareq_destroy(&_pareq0);
        sp_pareq_destroy(&_pareq1);
        AKSoundpipeDSPBase::destroy();
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            // do gain ramping every 8 samples
            if ((frameOffset & 0x7) == 0) {
                cornerFrequencyRamp.advanceTo(_now + frameOffset);
                gainRamp.advanceTo(_now + frameOffset);
                qRamp.advanceTo(_now + frameOffset);
            }
            _pareq0->fc = cornerFrequencyRamp.getValue();
            _pareq1->fc = cornerFrequencyRamp.getValue();            
            _pareq0->v = gainRamp.getValue();
            _pareq1->v = gainRamp.getValue();            
            _pareq0->q = qRamp.getValue();
            _pareq1->q = qRamp.getValue();            

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
                    sp_pareq_compute(_sp, _pareq0, in, out);
                } else {
                    sp_pareq_compute(_sp, _pareq1, in, out);
                }
            }
            if (_playing) {
            }
        }
    }
};

#endif
