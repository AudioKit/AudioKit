//
//  AKMoogLadderDSP.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import <Foundation/Foundation.h>

typedef NS_ENUM(int64_t, AKMoogLadderParameter) {
    AKMoogLadderParameterCutoffFrequency,
    AKMoogLadderParameterResonance,
    AKMoogLadderParameterRampTime
};

#import "AKLinearParameterRamp.hpp"  // have to put this here to get it included in umbrella header

#ifndef __cplusplus

void* createMoogLadderDSP(int nChannels, double sampleRate);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKMoogLadderDSP : public AKSoundpipeDSPBase {

    sp_moogladder *_moogladder0;
    sp_moogladder *_moogladder1;

private:
    AKLinearParameterRamp cutoffFrequencyRamp;
    AKLinearParameterRamp resonanceRamp;
   
public:
    AKMoogLadderDSP() {
        cutoffFrequencyRamp.setTarget(1000, true);
        cutoffFrequencyRamp.setDurationInSamples(10000);
        resonanceRamp.setTarget(0.5, true);
        resonanceRamp.setDurationInSamples(10000);
    }

    /** Uses the ParameterAddress as a key */
    void setParameter(uint64_t address, float value, bool immediate) override {
        switch (address) {
            case AKMoogLadderParameterCutoffFrequency:
                cutoffFrequencyRamp.setTarget(value, immediate);
                break;
            case AKMoogLadderParameterResonance:
                resonanceRamp.setTarget(value, immediate);
                break;
            case AKMoogLadderParameterRampTime:
                cutoffFrequencyRamp.setRampTime(value, _sampleRate);
                resonanceRamp.setRampTime(value, _sampleRate);
                break;
        }
    }

    /** Uses the ParameterAddress as a key */
    float getParameter(uint64_t address) override {
        switch (address) {
            case AKMoogLadderParameterCutoffFrequency:
                return cutoffFrequencyRamp.getTarget();
            case AKMoogLadderParameterResonance:
                return resonanceRamp.getTarget();
            case AKMoogLadderParameterRampTime:
                return cutoffFrequencyRamp.getRampTime(_sampleRate);
                return resonanceRamp.getRampTime(_sampleRate);
        }
        return 0;
    }

    void init(int _channels, double _sampleRate) override {
        AKSoundpipeDSPBase::init(_channels, _sampleRate);
        sp_moogladder_create(&_moogladder0);
        sp_moogladder_create(&_moogladder1);
        sp_moogladder_init(_sp, _moogladder0);
        sp_moogladder_init(_sp, _moogladder1);
        _moogladder0->freq = 1000;
        _moogladder1->freq = 1000;
        _moogladder0->res = 0.5;
        _moogladder1->res = 0.5;
    }

    void destroy() {
        sp_moogladder_destroy(&_moogladder0);
        sp_moogladder_destroy(&_moogladder1);
        AKSoundpipeDSPBase::destroy();
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            // do gain ramping every 8 samples
            if ((frameOffset & 0x7) == 0) {
                cutoffFrequencyRamp.advanceTo(_now + frameOffset);
                resonanceRamp.advanceTo(_now + frameOffset);
            }
            _moogladder0->freq = cutoffFrequencyRamp.getValue();
            _moogladder1->freq = cutoffFrequencyRamp.getValue();            
            _moogladder0->res = resonanceRamp.getValue();
            _moogladder1->res = resonanceRamp.getValue();            

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
                    sp_moogladder_compute(_sp, _moogladder0, in, out);
                } else {
                    sp_moogladder_compute(_sp, _moogladder1, in, out);
                }
            }
            if (_playing) {
            }
        }
    }
};

#endif
