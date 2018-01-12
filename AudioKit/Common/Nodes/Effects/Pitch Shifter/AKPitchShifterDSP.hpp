//
//  AKPitchShifterDSP.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import <Foundation/Foundation.h>

typedef NS_ENUM(int64_t, AKPitchShifterParameter) {
    AKPitchShifterParameterShift,
    AKPitchShifterParameterWindowSize,
    AKPitchShifterParameterCrossfade,
    AKPitchShifterParameterRampTime
};

#import "AKLinearParameterRamp.hpp"  // have to put this here to get it included in umbrella header

#ifndef __cplusplus

void* createPitchShifterDSP(int nChannels, double sampleRate);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKPitchShifterDSP : public AKSoundpipeDSPBase {

    sp_pshift *_pshift0;
    sp_pshift *_pshift1;

private:
    AKLinearParameterRamp shiftRamp;
    AKLinearParameterRamp windowSizeRamp;
    AKLinearParameterRamp crossfadeRamp;
   
public:
    AKPitchShifterDSP() {
        shiftRamp.setTarget(0, true);
        shiftRamp.setDurationInSamples(10000);
        windowSizeRamp.setTarget(1024, true);
        windowSizeRamp.setDurationInSamples(10000);
        crossfadeRamp.setTarget(512, true);
        crossfadeRamp.setDurationInSamples(10000);
    }

    /** Uses the ParameterAddress as a key */
    void setParameter(uint64_t address, float value, bool immediate) override {
        switch (address) {
            case AKPitchShifterParameterShift:
                shiftRamp.setTarget(value, immediate);
                break;
            case AKPitchShifterParameterWindowSize:
                windowSizeRamp.setTarget(value, immediate);
                break;
            case AKPitchShifterParameterCrossfade:
                crossfadeRamp.setTarget(value, immediate);
                break;
            case AKPitchShifterParameterRampTime:
                shiftRamp.setRampTime(value, _sampleRate);
                windowSizeRamp.setRampTime(value, _sampleRate);
                crossfadeRamp.setRampTime(value, _sampleRate);
                break;
        }
    }

    /** Uses the ParameterAddress as a key */
    float getParameter(uint64_t address) override {
        switch (address) {
            case AKPitchShifterParameterShift:
                return shiftRamp.getTarget();
            case AKPitchShifterParameterWindowSize:
                return windowSizeRamp.getTarget();
            case AKPitchShifterParameterCrossfade:
                return crossfadeRamp.getTarget();
            case AKPitchShifterParameterRampTime:
                return shiftRamp.getRampTime(_sampleRate);
        }
        return 0;
    }

    void init(int _channels, double _sampleRate) override {
        AKSoundpipeDSPBase::init(_channels, _sampleRate);
        sp_pshift_create(&_pshift0);
        sp_pshift_create(&_pshift1);
        sp_pshift_init(_sp, _pshift0);
        sp_pshift_init(_sp, _pshift1);
        *_pshift0->shift = 0;
        *_pshift1->shift = 0;
        *_pshift0->window = 1024;
        *_pshift1->window = 1024;
        *_pshift0->xfade = 512;
        *_pshift1->xfade = 512;
    }

    void destroy() {
        sp_pshift_destroy(&_pshift0);
        sp_pshift_destroy(&_pshift1);
        AKSoundpipeDSPBase::destroy();
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            // do gain ramping every 8 samples
            if ((frameOffset & 0x7) == 0) {
                shiftRamp.advanceTo(_now + frameOffset);
                windowSizeRamp.advanceTo(_now + frameOffset);
                crossfadeRamp.advanceTo(_now + frameOffset);
            }
            *_pshift0->shift = shiftRamp.getValue();
            *_pshift1->shift = shiftRamp.getValue();
            *_pshift0->window = windowSizeRamp.getValue();
            *_pshift1->window = windowSizeRamp.getValue();
            *_pshift0->xfade = crossfadeRamp.getValue();
            *_pshift1->xfade = crossfadeRamp.getValue();            

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
                    sp_pshift_compute(_sp, _pshift0, in, out);
                } else {
                    sp_pshift_compute(_sp, _pshift1, in, out);
                }
            }
            if (_playing) {
            }
        }
    }
};

#endif
