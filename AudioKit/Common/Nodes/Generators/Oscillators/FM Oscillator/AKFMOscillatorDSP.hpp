//
//  AKFMOscillatorDSP.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import <Foundation/Foundation.h>

typedef NS_ENUM(int64_t, AKFMOscillatorParameter) {
    AKFMOscillatorParameterBaseFrequency,
    AKFMOscillatorParameterCarrierMultiplier,
    AKFMOscillatorParameterModulatingMultiplier,
    AKFMOscillatorParameterModulationIndex,
    AKFMOscillatorParameterAmplitude,
    AKFMOscillatorParameterRampTime
};

#import "AKLinearParameterRamp.hpp"  // have to put this here to get it included in umbrella header

#ifndef __cplusplus

void* createFMOscillatorDSP(int nChannels, double sampleRate);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKFMOscillatorDSP : public AKSoundpipeDSPBase {

    sp_fosc *_fosc;
    sp_ftbl *_ftbl;
    UInt32 _ftbl_size = 4096;

private:
    AKLinearParameterRamp baseFrequencyRamp;
    AKLinearParameterRamp carrierMultiplierRamp;
    AKLinearParameterRamp modulatingMultiplierRamp;
    AKLinearParameterRamp modulationIndexRamp;
    AKLinearParameterRamp amplitudeRamp;

public:
    AKFMOscillatorDSP() {
        baseFrequencyRamp.setTarget(440, true);
        baseFrequencyRamp.setDurationInSamples(10000);
        carrierMultiplierRamp.setTarget(1.0, true);
        carrierMultiplierRamp.setDurationInSamples(10000);
        modulatingMultiplierRamp.setTarget(1, true);
        modulatingMultiplierRamp.setDurationInSamples(10000);
        modulationIndexRamp.setTarget(1, true);
        modulationIndexRamp.setDurationInSamples(10000);
        amplitudeRamp.setTarget(1, true);
        amplitudeRamp.setDurationInSamples(10000);
    }

    /** Uses the ParameterAddress as a key */
    void setParameter(uint64_t address, float value, bool immediate) override {
        switch (address) {
            case AKFMOscillatorParameterBaseFrequency:
                baseFrequencyRamp.setTarget(value, immediate);
                break;
            case AKFMOscillatorParameterCarrierMultiplier:
                carrierMultiplierRamp.setTarget(value, immediate);
                break;
            case AKFMOscillatorParameterModulatingMultiplier:
                modulatingMultiplierRamp.setTarget(value, immediate);
                break;
            case AKFMOscillatorParameterModulationIndex:
                modulationIndexRamp.setTarget(value, immediate);
                break;
            case AKFMOscillatorParameterAmplitude:
                amplitudeRamp.setTarget(value, immediate);
                break;
            case AKFMOscillatorParameterRampTime:
                baseFrequencyRamp.setRampTime(value, _sampleRate);
                carrierMultiplierRamp.setRampTime(value, _sampleRate);
                modulatingMultiplierRamp.setRampTime(value, _sampleRate);
                modulationIndexRamp.setRampTime(value, _sampleRate);
                amplitudeRamp.setRampTime(value, _sampleRate);
                break;
        }
    }

    /** Uses the ParameterAddress as a key */
    float getParameter(uint64_t address) override {
        switch (address) {
            case AKFMOscillatorParameterBaseFrequency:
                return baseFrequencyRamp.getTarget();
            case AKFMOscillatorParameterCarrierMultiplier:
                return carrierMultiplierRamp.getTarget();
            case AKFMOscillatorParameterModulatingMultiplier:
                return modulatingMultiplierRamp.getTarget();
            case AKFMOscillatorParameterModulationIndex:
                return modulationIndexRamp.getTarget();
            case AKFMOscillatorParameterAmplitude:
                return amplitudeRamp.getTarget();
            case AKFMOscillatorParameterRampTime:
                return baseFrequencyRamp.getRampTime(_sampleRate);
        }
        return 0;
    }

    void init(int _channels, double _sampleRate) override {
        AKSoundpipeDSPBase::init(_channels, _sampleRate);

        sp_fosc_create(&_fosc);
        sp_fosc_init(_sp, _fosc, _ftbl);
        _fosc->freq = 440;
        _fosc->car = 1.0;
        _fosc->mod = 1;
        _fosc->indx = 1;
        _fosc->amp = 1;
    }

    void destroy() {
        sp_fosc_destroy(&_fosc);
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
                baseFrequencyRamp.advanceTo(_now + frameOffset);
                carrierMultiplierRamp.advanceTo(_now + frameOffset);
                modulatingMultiplierRamp.advanceTo(_now + frameOffset);
                modulationIndexRamp.advanceTo(_now + frameOffset);
                amplitudeRamp.advanceTo(_now + frameOffset);
            }
            float baseFrequency = baseFrequencyRamp.getValue();
            float carrierMultiplier = carrierMultiplierRamp.getValue();
            float modulatingMultiplier = modulatingMultiplierRamp.getValue();
            float modulationIndex = modulationIndexRamp.getValue();
            float amplitude = amplitudeRamp.getValue();
            _fosc->freq = baseFrequency;
            _fosc->car = carrierMultiplier;
            _fosc->mod = modulatingMultiplier;
            _fosc->indx = modulationIndex;
            _fosc->amp = amplitude;

            float temp = 0;
            for (int channel = 0; channel < _nChannels; ++channel) {
                float* out = (float *)_outBufferListPtr->mBuffers[channel].mData + frameOffset;

                if (_playing) {
                    if (channel == 0) {
                        sp_fosc_compute(_sp, _fosc, nil, &temp);
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
