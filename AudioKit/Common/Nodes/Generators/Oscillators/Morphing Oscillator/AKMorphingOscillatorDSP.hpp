//
//  AKMorphingOscillatorDSP.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2020 AudioKit. All rights reserved.
//

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKMorphingOscillatorParameter) {
    AKMorphingOscillatorParameterFrequency,
    AKMorphingOscillatorParameterAmplitude,
    AKMorphingOscillatorParameterIndex,
    AKMorphingOscillatorParameterDetuningOffset,
    AKMorphingOscillatorParameterDetuningMultiplier,
};

#ifndef __cplusplus

AKDSPRef createMorphingOscillatorDSP(void);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKMorphingOscillatorDSP : public AKSoundpipeDSPBase {
private:
    struct InternalData;
    std::unique_ptr<InternalData> data;
 
public:
    AKMorphingOscillatorDSP();

    void setWavetable(const float* table, size_t length, int index) override;

    void init(int channelCount, double sampleRate) override;

    void deinit() override;

    void reset() override;

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override;
};

#endif
