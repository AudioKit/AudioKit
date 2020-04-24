//
//  AKStereoDelayDSP.hpp
//  AudioKit
//
//  Created by Shane Dunne, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKStereoDelayParameter) {
    AKStereoDelayParameterTime,
    AKStereoDelayParameterFeedback,
    AKStereoDelayParameterDryWetMix,
    AKStereoDelayParameterPingPong,
};

#ifndef __cplusplus

AKDSPRef createStereoDelayDSP(void);

#else

#include "AKDSPBase.hpp"

class AKStereoDelayDSP : public AKDSPBase
{
private:
    struct InternalData;
    std::unique_ptr<InternalData> data;
 
public:
    AKStereoDelayDSP();

    void setParameter(AUParameterAddress address, float value, bool immediate) override;

    float getParameter(AUParameterAddress address) override;

    void init(int channelCount, double sampleRate) override;

    void deinit() override;

    void reset() override;

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override;
};

#endif
