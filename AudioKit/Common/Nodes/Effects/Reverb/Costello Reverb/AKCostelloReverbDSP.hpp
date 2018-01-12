//
//  AKCostelloReverbDSP.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import <Foundation/Foundation.h>

typedef NS_ENUM(int64_t, AKCostelloReverbParameter) {
    AKCostelloReverbParameterFeedback,
    AKCostelloReverbParameterCutoffFrequency,
    AKCostelloReverbParameterRampTime
};

#import "AKLinearParameterRamp.hpp"  // have to put this here to get it included in umbrella header

#ifndef __cplusplus

void* createCostelloReverbDSP(int nChannels, double sampleRate);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKCostelloReverbDSP : public AKSoundpipeDSPBase {

    sp_revsc *_revsc;


private:
    AKLinearParameterRamp feedbackRamp;
    AKLinearParameterRamp cutoffFrequencyRamp;

public:
    AKCostelloReverbDSP() {
        feedbackRamp.setTarget(0.6, true);
        feedbackRamp.setDurationInSamples(10000);
        cutoffFrequencyRamp.setTarget(4000.0, true);
        cutoffFrequencyRamp.setDurationInSamples(10000);
    }

    /** Uses the ParameterAddress as a key */
    void setParameter(uint64_t address, float value, bool immediate) override {
        switch (address) {
            case AKCostelloReverbParameterFeedback:
                feedbackRamp.setTarget(value, immediate);
                break;
            case AKCostelloReverbParameterCutoffFrequency:
                cutoffFrequencyRamp.setTarget(value, immediate);
                break;
            case AKCostelloReverbParameterRampTime:
                feedbackRamp.setRampTime(value, _sampleRate);
                cutoffFrequencyRamp.setRampTime(value, _sampleRate);
                break;
        }
    }

    /** Uses the ParameterAddress as a key */
    float getParameter(uint64_t address) override {
        switch (address) {
            case AKCostelloReverbParameterFeedback:
                return feedbackRamp.getTarget();
            case AKCostelloReverbParameterCutoffFrequency:
                return cutoffFrequencyRamp.getTarget();
            case AKCostelloReverbParameterRampTime:
                return feedbackRamp.getRampTime(_sampleRate);
        }
        return 0;
    }

    void init(int _channels, double _sampleRate) override {
        AKSoundpipeDSPBase::init(_channels, _sampleRate);
        sp_revsc_create(&_revsc);
        sp_revsc_init(_sp, _revsc);
        _revsc->feedback = 0.6;
        _revsc->lpfreq = 4000.0;
    }

    void destroy() {
        sp_revsc_destroy(&_revsc);
        AKSoundpipeDSPBase::destroy();
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            // do gain ramping every 8 samples
            if ((frameOffset & 0x7) == 0) {
                feedbackRamp.advanceTo(_now + frameOffset);
                cutoffFrequencyRamp.advanceTo(_now + frameOffset);
            }


            _revsc->feedback = feedbackRamp.getValue();
            _revsc->lpfreq = cutoffFrequencyRamp.getValue();

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
            }
            if (_playing) {
                sp_revsc_compute(_sp, _revsc, tmpin[0], tmpin[1], tmpout[0], tmpout[1]);
            }
        }
    }
};

#endif
