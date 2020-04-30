// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKFMOscillatorParameter) {
    AKFMOscillatorParameterBaseFrequency,
    AKFMOscillatorParameterCarrierMultiplier,
    AKFMOscillatorParameterModulatingMultiplier,
    AKFMOscillatorParameterModulationIndex,
    AKFMOscillatorParameterAmplitude,
};

#ifndef __cplusplus

AKDSPRef createFMOscillatorDSP(void);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKFMOscillatorDSP : public AKSoundpipeDSPBase {
private:
    struct InternalData;
    std::unique_ptr<InternalData> data;
 
public:
    AKFMOscillatorDSP();

    void setWavetable(const float* table, size_t length, int index) override;

    void init(int channelCount, double sampleRate) override;

    void deinit() override;

    void reset() override;

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override;
};

#endif
