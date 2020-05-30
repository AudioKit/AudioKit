// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM (AUParameterAddress, AKBoosterParameter) {
    AKBoosterParameterLeftGain,
    AKBoosterParameterRightGain
};

#ifndef __cplusplus

AKDSPRef createBoosterDSP(void);

#else

#import "AKDSPBase.hpp"

struct AKBoosterDSP : AKDSPBase {
private:
    struct InternalData;
    std::unique_ptr<InternalData> data;

public:
    AKBoosterDSP();

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override;
};

#endif
