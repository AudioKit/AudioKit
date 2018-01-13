//
//  AKVariableDelayDSP.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import <Foundation/Foundation.h>

typedef NS_ENUM(int64_t, AKVariableDelayParameter) {
    AKVariableDelayParameterTime,
    AKVariableDelayParameterFeedback,
    AKVariableDelayParameterRampTime
};

#import "AKLinearParameterRamp.hpp"  // have to put this here to get it included in umbrella header

#ifndef __cplusplus

void* createVariableDelayDSP(int nChannels, double sampleRate);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKVariableDelayDSP : public AKSoundpipeDSPBase {

    sp_vdelay *_vdelay0;
    sp_vdelay *_vdelay1;
    sp_revsc* _revsc;


private:
    AKLinearParameterRamp timeRamp;
    AKLinearParameterRamp feedbackRamp;
   
public:
    AKVariableDelayDSP() {
        timeRamp.setTarget(0, true);
        timeRamp.setDurationInSamples(10000);
        feedbackRamp.setTarget(0, true);
        feedbackRamp.setDurationInSamples(10000);
    }

    /** Uses the ParameterAddress as a key */
    void setParameter(uint64_t address, float value, bool immediate) override {
        switch (address) {
            case AKVariableDelayParameterTime:
                timeRamp.setTarget(value, immediate);
                break;
            case AKVariableDelayParameterFeedback:
                feedbackRamp.setTarget(value, immediate);
                break;
            case AKVariableDelayParameterRampTime:
                timeRamp.setRampTime(value, _sampleRate);
                feedbackRamp.setRampTime(value, _sampleRate);
                break;
        }
    }

    /** Uses the ParameterAddress as a key */
    float getParameter(uint64_t address) override {
        switch (address) {
            case AKVariableDelayParameterTime:
                return timeRamp.getTarget();
            case AKVariableDelayParameterFeedback:
                return feedbackRamp.getTarget();
            case AKVariableDelayParameterRampTime:
                return timeRamp.getRampTime(_sampleRate);
                return feedbackRamp.getRampTime(_sampleRate);
        }
        return 0;
    }

    void init(int _channels, double _sampleRate) override {
        AKSoundpipeDSPBase::init(_channels, _sampleRate);

        sp_vdelay_create(&_vdelay0);
        sp_vdelay_create(&_vdelay1);
        sp_vdelay_init(_sp, _vdelay0, 10);
        sp_vdelay_init(_sp, _vdelay1, 10);


        _vdelay0->del = 0;
        _vdelay1->del = 0;
        _vdelay0->feedback = 0;
        _vdelay1->feedback = 0;

    }

    void destroy() {
        sp_vdelay_destroy(&_vdelay0);
        sp_vdelay_destroy(&_vdelay1);
        AKSoundpipeDSPBase::destroy();
    }

    void process(uint32_t frameCount, uint32_t bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            // do gain ramping every 8 samples
            if ((frameOffset & 0x7) == 0) {
                timeRamp.advanceTo(_now + frameOffset);
                feedbackRamp.advanceTo(_now + frameOffset);
            }
            _vdelay0->del = timeRamp.getValue();
            _vdelay1->del = timeRamp.getValue();            
            _vdelay0->feedback = feedbackRamp.getValue();
            _vdelay1->feedback = feedbackRamp.getValue();            

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
                if (_playing) {
                    if (channel == 0) {
                        sp_vdelay_compute(_sp, _vdelay0, in, out);
                    } else {
                        sp_vdelay_compute(_sp, _vdelay1, in, out);
                    }
                }
            }

        }
    }

    void clear() override {
        sp_vdelay_reset(_sp, _vdelay0);
        sp_vdelay_reset(_sp, _vdelay1);
    }

};

#endif
