//
//  AKPWMOscillatorDSP.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKPWMOscillatorParameter) {
    AKPWMOscillatorParameterFrequency,
    AKPWMOscillatorParameterAmplitude,
    AKPWMOscillatorParameterPulseWidth,
    AKPWMOscillatorParameterDetuningOffset,
    AKPWMOscillatorParameterDetuningMultiplier,
    AKPWMOscillatorParameterRampDuration
};

#import "AKLinearParameterRamp.hpp"  // have to put this here to get it included in umbrella header

#ifndef __cplusplus

void *createPWMOscillatorDSP(int nChannels, double sampleRate);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKPWMOscillatorDSP : public AKSoundpipeDSPBase {

    sp_blsquare *_blsquare;


private:
    AKLinearParameterRamp frequencyRamp;
    AKLinearParameterRamp amplitudeRamp;
    AKLinearParameterRamp pulseWidthRamp;
    AKLinearParameterRamp detuningOffsetRamp;
    AKLinearParameterRamp detuningMultiplierRamp;

public:
    AKPWMOscillatorDSP() {
        frequencyRamp.setTarget(440, true);
        frequencyRamp.setDurationInSamples(10000);
        amplitudeRamp.setTarget(1, true);
        amplitudeRamp.setDurationInSamples(10000);
        pulseWidthRamp.setTarget(0, true);
        pulseWidthRamp.setDurationInSamples(10000);
        detuningOffsetRamp.setTarget(0, true);
        detuningOffsetRamp.setDurationInSamples(10000);
        detuningMultiplierRamp.setTarget(1, true);
        detuningMultiplierRamp.setDurationInSamples(10000);
    }

    /** Uses the ParameterAddress as a key */
    void setParameter(AUParameterAddress address, float value, bool immediate) override {
        switch (address) {
            case AKPWMOscillatorParameterFrequency:
                frequencyRamp.setTarget(value, immediate);
                break;
            case AKPWMOscillatorParameterAmplitude:
                amplitudeRamp.setTarget(value, immediate);
                break;
            case AKPWMOscillatorParameterPulseWidth:
                pulseWidthRamp.setTarget(value, immediate);
                break;
            case AKPWMOscillatorParameterDetuningOffset:
                detuningOffsetRamp.setTarget(value, immediate);
                break;
            case AKPWMOscillatorParameterDetuningMultiplier:
                detuningMultiplierRamp.setTarget(value, immediate);
                break;
            case AKPWMOscillatorParameterRampDuration:
                frequencyRamp.setRampDuration(value, _sampleRate);
                amplitudeRamp.setRampDuration(value, _sampleRate);
                pulseWidthRamp.setRampDuration(value, _sampleRate);
                detuningOffsetRamp.setRampDuration(value, _sampleRate);
                detuningMultiplierRamp.setRampDuration(value, _sampleRate);
                break;
        }
    }

    /** Uses the ParameterAddress as a key */
    float getParameter(AUParameterAddress address) override {
        switch (address) {
            case AKPWMOscillatorParameterFrequency:
                return frequencyRamp.getTarget();
            case AKPWMOscillatorParameterAmplitude:
                return amplitudeRamp.getTarget();
            case AKPWMOscillatorParameterPulseWidth:
                return pulseWidthRamp.getTarget();
            case AKPWMOscillatorParameterDetuningOffset:
                return detuningOffsetRamp.getTarget();
            case AKPWMOscillatorParameterDetuningMultiplier:
                return detuningMultiplierRamp.getTarget();
            case AKPWMOscillatorParameterRampDuration:
                return frequencyRamp.getRampDuration(_sampleRate);
        }
        return 0;
    }

    void init(int _channels, double _sampleRate) override {
        AKSoundpipeDSPBase::init(_channels, _sampleRate);
        _playing = false;
        
        sp_blsquare_create(&_blsquare);
        sp_blsquare_init(_sp, _blsquare);
        *_blsquare->freq = 440;
        *_blsquare->amp = 1.0;
        *_blsquare->width = 0.5;
   }

    void deinit() override {
        sp_blsquare_destroy(&_blsquare);
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            // do ramping every 8 samples
            if ((frameOffset & 0x7) == 0) {
                frequencyRamp.advanceTo(_now + frameOffset);
                amplitudeRamp.advanceTo(_now + frameOffset);
                pulseWidthRamp.advanceTo(_now + frameOffset);
                detuningOffsetRamp.advanceTo(_now + frameOffset);
                detuningMultiplierRamp.advanceTo(_now + frameOffset);
            }
            float frequency = frequencyRamp.getValue();
            float amplitude = amplitudeRamp.getValue();
            float pulseWidth = pulseWidthRamp.getValue();
            float detuningOffset = detuningOffsetRamp.getValue();
            float detuningMultiplier = detuningMultiplierRamp.getValue();
            *_blsquare->freq = frequency * detuningMultiplier + detuningOffset;
            *_blsquare->amp = amplitude;
            *_blsquare->width = pulseWidth;

            float temp = 0;
            for (int channel = 0; channel < _nChannels; ++channel) {
                float *out = (float *)_outBufferListPtr->mBuffers[channel].mData + frameOffset;

                if (_playing) {
                    if (channel == 0) {
                        sp_blsquare_compute(_sp, _blsquare, nil, &temp);
                    }
                    *out = temp;
                } else {
                    *out = 0.0;
                }
            }
        }
    }
};

#endif
