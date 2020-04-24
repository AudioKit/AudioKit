//
//  AKRolandTB303FilterDSP.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2020 AudioKit. All rights reserved.
//

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKRolandTB303FilterParameter) {
    AKRolandTB303FilterParameterCutoffFrequency,
    AKRolandTB303FilterParameterResonance,
    AKRolandTB303FilterParameterDistortion,
    AKRolandTB303FilterParameterResonanceAsymmetry,
};

#ifndef __cplusplus

AKDSPRef createRolandTB303FilterDSP(void);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKRolandTB303FilterDSP : public AKSoundpipeDSPBase {
private:
    struct InternalData;
    std::unique_ptr<InternalData> data;
 
public:
    AKRolandTB303FilterDSP();

    void init(int channelCount, double sampleRate) override;

    void deinit() override;

    void reset() override;

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override;
};

#endif
