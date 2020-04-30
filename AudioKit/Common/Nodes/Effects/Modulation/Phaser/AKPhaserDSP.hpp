// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKPhaserParameter) {
    AKPhaserParameterNotchMinimumFrequency,
    AKPhaserParameterNotchMaximumFrequency,
    AKPhaserParameterNotchWidth,
    AKPhaserParameterNotchFrequency,
    AKPhaserParameterVibratoMode,
    AKPhaserParameterDepth,
    AKPhaserParameterFeedback,
    AKPhaserParameterInverted,
    AKPhaserParameterLfoBPM,
};

#ifndef __cplusplus

AKDSPRef createPhaserDSP(void);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKPhaserDSP : public AKSoundpipeDSPBase {
private:
    struct InternalData;
    std::unique_ptr<InternalData> data;
 
public:
    AKPhaserDSP();

    void init(int channelCount, double sampleRate) override;

    void deinit() override;

    void reset() override;

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override;
};

#endif
