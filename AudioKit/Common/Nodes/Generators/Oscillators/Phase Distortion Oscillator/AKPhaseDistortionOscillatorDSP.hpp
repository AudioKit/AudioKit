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

AKDSPRef createPhaseDistortionOscillatorDSP(int channelCount, double sampleRate);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKPhaseDistortionOscillatorDSP : public AKSoundpipeDSPBase {

    sp_pdhalf *pdhalf;
    sp_tabread *tabread;
    sp_phasor *phasor;

    sp_ftbl *ftbl;
    UInt32 ftbl_size = 4096;

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
                frequencyRamp.setRampDuration(value, sampleRate);
                amplitudeRamp.setRampDuration(value, sampleRate);
                phaseDistortionRamp.setRampDuration(value, sampleRate);
                detuningOffsetRamp.setRampDuration(value, sampleRate);
                detuningMultiplierRamp.setRampDuration(value, sampleRate);
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
                return frequencyRamp.getRampDuration(sampleRate);
        }
        return 0;
    }

    void init(int channelCount, double sampleRate) override {
        AKSoundpipeDSPBase::init(channelCount, sampleRate);
        isStarted = false;
        
        sp_pdhalf_create(&pdhalf);
        sp_tabread_create(&tabread);
        sp_tabread_init(sp, tabread, ftbl, 1);
        sp_phasor_create(&phasor);

        sp_pdhalf_init(sp, pdhalf);
        sp_phasor_init(sp, phasor, 0);

        phasor->freq = 440;
        pdhalf->amount = 0;
   }

    void deinit() override {
        sp_pdhalf_destroy(&pdhalf);
    }

    void setupWaveform(uint32_t size) override {
        ftbl_size = size;
        sp_ftbl_create(sp, &ftbl, ftbl_size);
    }

    void setWaveformValue(uint32_t index, float value) override {
        ftbl->tbl[index] = value;
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            // do ramping every 8 samples
            if ((frameOffset & 0x7) == 0) {
                frequencyRamp.advanceTo(now + frameOffset);
                amplitudeRamp.advanceTo(now + frameOffset);
                phaseDistortionRamp.advanceTo(now + frameOffset);
                detuningOffsetRamp.advanceTo(now + frameOffset);
                detuningMultiplierRamp.advanceTo(now + frameOffset);
            }
            float frequency = frequencyRamp.getValue();
            float amplitude = amplitudeRamp.getValue();
            float phaseDistortion = phaseDistortionRamp.getValue();
            float detuningOffset = detuningOffsetRamp.getValue();
            float detuningMultiplier = detuningMultiplierRamp.getValue();
            phasor->freq = frequency * detuningMultiplier + detuningOffset;
            pdhalf->amount = phaseDistortion;

            float temp = 0;
            float pd = 0;
            float ph = 0;

            for (int channel = 0; channel < channelCount; ++channel) {
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;

                if (isStarted) {
                    if (channel == 0) {
                        sp_phasor_compute(sp, phasor, NULL, &ph);
                        sp_pdhalf_compute(sp, pdhalf, &ph, &pd);
                        tabread->index = pd;
                        sp_tabread_compute(sp, tabread, NULL, &temp);

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
