//
//  AKPhaseDistortionOscillatorDSP.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKPhaseDistortionOscillatorParameter) {
    AKPhaseDistortionOscillatorParameterFrequency,
    AKPhaseDistortionOscillatorParameterAmplitude,
    AKPhaseDistortionOscillatorParameterPhaseDistortion,
    AKPhaseDistortionOscillatorParameterDetuningOffset,
    AKPhaseDistortionOscillatorParameterDetuningMultiplier,
    AKPhaseDistortionOscillatorParameterRampDuration
};

#import "AKLinearParameterRamp.hpp"  // have to put this here to get it included in umbrella header

#ifndef __cplusplus

void *createPhaseDistortionOscillatorDSP(int nChannels, double sampleRate);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKPhaseDistortionOscillatorDSP : public AKSoundpipeDSPBase {

    sp_pdhalf *_pdhalf;
    sp_tabread *_tab;
    sp_phasor *_phs;

    sp_ftbl *_ftbl;
    UInt32 _ftbl_size = 4096;

private:
    AKLinearParameterRamp frequencyRamp;
    AKLinearParameterRamp amplitudeRamp;
    AKLinearParameterRamp phaseDistortionRamp;
    AKLinearParameterRamp detuningOffsetRamp;
    AKLinearParameterRamp detuningMultiplierRamp;

public:
    AKPhaseDistortionOscillatorDSP() {
        frequencyRamp.setTarget(440, true);
        frequencyRamp.setDurationInSamples(10000);
        amplitudeRamp.setTarget(1, true);
        amplitudeRamp.setDurationInSamples(10000);
        phaseDistortionRamp.setTarget(0, true);
        phaseDistortionRamp.setDurationInSamples(10000);
        detuningOffsetRamp.setTarget(0, true);
        detuningOffsetRamp.setDurationInSamples(10000);
        detuningMultiplierRamp.setTarget(1, true);
        detuningMultiplierRamp.setDurationInSamples(10000);
    }

    /** Uses the ParameterAddress as a key */
    void setParameter(AUParameterAddress address, float value, bool immediate) override {
        switch (address) {
            case AKPhaseDistortionOscillatorParameterFrequency:
                frequencyRamp.setTarget(value, immediate);
                break;
            case AKPhaseDistortionOscillatorParameterAmplitude:
                amplitudeRamp.setTarget(value, immediate);
                break;
            case AKPhaseDistortionOscillatorParameterPhaseDistortion:
                phaseDistortionRamp.setTarget(value, immediate);
                break;
            case AKPhaseDistortionOscillatorParameterDetuningOffset:
                detuningOffsetRamp.setTarget(value, immediate);
                break;
            case AKPhaseDistortionOscillatorParameterDetuningMultiplier:
                detuningMultiplierRamp.setTarget(value, immediate);
                break;
            case AKPhaseDistortionOscillatorParameterRampDuration:
                frequencyRamp.setRampDuration(value, _sampleRate);
                amplitudeRamp.setRampDuration(value, _sampleRate);
                phaseDistortionRamp.setRampDuration(value, _sampleRate);
                detuningOffsetRamp.setRampDuration(value, _sampleRate);
                detuningMultiplierRamp.setRampDuration(value, _sampleRate);
                break;
        }
    }

    /** Uses the ParameterAddress as a key */
    float getParameter(AUParameterAddress address) override {
        switch (address) {
            case AKPhaseDistortionOscillatorParameterFrequency:
                return frequencyRamp.getTarget();
            case AKPhaseDistortionOscillatorParameterAmplitude:
                return amplitudeRamp.getTarget();
            case AKPhaseDistortionOscillatorParameterPhaseDistortion:
                return phaseDistortionRamp.getTarget();
            case AKPhaseDistortionOscillatorParameterDetuningOffset:
                return detuningOffsetRamp.getTarget();
            case AKPhaseDistortionOscillatorParameterDetuningMultiplier:
                return detuningMultiplierRamp.getTarget();
            case AKPhaseDistortionOscillatorParameterRampDuration:
                return frequencyRamp.getRampDuration(_sampleRate);
        }
        return 0;
    }

    void init(int _channels, double _sampleRate) override {
        AKSoundpipeDSPBase::init(_channels, _sampleRate);
        _playing = false;
        
        sp_pdhalf_create(&_pdhalf);
        sp_tabread_create(&_tab);
        sp_tabread_init(_sp, _tab, _ftbl, 1);
        sp_phasor_create(&_phs);

        sp_pdhalf_init(_sp, _pdhalf);
        sp_phasor_init(_sp, _phs, 0);

        _phs->freq = 440;
        _pdhalf->amount = 0;
   }

    void deinit() override {
        sp_pdhalf_destroy(&_pdhalf);
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

            // do ramping every 8 samples
            if ((frameOffset & 0x7) == 0) {
                frequencyRamp.advanceTo(_now + frameOffset);
                amplitudeRamp.advanceTo(_now + frameOffset);
                phaseDistortionRamp.advanceTo(_now + frameOffset);
                detuningOffsetRamp.advanceTo(_now + frameOffset);
                detuningMultiplierRamp.advanceTo(_now + frameOffset);
            }
            float frequency = frequencyRamp.getValue();
            float amplitude = amplitudeRamp.getValue();
            float phaseDistortion = phaseDistortionRamp.getValue();
            float detuningOffset = detuningOffsetRamp.getValue();
            float detuningMultiplier = detuningMultiplierRamp.getValue();
            _phs->freq = frequency * detuningMultiplier + detuningOffset;
            _pdhalf->amount = phaseDistortion;

            float temp = 0;
            float pd = 0;
            float ph = 0;

            for (int channel = 0; channel < _nChannels; ++channel) {
                float *out = (float *)_outBufferListPtr->mBuffers[channel].mData + frameOffset;

                if (_playing) {
                    if (channel == 0) {
                        sp_phasor_compute(_sp, _phs, NULL, &ph);
                        sp_pdhalf_compute(_sp, _pdhalf, &ph, &pd);
                        _tab->index = pd;
                        sp_tabread_compute(_sp, _tab, NULL, &temp);

                    }
                    *out = temp * amplitude;
                } else {
                    *out = 0.0;
                }
            }
        }
    }
};

#endif
