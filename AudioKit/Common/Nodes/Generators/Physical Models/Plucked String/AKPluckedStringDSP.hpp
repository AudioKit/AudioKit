// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKPluckedStringParameter) {
    AKPluckedStringParameterFrequency,
    AKPluckedStringParameterAmplitude,
};

#ifndef __cplusplus

AKDSPRef createPluckedStringDSP(void);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKPluckedStringDSP : public AKSoundpipeDSPBase {
private:
    struct InternalData;
    std::unique_ptr<InternalData> data;
 
public:
    AKPluckedStringDSP();

    void init(int channelCount, double sampleRate) override;

    void deinit() override;

    void reset() override;

    void trigger() override;

    void triggerFrequencyAmplitude(AUValue freq, AUValue amp) override;

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override;
};

#endif
