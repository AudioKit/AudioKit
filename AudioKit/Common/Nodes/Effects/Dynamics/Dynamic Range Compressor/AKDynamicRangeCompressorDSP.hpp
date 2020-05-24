// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKDynamicRangeCompressorParameter) {
    AKDynamicRangeCompressorParameterRatio,
    AKDynamicRangeCompressorParameterThreshold,
    AKDynamicRangeCompressorParameterAttackTime,
    AKDynamicRangeCompressorParameterReleaseTime,
};

#ifndef __cplusplus

AKDSPRef createDynamicRangeCompressorDSP(void);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKDynamicRangeCompressorDSP : public AKSoundpipeDSPBase {
private:
    struct InternalData;
    std::unique_ptr<InternalData> data;
 
public:
    AKDynamicRangeCompressorDSP();

    void init(int channelCount, double sampleRate) override;

    void deinit() override;

    void reset() override;

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override;
};

#endif
