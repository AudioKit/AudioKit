//
//  AKFaderDSP.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka and Ryan Francesconi, revision history on Github.
//  Copyright © 2019 AudioKit. All rights reserved.
//

#pragma once

#import <AVFoundation/AVFoundation.h>
#import "AKParameterRamp.hpp"

typedef NS_ENUM (AUParameterAddress, AKFaderParameter) {
    AKFaderParameterLeftGain,
    AKFaderParameterRightGain,
    AKFaderParameterTaper,
    AKFaderParameterSkew,
    AKFaderParameterOffset,
    AKFaderParameterFlipStereo,
    AKFaderParameterMixToMono
};

#ifndef __cplusplus

AKDSPRef createFaderDSP(int channelCount, double sampleRate);

#else

#import "AKDSPBase.hpp"

/// Based heavily off AKBooster, AKFader is slightly simpler and adds parameter ramping events
struct AKFaderDSP : AKDSPBase {
private:
    struct InternalData;
    std::unique_ptr<InternalData> data;

public:
    AKFaderDSP();

    void setParameter(AUParameterAddress address, float value, bool immediate) override;
    float getParameter(AUParameterAddress address) override;
    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override;
    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override;
    void start() override;
    void stop() override;
};

#endif
