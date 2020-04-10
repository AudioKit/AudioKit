// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import <AVFoundation/AVFoundation.h>
#import <AKInterop.h>

typedef NS_ENUM(AUParameterAddress, SDBoosterParameter) {
    SDBoosterParameterLeftGain,
    SDBoosterParameterRightGain,
    SDBoosterParameterRampDuration
};

#ifndef __cplusplus

AKDSPRef createSDBoosterDSP(int nChannels, double sampleRate);

#else

#import "AKDSPBase.hpp"

struct SDBoosterDSP : AKDSPBase {

private:
    struct _Internal;
    std::unique_ptr<_Internal> _private;

public:
    SDBoosterDSP();

    void setParameter(AUParameterAddress address, float value, bool immediate) override;
    float getParameter(AUParameterAddress address) override;
    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override;
};

#endif
