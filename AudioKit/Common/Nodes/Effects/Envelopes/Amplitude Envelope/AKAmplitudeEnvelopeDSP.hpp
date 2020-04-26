// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKAmplitudeEnvelopeParameter) {
    AKAmplitudeEnvelopeParameterAttackDuration,
    AKAmplitudeEnvelopeParameterDecayDuration,
    AKAmplitudeEnvelopeParameterSustainLevel,
    AKAmplitudeEnvelopeParameterReleaseDuration,
};

#ifndef __cplusplus

AKDSPRef createAmplitudeEnvelopeDSP(void);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKAmplitudeEnvelopeDSP : public AKSoundpipeDSPBase {
private:
    struct InternalData;
    std::unique_ptr<InternalData> data;
 
public:
    AKAmplitudeEnvelopeDSP();

    void init(int channelCount, double sampleRate) override;

    void deinit() override;

    void reset() override;

    void start() override;

    void stop() override;

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override;
};

#endif
