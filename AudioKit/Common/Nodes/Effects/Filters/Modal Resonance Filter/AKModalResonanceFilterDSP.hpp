//
//  AKModalResonanceFilterDSP.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import <Foundation/Foundation.h>

typedef NS_ENUM(int64_t, AKModalResonanceFilterParameter) {
    AKModalResonanceFilterParameterFrequency,
    AKModalResonanceFilterParameterQualityFactor,
    AKModalResonanceFilterParameterRampTime
};

#import "AKLinearParameterRamp.hpp"  // have to put this here to get it included in umbrella header

#ifndef __cplusplus

void* createModalResonanceFilterDSP(int nChannels, double sampleRate);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKModalResonanceFilterDSP : public AKSoundpipeDSPBase {

    sp_mode *_mode0;
    sp_mode *_mode1;

private:
    AKLinearParameterRamp frequencyRamp;
    AKLinearParameterRamp qualityFactorRamp;
   
public:
    AKModalResonanceFilterDSP() {
        frequencyRamp.setTarget(500.0, true);
        frequencyRamp.setDurationInSamples(10000);
        qualityFactorRamp.setTarget(50.0, true);
        qualityFactorRamp.setDurationInSamples(10000);
    }

    /** Uses the ParameterAddress as a key */
    void setParameter(uint64_t address, float value, bool immediate) override {
        switch (address) {
            case AKModalResonanceFilterParameterFrequency:
                frequencyRamp.setTarget(value, immediate);
                break;
            case AKModalResonanceFilterParameterQualityFactor:
                qualityFactorRamp.setTarget(value, immediate);
                break;
            case AKModalResonanceFilterParameterRampTime:
                frequencyRamp.setRampTime(value, _sampleRate);
                qualityFactorRamp.setRampTime(value, _sampleRate);
                break;
        }
    }

    /** Uses the ParameterAddress as a key */
    float getParameter(uint64_t address) override {
        switch (address) {
            case AKModalResonanceFilterParameterFrequency:
                return frequencyRamp.getTarget();
            case AKModalResonanceFilterParameterQualityFactor:
                return qualityFactorRamp.getTarget();
            case AKModalResonanceFilterParameterRampTime:
                return frequencyRamp.getRampTime(_sampleRate);
        }
        return 0;
    }

    void init(int _channels, double _sampleRate) override {
        AKSoundpipeDSPBase::init(_channels, _sampleRate);
        sp_mode_create(&_mode0);
        sp_mode_create(&_mode1);
        sp_mode_init(_sp, _mode0);
        sp_mode_init(_sp, _mode1);
        _mode0->freq = 500.0;
        _mode1->freq = 500.0;
        _mode0->q = 50.0;
        _mode1->q = 50.0;
    }

    void destroy() {
        sp_mode_destroy(&_mode0);
        sp_mode_destroy(&_mode1);
        AKSoundpipeDSPBase::destroy();
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            // do gain ramping every 8 samples
            if ((frameOffset & 0x7) == 0) {
                frequencyRamp.advanceTo(_now + frameOffset);
                qualityFactorRamp.advanceTo(_now + frameOffset);
            }
            _mode0->freq = frequencyRamp.getValue();
            _mode1->freq = frequencyRamp.getValue();            
            _mode0->q = qualityFactorRamp.getValue();
            _mode1->q = qualityFactorRamp.getValue();            

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
                    sp_mode_compute(_sp, _mode0, in, out);
                } else {
                    sp_mode_compute(_sp, _mode1, in, out);
                }
            }
            if (_playing) {
            }
        }
    }
};

#endif
