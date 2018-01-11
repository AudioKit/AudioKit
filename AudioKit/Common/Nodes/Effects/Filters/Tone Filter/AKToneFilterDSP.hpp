//
//  AKToneFilterDSP.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import <Foundation/Foundation.h>

typedef NS_ENUM(int64_t, AKToneFilterParameter) {
    AKToneFilterParameterHalfPowerPoint,
    AKToneFilterParameterRampTime
};

#import "AKLinearParameterRamp.hpp"  // have to put this here to get it included in umbrella header

#ifndef __cplusplus

void* createToneFilterDSP(int nChannels, double sampleRate);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKToneFilterDSP : public AKSoundpipeDSPBase {

    sp_tone *_tone0;
    sp_tone *_tone1;
    sp_revsc* _revsc;


private:
    AKLinearParameterRamp halfPowerPointRamp;
   
public:
    AKToneFilterDSP() {
        halfPowerPointRamp.setTarget(1000.0, true);
        halfPowerPointRamp.setDurationInSamples(10000);
    }

    /** Uses the ParameterAddress as a key */
    void setParameter(uint64_t address, float value, bool immediate) override {
        switch (address) {
            case AKToneFilterParameterHalfPowerPoint:
                halfPowerPointRamp.setTarget(value, immediate);
                break;
            case AKToneFilterParameterRampTime:
                halfPowerPointRamp.setRampTime(value, _sampleRate);
                break;
        }
    }

    /** Uses the ParameterAddress as a key */
    float getParameter(uint64_t address) override {
        switch (address) {
            case AKToneFilterParameterHalfPowerPoint:
                return halfPowerPointRamp.getTarget();
            case AKToneFilterParameterRampTime:
                return halfPowerPointRamp.getRampTime(_sampleRate);
        }
        return 0;
    }

    void init(int _channels, double _sampleRate) override {
        AKSoundpipeDSPBase::init(_channels, _sampleRate);
        sp_tone_create(&_tone0);
        sp_tone_create(&_tone1);
        sp_tone_init(_sp, _tone0);
        sp_tone_init(_sp, _tone1);
        _tone0->hp = 1000.0;
        _tone1->hp = 1000.0;
    }

    void destroy() {
        sp_tone_destroy(&_tone0);
        sp_tone_destroy(&_tone1);
        AKSoundpipeDSPBase::destroy();
    }

    void process(uint32_t frameCount, uint32_t bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            // do gain ramping every 8 samples
            if ((frameOffset & 0x7) == 0) {
                halfPowerPointRamp.advanceTo(_now + frameOffset);
            }
            _tone0->hp = halfPowerPointRamp.getValue();
            _tone1->hp = halfPowerPointRamp.getValue();            

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
                    sp_tone_compute(_sp, _tone0, in, out);
                } else {
                    sp_tone_compute(_sp, _tone1, in, out);
                }
            }
            if (_playing) {
            }
        }
    }
};

#endif
