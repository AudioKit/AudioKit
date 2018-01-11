//
//  AKHighShelfParametricEqualizerFilterDSP.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import <Foundation/Foundation.h>

typedef NS_ENUM(int64_t, AKHighShelfParametricEqualizerFilterParameter) {
    AKHighShelfParametricEqualizerFilterParameterCenterFrequency,
    AKHighShelfParametricEqualizerFilterParameterGain,
    AKHighShelfParametricEqualizerFilterParameterQ,
    AKHighShelfParametricEqualizerFilterParameterRampTime
};

#import "AKLinearParameterRamp.hpp"  // have to put this here to get it included in umbrella header

#ifndef __cplusplus

void* createHighShelfParametricEqualizerFilterDSP(int nChannels, double sampleRate);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKHighShelfParametricEqualizerFilterDSP : public AKSoundpipeDSPBase {

    sp_pareq *_pareq0;
    sp_pareq *_pareq1;
    sp_revsc* _revsc;


private:
    AKLinearParameterRamp centerFrequencyRamp;
    AKLinearParameterRamp gainRamp;
    AKLinearParameterRamp qRamp;
   
public:
    AKHighShelfParametricEqualizerFilterDSP() {
        centerFrequencyRamp.setTarget(1000, true);
        centerFrequencyRamp.setDurationInSamples(10000);
        gainRamp.setTarget(1.0, true);
        gainRamp.setDurationInSamples(10000);
        qRamp.setTarget(0.707, true);
        qRamp.setDurationInSamples(10000);
    }

    /** Uses the ParameterAddress as a key */
    void setParameter(uint64_t address, float value, bool immediate) override {
        switch (address) {
            case AKHighShelfParametricEqualizerFilterParameterCenterFrequency:
                centerFrequencyRamp.setTarget(value, immediate);
                break;
            case AKHighShelfParametricEqualizerFilterParameterGain:
                gainRamp.setTarget(value, immediate);
                break;
            case AKHighShelfParametricEqualizerFilterParameterQ:
                qRamp.setTarget(value, immediate);
                break;
            case AKHighShelfParametricEqualizerFilterParameterRampTime:
                centerFrequencyRamp.setRampTime(value, _sampleRate);
                gainRamp.setRampTime(value, _sampleRate);
                qRamp.setRampTime(value, _sampleRate);
                break;
        }
    }

    /** Uses the ParameterAddress as a key */
    float getParameter(uint64_t address) override {
        switch (address) {
            case AKHighShelfParametricEqualizerFilterParameterCenterFrequency:
                return centerFrequencyRamp.getTarget();
            case AKHighShelfParametricEqualizerFilterParameterGain:
                return gainRamp.getTarget();
            case AKHighShelfParametricEqualizerFilterParameterQ:
                return qRamp.getTarget();
            case AKHighShelfParametricEqualizerFilterParameterRampTime:
                return centerFrequencyRamp.getRampTime(_sampleRate);
                return gainRamp.getRampTime(_sampleRate);
                return qRamp.getRampTime(_sampleRate);
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
        _pareq0->mode = 2;
        _pareq1->mode = 2;
    }

    void destroy() {
        sp_pareq_destroy(&_pareq0);
        sp_pareq_destroy(&_pareq1);
        AKSoundpipeDSPBase::destroy();
    }

    void process(uint32_t frameCount, uint32_t bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            // do gain ramping every 8 samples
            if ((frameOffset & 0x7) == 0) {
                centerFrequencyRamp.advanceTo(_now + frameOffset);
                gainRamp.advanceTo(_now + frameOffset);
                qRamp.advanceTo(_now + frameOffset);
            }
            _pareq0->fc = centerFrequencyRamp.getValue();
            _pareq1->fc = centerFrequencyRamp.getValue();            
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
