//
//  AKBoosterDSP.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import <AVFoundation/AVFoundation.h>
#import "AKParameterRamp.hpp"
#import "AKExponentialParameterRamp.hpp" // to be deleted

typedef NS_ENUM(AUParameterAddress, AKBoosterParameter) {
    AKBoosterParameterLeftGain,
    AKBoosterParameterRightGain,
    AKBoosterParameterRampDuration,
    AKBoosterParameterRampType
};

#ifndef __cplusplus

void *createBoosterDSP(int nChannels, double sampleRate);

#else

#import "AKDSPBase.hpp"

/**
 A simple DSP kernel. Most of the plumbing is in the base class. All the code at this
 level has to do is supply the core of the rendering code. A less trivial example would probably
 need to coordinate the updating of DSP parameters, which would probably involve thread locks,
 etc.
 */

struct AKBoosterDSP : AKDSPBase {

private:
    struct _Internal;
    std::unique_ptr<_Internal> _private;

public:
    AKBoosterDSP();

    void setParameter(AUParameterAddress address, float value, bool immediate) override;
    float getParameter(AUParameterAddress address) override;
    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override;
};

#endif
