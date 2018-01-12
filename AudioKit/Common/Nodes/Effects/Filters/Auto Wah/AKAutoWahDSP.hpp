//
//  AKAutoWahDSP.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import <Foundation/Foundation.h>

typedef NS_ENUM(int64_t, AKAutoWahParameter) {
    AKAutoWahParameterWah,
    AKAutoWahParameterMix,
    AKAutoWahParameterAmplitude,
    AKAutoWahParameterRampTime
};

#import "AKLinearParameterRamp.hpp"  // have to put this here to get it included in umbrella header

#ifndef __cplusplus

void* createAutoWahDSP(int nChannels, double sampleRate);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKAutoWahDSP : public AKSoundpipeDSPBase {

    sp_autowah *_autowah0;
    sp_autowah *_autowah1;

private:
    AKLinearParameterRamp wahRamp;
    AKLinearParameterRamp mixRamp;
    AKLinearParameterRamp amplitudeRamp;
   
public:
    AKAutoWahDSP() {
        wahRamp.setTarget(0.0, true);
        wahRamp.setDurationInSamples(10000);
        mixRamp.setTarget(1.0, true);
        mixRamp.setDurationInSamples(10000);
        amplitudeRamp.setTarget(0.1, true);
        amplitudeRamp.setDurationInSamples(10000);
    }

    /** Uses the ParameterAddress as a key */
    void setParameter(uint64_t address, float value, bool immediate) override {
        switch (address) {
            case AKAutoWahParameterWah:
                wahRamp.setTarget(value, immediate);
                break;
            case AKAutoWahParameterMix:
                mixRamp.setTarget(value, immediate);
                break;
            case AKAutoWahParameterAmplitude:
                amplitudeRamp.setTarget(value, immediate);
                break;
            case AKAutoWahParameterRampTime:
                wahRamp.setRampTime(value, _sampleRate);
                mixRamp.setRampTime(value, _sampleRate);
                amplitudeRamp.setRampTime(value, _sampleRate);
                break;
        }
    }

    /** Uses the ParameterAddress as a key */
    float getParameter(uint64_t address) override {
        switch (address) {
            case AKAutoWahParameterWah:
                return wahRamp.getTarget();
            case AKAutoWahParameterMix:
                return mixRamp.getTarget();
            case AKAutoWahParameterAmplitude:
                return amplitudeRamp.getTarget();
            case AKAutoWahParameterRampTime:
                return wahRamp.getRampTime(_sampleRate);
                return mixRamp.getRampTime(_sampleRate);
                return amplitudeRamp.getRampTime(_sampleRate);
        }
        return 0;
    }

    void init(int _channels, double _sampleRate) override {
        AKSoundpipeDSPBase::init(_channels, _sampleRate);
        sp_autowah_create(&_autowah0);
        sp_autowah_create(&_autowah1);
        sp_autowah_init(_sp, _autowah0);
        sp_autowah_init(_sp, _autowah1);
        *_autowah0->wah = 0.0;
        *_autowah1->wah = 0.0;
        *_autowah0->mix = 1.0;
        *_autowah1->mix = 1.0;
        *_autowah0->level = 0.1;
        *_autowah1->level = 0.1;
    }

    void destroy() {
        sp_autowah_destroy(&_autowah0);
        sp_autowah_destroy(&_autowah1);
        AKSoundpipeDSPBase::destroy();
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            // do gain ramping every 8 samples
            if ((frameOffset & 0x7) == 0) {
                wahRamp.advanceTo(_now + frameOffset);
                mixRamp.advanceTo(_now + frameOffset);
                amplitudeRamp.advanceTo(_now + frameOffset);
            }
            *_autowah0->wah = wahRamp.getValue();
            *_autowah1->wah = wahRamp.getValue();
            *_autowah0->mix = mixRamp.getValue() * 100.0;
            *_autowah1->mix = mixRamp.getValue() * 100.0;
            *_autowah0->level = amplitudeRamp.getValue();
            *_autowah1->level = amplitudeRamp.getValue();            

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
                    sp_autowah_compute(_sp, _autowah0, in, out);
                } else {
                    sp_autowah_compute(_sp, _autowah1, in, out);
                }
            }
            if (_playing) {
            }
        }
    }
};

#endif
