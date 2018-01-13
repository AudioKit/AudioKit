//
//  AKOscillatorDSP.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import <Foundation/Foundation.h>

typedef NS_ENUM(int64_t, AKOscillatorParameter) {
    AKOscillatorParameterFrequency,
    AKOscillatorParameterAmplitude,
    AKOscillatorParameterDetuningOffset,
    AKOscillatorParameterDetuningMultiplier,
    AKOscillatorParameterRampTime
};

#import "AKLinearParameterRamp.hpp"  // have to put this here to get it included in umbrella header

#ifndef __cplusplus

void* createOscillatorDSP(int nChannels, double sampleRate);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKOscillatorDSP : public AKSoundpipeDSPBase {

    sp_osc *_osc;
    sp_ftbl *_ftbl;
    UInt32 _ftbl_size = 4096;

private:
    AKLinearParameterRamp frequencyRamp;
    AKLinearParameterRamp amplitudeRamp;
    AKLinearParameterRamp detuningOffsetRamp;
    AKLinearParameterRamp detuningMultiplierRamp;

public:
    AKOscillatorDSP() {
        frequencyRamp.setTarget(440, true);
        frequencyRamp.setDurationInSamples(10000);
        amplitudeRamp.setTarget(1, true);
        amplitudeRamp.setDurationInSamples(10000);
        detuningOffsetRamp.setTarget(0, true);
        detuningOffsetRamp.setDurationInSamples(10000);
        detuningMultiplierRamp.setTarget(1, true);
        detuningMultiplierRamp.setDurationInSamples(10000);
    }

    /** Uses the ParameterAddress as a key */
    void setParameter(uint64_t address, float value, bool immediate) override {
        switch (address) {
            case AKOscillatorParameterFrequency:
                frequencyRamp.setTarget(value, immediate);
                break;
            case AKOscillatorParameterAmplitude:
                amplitudeRamp.setTarget(value, immediate);
                break;
            case AKOscillatorParameterDetuningOffset:
                detuningOffsetRamp.setTarget(value, immediate);
                break;
            case AKOscillatorParameterDetuningMultiplier:
                detuningMultiplierRamp.setTarget(value, immediate);
                break;
            case AKOscillatorParameterRampTime:
                frequencyRamp.setRampTime(value, _sampleRate);
                amplitudeRamp.setRampTime(value, _sampleRate);
                detuningOffsetRamp.setRampTime(value, _sampleRate);
                detuningMultiplierRamp.setRampTime(value, _sampleRate);
                break;
        }
    }

    /** Uses the ParameterAddress as a key */
    float getParameter(uint64_t address) override {
        switch (address) {
            case AKOscillatorParameterFrequency:
                return frequencyRamp.getTarget();
            case AKOscillatorParameterAmplitude:
                return amplitudeRamp.getTarget();
            case AKOscillatorParameterDetuningOffset:
                return detuningOffsetRamp.getTarget();
            case AKOscillatorParameterDetuningMultiplier:
                return detuningMultiplierRamp.getTarget();
            case AKOscillatorParameterRampTime:
                return frequencyRamp.getRampTime(_sampleRate);
        }
        return 0;
    }

    void init(int _channels, double _sampleRate) override {
        AKSoundpipeDSPBase::init(_channels, _sampleRate);
        
        sp_osc_create(&_osc);
        sp_osc_init(_sp, _osc, _ftbl, 0);
        _osc->freq = 440;
        _osc->amp = 1;
    }

    void destroy() {
        sp_osc_destroy(&_osc);
        AKSoundpipeDSPBase::destroy();
    }

    void setupWaveform(uint32_t size) override {
        _ftbl_size = size;
        sp_ftbl_create(_sp, &_ftbl, _ftbl_size);
    }

    void setWaveformValue(uint32_t index, float value) override {
        _ftbl->tbl[index] = value;
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            // do gain ramping every 8 samples
            if ((frameOffset & 0x7) == 0) {
                frequencyRamp.advanceTo(_now + frameOffset);
                amplitudeRamp.advanceTo(_now + frameOffset);
                detuningOffsetRamp.advanceTo(_now + frameOffset);
                detuningMultiplierRamp.advanceTo(_now + frameOffset);
            }
            float frequency = frequencyRamp.getValue();
            float amplitude = amplitudeRamp.getValue();
            float detuningOffset = detuningOffsetRamp.getValue();
            float detuningMultiplier = detuningMultiplierRamp.getValue();
            _osc->freq = frequency * detuningMultiplier + detuningOffset;
            _osc->amp = amplitude;

            float temp = 0;
            for (int channel = 0; channel < _nChannels; ++channel) {
                float* out = (float *)_outBufferListPtr->mBuffers[channel].mData + frameOffset;

                if (_playing) {
                    if (channel == 0) {
                        sp_osc_compute(_sp, _osc, nil, &temp);
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
