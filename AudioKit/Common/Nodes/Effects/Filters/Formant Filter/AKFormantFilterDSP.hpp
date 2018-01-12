//
//  AKFormantFilterDSP.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import <Foundation/Foundation.h>

typedef NS_ENUM(int64_t, AKFormantFilterParameter) {
    AKFormantFilterParameterCenterFrequency,
    AKFormantFilterParameterAttackDuration,
    AKFormantFilterParameterDecayDuration,
    AKFormantFilterParameterRampTime
};

#import "AKLinearParameterRamp.hpp"  // have to put this here to get it included in umbrella header

#ifndef __cplusplus

void* createFormantFilterDSP(int nChannels, double sampleRate);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKFormantFilterDSP : public AKSoundpipeDSPBase {

    sp_fofilt *_fofilt0;
    sp_fofilt *_fofilt1;
    sp_revsc* _revsc;


private:
    AKLinearParameterRamp centerFrequencyRamp;
    AKLinearParameterRamp attackDurationRamp;
    AKLinearParameterRamp decayDurationRamp;
   
public:
    AKFormantFilterDSP() {
        centerFrequencyRamp.setTarget(1000, true);
        centerFrequencyRamp.setDurationInSamples(10000);
        attackDurationRamp.setTarget(0.007, true);
        attackDurationRamp.setDurationInSamples(10000);
        decayDurationRamp.setTarget(0.04, true);
        decayDurationRamp.setDurationInSamples(10000);
    }

    /** Uses the ParameterAddress as a key */
    void setParameter(uint64_t address, float value, bool immediate) override {
        switch (address) {
            case AKFormantFilterParameterCenterFrequency:
                centerFrequencyRamp.setTarget(value, immediate);
                break;
            case AKFormantFilterParameterAttackDuration:
                attackDurationRamp.setTarget(value, immediate);
                break;
            case AKFormantFilterParameterDecayDuration:
                decayDurationRamp.setTarget(value, immediate);
                break;
            case AKFormantFilterParameterRampTime:
                centerFrequencyRamp.setRampTime(value, _sampleRate);
                attackDurationRamp.setRampTime(value, _sampleRate);
                decayDurationRamp.setRampTime(value, _sampleRate);
                break;
        }
    }

    /** Uses the ParameterAddress as a key */
    float getParameter(uint64_t address) override {
        switch (address) {
            case AKFormantFilterParameterCenterFrequency:
                return centerFrequencyRamp.getTarget();
            case AKFormantFilterParameterAttackDuration:
                return attackDurationRamp.getTarget();
            case AKFormantFilterParameterDecayDuration:
                return decayDurationRamp.getTarget();
            case AKFormantFilterParameterRampTime:
                return centerFrequencyRamp.getRampTime(_sampleRate);
                return attackDurationRamp.getRampTime(_sampleRate);
                return decayDurationRamp.getRampTime(_sampleRate);
        }
        return 0;
    }

    void init(int _channels, double _sampleRate) override {
        AKSoundpipeDSPBase::init(_channels, _sampleRate);
        sp_fofilt_create(&_fofilt0);
        sp_fofilt_create(&_fofilt1);
        sp_fofilt_init(_sp, _fofilt0);
        sp_fofilt_init(_sp, _fofilt1);
        _fofilt0->freq = 1000;
        _fofilt1->freq = 1000;
        _fofilt0->atk = 0.007;
        _fofilt1->atk = 0.007;
        _fofilt0->dec = 0.04;
        _fofilt1->dec = 0.04;
    }

    void destroy() {
        sp_fofilt_destroy(&_fofilt0);
        sp_fofilt_destroy(&_fofilt1);
        AKSoundpipeDSPBase::destroy();
    }

    void process(uint32_t frameCount, uint32_t bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            // do gain ramping every 8 samples
            if ((frameOffset & 0x7) == 0) {
                centerFrequencyRamp.advanceTo(_now + frameOffset);
                attackDurationRamp.advanceTo(_now + frameOffset);
                decayDurationRamp.advanceTo(_now + frameOffset);
            }
            _fofilt0->freq = centerFrequencyRamp.getValue();
            _fofilt1->freq = centerFrequencyRamp.getValue();            
            _fofilt0->atk = attackDurationRamp.getValue();
            _fofilt1->atk = attackDurationRamp.getValue();            
            _fofilt0->dec = decayDurationRamp.getValue();
            _fofilt1->dec = decayDurationRamp.getValue();            

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
                    sp_fofilt_compute(_sp, _fofilt0, in, out);
                } else {
                    sp_fofilt_compute(_sp, _fofilt1, in, out);
                }
            }
            if (_playing) {
            }
        }
    }
};

#endif
