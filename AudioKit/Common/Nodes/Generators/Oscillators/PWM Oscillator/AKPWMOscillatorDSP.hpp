// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKPWMOscillatorParameter) {
    AKPWMOscillatorParameterFrequency,
    AKPWMOscillatorParameterAmplitude,
    AKPWMOscillatorParameterPulseWidth,
    AKPWMOscillatorParameterDetuningOffset,
    AKPWMOscillatorParameterDetuningMultiplier,
};

#ifndef __cplusplus

AKDSPRef createPWMOscillatorDSP(void);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKPWMOscillatorDSP : public AKSoundpipeDSPBase {
private:
    struct InternalData;
    std::unique_ptr<InternalData> data;

public:
    AKPWMOscillatorDSP();

    void init(int channelCount, double sampleRate) override;

    void deinit() override;

    void reset() override;

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override;
};

#endif
