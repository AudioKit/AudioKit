//
//  AKToneComplementFilterDSP.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKToneComplementFilterParameter) {
    AKToneComplementFilterParameterHalfPowerPoint,
    AKToneComplementFilterParameterRampTime
};

#import "AKLinearParameterRamp.hpp"  // have to put this here to get it included in umbrella header

#ifndef __cplusplus

void* createToneComplementFilterDSP(int nChannels, double sampleRate);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKToneComplementFilterDSP : public AKSoundpipeDSPBase {

    sp_atone *_atone0;
    sp_atone *_atone1;

private:
    AKLinearParameterRamp halfPowerPointRamp;
   
public:
    AKToneComplementFilterDSP() {
        halfPowerPointRamp.setTarget(1000.0, true);
        halfPowerPointRamp.setDurationInSamples(10000);
    }

    /** Uses the ParameterAddress as a key */
    void setParameter(AUParameterAddress address, float value, bool immediate) override {
        switch (address) {
            case AKToneComplementFilterParameterHalfPowerPoint:
                halfPowerPointRamp.setTarget(value, immediate);
                break;
            case AKToneComplementFilterParameterRampTime:
                halfPowerPointRamp.setRampTime(value, _sampleRate);
                break;
        }
    }

    /** Uses the ParameterAddress as a key */
    float getParameter(AUParameterAddress address) override {
        switch (address) {
            case AKToneComplementFilterParameterHalfPowerPoint:
                return halfPowerPointRamp.getTarget();
            case AKToneComplementFilterParameterRampTime:
                return halfPowerPointRamp.getRampTime(_sampleRate);
        }
        return 0;
    }

    void init(int _channels, double _sampleRate) override {
        AKSoundpipeDSPBase::init(_channels, _sampleRate);
        sp_atone_create(&_atone0);
        sp_atone_create(&_atone1);
        sp_atone_init(_sp, _atone0);
        sp_atone_init(_sp, _atone1);
        _atone0->hp = 1000.0;
        _atone1->hp = 1000.0;
    }

    void destroy() {
        sp_atone_destroy(&_atone0);
        sp_atone_destroy(&_atone1);
        AKSoundpipeDSPBase::destroy();
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            // do gain ramping every 8 samples
            if ((frameOffset & 0x7) == 0) {
                halfPowerPointRamp.advanceTo(_now + frameOffset);
            }
            _atone0->hp = halfPowerPointRamp.getValue();
            _atone1->hp = halfPowerPointRamp.getValue();            

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
                    sp_atone_compute(_sp, _atone0, in, out);
                } else {
                    sp_atone_compute(_sp, _atone1, in, out);
                }
            }
            if (_playing) {
            }
        }
    }
};

#endif
