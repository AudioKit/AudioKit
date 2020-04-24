//
//  AKDripDSP.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2020 AudioKit. All rights reserved.
//

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKDripParameter) {
    AKDripParameterIntensity,
    AKDripParameterDampingFactor,
    AKDripParameterEnergyReturn,
    AKDripParameterMainResonantFrequency,
    AKDripParameterFirstResonantFrequency,
    AKDripParameterSecondResonantFrequency,
    AKDripParameterAmplitude,
};

#ifndef __cplusplus

AKDSPRef createDripDSP(void);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKDripDSP : public AKSoundpipeDSPBase {
private:
    struct InternalData;
    std::unique_ptr<InternalData> data;
 
public:
    AKDripDSP();

    void init(int channelCount, double sampleRate) override;

    void deinit() override;

    void reset() override;
    
    void trigger() override;

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override;
};

#endif
