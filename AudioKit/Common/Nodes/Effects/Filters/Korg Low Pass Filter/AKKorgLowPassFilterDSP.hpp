//
//  AKKorgLowPassFilterDSP.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2020 AudioKit. All rights reserved.
//

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKKorgLowPassFilterParameter) {
    AKKorgLowPassFilterParameterCutoffFrequency,
    AKKorgLowPassFilterParameterResonance,
    AKKorgLowPassFilterParameterSaturation,
};

#ifndef __cplusplus

AKDSPRef createKorgLowPassFilterDSP(void);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKKorgLowPassFilterDSP : public AKSoundpipeDSPBase {
private:
    struct InternalData;
    std::unique_ptr<InternalData> data;
 
public:
    AKKorgLowPassFilterDSP();

    void init(int channelCount, double sampleRate) override;

    void deinit() override;

    void reset() override;

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override;
};

#endif
