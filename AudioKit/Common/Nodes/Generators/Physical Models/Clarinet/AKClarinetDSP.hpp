//
//  AKClarinetDSP.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKClarinetParameter) {
    AKClarinetParameterFrequency,
    AKClarinetParameterAmplitude,
    AKClarinetParameterRampDuration
};

#import "AKLinearParameterRamp.hpp"  // have to put this here to get it included in umbrella header

#ifndef __cplusplus

AKDSPRef createClarinetDSP(int channelCount, double sampleRate);

#else

class AKClarinetDSP : public AKDSPBase {
private:
    struct InternalData;
    std::unique_ptr<InternalData> data;

public:

    AKClarinetDSP();
    
    ~AKClarinetDSP();

    /** Uses the ParameterAddress as a key */
    void setParameter(AUParameterAddress address, float value, bool immediate) override;

    /** Uses the ParameterAddress as a key */
    float getParameter(AUParameterAddress address) override;

    void init(int channelCount, double sampleRate) override;

    void trigger() override;

    void triggerFrequencyAmplitude(AUValue freq, AUValue amp) override;

    void destroy();

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override;
};

#endif

