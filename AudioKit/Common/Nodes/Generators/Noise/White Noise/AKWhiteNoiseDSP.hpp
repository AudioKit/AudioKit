// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKWhiteNoiseParameter) {
    AKWhiteNoiseParameterAmplitude,
};

#ifndef __cplusplus

AKDSPRef createWhiteNoiseDSP(void);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKWhiteNoiseDSP : public AKSoundpipeDSPBase {
private:
    struct InternalData;
    std::unique_ptr<InternalData> data;
 
public:
    AKWhiteNoiseDSP();

    void init(int channelCount, double sampleRate) override;

    void deinit() override;

    void reset() override;

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override;
};

#endif
