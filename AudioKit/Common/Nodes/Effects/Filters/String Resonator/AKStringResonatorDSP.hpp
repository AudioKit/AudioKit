//
//  AKStringResonatorDSP.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import <Foundation/Foundation.h>

typedef NS_ENUM(int64_t, AKStringResonatorParameter) {
    AKStringResonatorParameterFundamentalFrequency,
    AKStringResonatorParameterFeedback,
    AKStringResonatorParameterRampTime
};

#import "AKLinearParameterRamp.hpp"  // have to put this here to get it included in umbrella header

#ifndef __cplusplus

void* createStringResonatorDSP(int nChannels, double sampleRate);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKStringResonatorDSP : public AKSoundpipeDSPBase {

    sp_streson *_streson0;
    sp_streson *_streson1;

private:
    AKLinearParameterRamp fundamentalFrequencyRamp;
    AKLinearParameterRamp feedbackRamp;
   
public:
    AKStringResonatorDSP() {
        fundamentalFrequencyRamp.setTarget(100, true);
        fundamentalFrequencyRamp.setDurationInSamples(10000);
        feedbackRamp.setTarget(0.95, true);
        feedbackRamp.setDurationInSamples(10000);
    }

    /** Uses the ParameterAddress as a key */
    void setParameter(uint64_t address, float value, bool immediate) override {
        switch (address) {
            case AKStringResonatorParameterFundamentalFrequency:
                fundamentalFrequencyRamp.setTarget(value, immediate);
                break;
            case AKStringResonatorParameterFeedback:
                feedbackRamp.setTarget(value, immediate);
                break;
            case AKStringResonatorParameterRampTime:
                fundamentalFrequencyRamp.setRampTime(value, _sampleRate);
                feedbackRamp.setRampTime(value, _sampleRate);
                break;
        }
    }

    /** Uses the ParameterAddress as a key */
    float getParameter(uint64_t address) override {
        switch (address) {
            case AKStringResonatorParameterFundamentalFrequency:
                return fundamentalFrequencyRamp.getTarget();
            case AKStringResonatorParameterFeedback:
                return feedbackRamp.getTarget();
            case AKStringResonatorParameterRampTime:
                return fundamentalFrequencyRamp.getRampTime(_sampleRate);
        }
        return 0;
    }

    void init(int _channels, double _sampleRate) override {
        AKSoundpipeDSPBase::init(_channels, _sampleRate);
        sp_streson_create(&_streson0);
        sp_streson_create(&_streson1);
        sp_streson_init(_sp, _streson0);
        sp_streson_init(_sp, _streson1);
        _streson0->freq = 100;
        _streson1->freq = 100;
        _streson0->fdbgain = 0.95;
        _streson1->fdbgain = 0.95;
    }

    void destroy() {
        sp_streson_destroy(&_streson0);
        sp_streson_destroy(&_streson1);
        AKSoundpipeDSPBase::destroy();
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            // do gain ramping every 8 samples
            if ((frameOffset & 0x7) == 0) {
                fundamentalFrequencyRamp.advanceTo(_now + frameOffset);
                feedbackRamp.advanceTo(_now + frameOffset);
            }
            _streson0->freq = fundamentalFrequencyRamp.getValue();
            _streson1->freq = fundamentalFrequencyRamp.getValue();            
            _streson0->fdbgain = feedbackRamp.getValue();
            _streson1->fdbgain = feedbackRamp.getValue();            

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
                    sp_streson_compute(_sp, _streson0, in, out);
                } else {
                    sp_streson_compute(_sp, _streson1, in, out);
                }
            }
            if (_playing) {
            }
        }
    }
};

#endif
