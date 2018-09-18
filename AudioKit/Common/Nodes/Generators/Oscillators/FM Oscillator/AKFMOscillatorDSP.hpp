//
//  AKFMOscillatorDSP.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKFMOscillatorParameter) {
    AKFMOscillatorParameterBaseFrequency,
    AKFMOscillatorParameterCarrierMultiplier,
    AKFMOscillatorParameterModulatingMultiplier,
    AKFMOscillatorParameterModulationIndex,
    AKFMOscillatorParameterAmplitude,
    AKFMOscillatorParameterRampDuration
};

#ifndef __cplusplus

void *createFMOscillatorDSP(int nChannels, double sampleRate);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKFMOscillatorDSP : public AKSoundpipeDSPBase {
private:
    struct _Internal;
    std::unique_ptr<_Internal> _private;
 
public:
    AKFMOscillatorDSP();

    float baseFrequencyLowerBound = 0.0;
    float baseFrequencyUpperBound = 20000.0;
    float carrierMultiplierLowerBound = 0.0;
    float carrierMultiplierUpperBound = 1000.0;
    float modulatingMultiplierLowerBound = 0.0;
    float modulatingMultiplierUpperBound = 1000.0;
    float modulationIndexLowerBound = 0.0;
    float modulationIndexUpperBound = 1000.0;
    float amplitudeLowerBound = 0.0;
    float amplitudeUpperBound = 10.0;

    float defaultBaseFrequency = 440.0;
    float defaultCarrierMultiplier = 1.0;
    float defaultModulatingMultiplier = 1.0;
    float defaultModulationIndex = 1.0;
    float defaultAmplitude = 1.0;

    int defaultRampDurationSamples = 10000;

    // Uses the ParameterAddress as a key
    void setParameter(AUParameterAddress address, float value, bool immediate) override;

    // Uses the ParameterAddress as a key
    float getParameter(AUParameterAddress address) override;
    
    void init(int _channels, double _sampleRate) override;

    void deinit() override;

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override;

    // Generator Stuff
    void setupWaveform(uint32_t size) override;
    void setWaveformValue(uint32_t index, float value) override;
};

#endif
