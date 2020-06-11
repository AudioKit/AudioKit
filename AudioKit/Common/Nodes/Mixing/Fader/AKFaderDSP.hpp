// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import <AVFoundation/AVFoundation.h>
#import "AKParameterRamp.hpp"

typedef NS_ENUM (AUParameterAddress, AKFaderParameter) {
    AKFaderParameterLeftGain,
    AKFaderParameterRightGain,
    AKFaderParameterFlipStereo,
    AKFaderParameterMixToMono
};

#ifndef __cplusplus

AKDSPRef createFaderDSP(void);

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
};

#endif
