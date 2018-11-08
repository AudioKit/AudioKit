//
//  AKMorphingOscillatorDSP.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKMorphingOscillatorParameter) {
    AKMorphingOscillatorParameterFrequency,
    AKMorphingOscillatorParameterAmplitude,
    AKMorphingOscillatorParameterIndex,
    AKMorphingOscillatorParameterDetuningOffset,
    AKMorphingOscillatorParameterDetuningMultiplier,
    AKMorphingOscillatorParameterRampDuration
};

#ifndef __cplusplus

void *createMorphingOscillatorDSP(int nChannels, double sampleRate);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKMorphingOscillatorDSP : public AKSoundpipeDSPBase {
private:
    struct _Internal;
    std::unique_ptr<_Internal> _private;
 
public:
    AKMorphingOscillatorDSP();

    float frequencyLowerBound = 0.0;
    float frequencyUpperBound = 22050.0;
    float amplitudeLowerBound = 0.0;
    float amplitudeUpperBound = 1.0;
    float indexLowerBound = 0.0;
    float indexUpperBound = 1000.0;
    float detuningOffsetLowerBound = -1000.0;
    float detuningOffsetUpperBound = 1000.0;
    float detuningMultiplierLowerBound = 0.9;
    float detuningMultiplierUpperBound = 1.11;

    float defaultFrequency = 440;
    float defaultAmplitude = 0.5;
    float defaultIndex = 0.0;
    float defaultDetuningOffset = 0;
    float defaultDetuningMultiplier = 1;

    int defaultRampDurationSamples = 10000;

    // Uses the ParameterAddress as a key
    void setParameter(AUParameterAddress address, float value, bool immediate) override;

    // Uses the ParameterAddress as a key
    float getParameter(AUParameterAddress address) override;
    
    void init(int _channels, double _sampleRate) override;

    void deinit() override;
    void reset() override;

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override;

    void setupIndividualWaveform(uint32_t waveform, uint32_t size) override;
    void setIndividualWaveformValue(uint32_t waveform, uint32_t index, float value) override;
};

#endif
