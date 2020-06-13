// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKTubularBellsParameter) {
    AKTubularBellsParameterFrequency,
    AKTubularBellsParameterAmplitude,
    AKTubularBellsParameterRampDuration
};

#import <AudioKit/AKLinearParameterRamp.hpp>

#ifndef __cplusplus

AKDSPRef createTubularBellsDSP(void);

#else

class AKTubularBellsDSP : public AKDSPBase {
private:
    struct InternalData;
    std::unique_ptr<InternalData> data;

public:

    AKTubularBellsDSP();

    ~AKTubularBellsDSP();

    /// Uses the ParameterAddress as a key
    void setParameter(AUParameterAddress address, float value, bool immediate) override;

    /// Uses the ParameterAddress as a key
    float getParameter(AUParameterAddress address) override;

    void init(int channelCount, double sampleRate) override;

    void trigger() override;

    void triggerFrequencyAmplitude(AUValue freq, AUValue amp) override;

    void deinit() override;

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override;
};

#endif


