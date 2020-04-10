// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKRolandTB303FilterParameter) {
    AKRolandTB303FilterParameterCutoffFrequency,
    AKRolandTB303FilterParameterResonance,
    AKRolandTB303FilterParameterDistortion,
    AKRolandTB303FilterParameterResonanceAsymmetry,
    AKRolandTB303FilterParameterRampDuration
};

#ifndef __cplusplus

AKDSPRef createRolandTB303FilterDSP(void);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKRolandTB303FilterDSP : public AKSoundpipeDSPBase {
private:
    struct InternalData;
    std::unique_ptr<InternalData> data;
 
public:
    AKRolandTB303FilterDSP();

    float cutoffFrequencyLowerBound = 12.0;
    float cutoffFrequencyUpperBound = 20000.0;
    float resonanceLowerBound = 0.0;
    float resonanceUpperBound = 2.0;
    float distortionLowerBound = 0.0;
    float distortionUpperBound = 4.0;
    float resonanceAsymmetryLowerBound = 0.0;
    float resonanceAsymmetryUpperBound = 1.0;

    float defaultCutoffFrequency = 500;
    float defaultResonance = 0.5;
    float defaultDistortion = 2.0;
    float defaultResonanceAsymmetry = 0.5;

    int defaultRampDurationSamples = 10000;

    // Uses the ParameterAddress as a key
    void setParameter(AUParameterAddress address, float value, bool immediate) override;

    // Uses the ParameterAddress as a key
    float getParameter(AUParameterAddress address) override;
    
    void init(int channelCount, double sampleRate) override;

    void deinit() override;

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override;
};

#endif
