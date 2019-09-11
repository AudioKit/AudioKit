//
//  AKFader
//  AudioKit
//
//  Created by Ryan Francesconi, revision history on Github.
//  Copyright © 2019 AudioKit. All rights reserved.
//

#pragma once

#import <AVFoundation/AVFoundation.h>
#import "AKParameterRamp.hpp"
#import "AKExponentialParameterRamp.hpp" // to be deleted

typedef NS_ENUM (AUParameterAddress, AKFaderParameter) {
    AKFaderParameterLeftGain,
    AKFaderParameterRightGain
};

#ifndef __cplusplus

AKDSPRef createFaderDSP(int channelCount, double sampleRate);

#else

#import "AKDSPBase.hpp"

/**
 A simple DSP kernel. Most of the plumbing is in the base class. All the code at this
 level has to do is supply the core of the rendering code. A less trivial example would probably
 need to coordinate the updating of DSP parameters, which would probably involve thread locks,
 etc.
 */

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
};

#endif
