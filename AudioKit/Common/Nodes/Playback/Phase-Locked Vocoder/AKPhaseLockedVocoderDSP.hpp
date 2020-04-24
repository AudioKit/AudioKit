//
//  AKPhaseLockedVocoderDSP.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2020 AudioKit. All rights reserved.
//

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKPhaseLockedVocoderParameter) {
    AKPhaseLockedVocoderParameterPosition,
    AKPhaseLockedVocoderParameterAmplitude,
    AKPhaseLockedVocoderParameterPitchRatio,
};

#ifndef __cplusplus

AKDSPRef createPhaseLockedVocoderDSP(void);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKPhaseLockedVocoderDSP : public AKSoundpipeDSPBase {
private:
    struct InternalData;
    std::unique_ptr<InternalData> data;
 
public:
    AKPhaseLockedVocoderDSP();

    void setWavetable(const float* table, size_t length, int index) override;

    void init(int channelCount, double sampleRate) override;

    void deinit() override;

    void reset() override;

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override;
};

#endif
