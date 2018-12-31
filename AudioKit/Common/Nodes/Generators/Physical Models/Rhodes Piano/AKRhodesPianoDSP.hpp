//
//  AKRhodesPianoDSP.hpp
//  AudioKit For iOS
//
//  Created by Aurelius Prochazka on 12/22/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKRhodesPianoParameter) {
    AKRhodesPianoParameterFrequency,
    AKRhodesPianoParameterAmplitude,
    AKRhodesPianoParameterRampDuration
};

#import "AKLinearParameterRamp.hpp"  // have to put this here to get it included in umbrella header

#ifndef __cplusplus

AKDSPRef createRhodesPianoDSP(int channelCount, double sampleRate);

#else

class AKRhodesPianoDSP : public AKDSPBase {
private:
    struct InternalData;
    std::unique_ptr<InternalData> data;

public:

    AKRhodesPianoDSP();

    ~AKRhodesPianoDSP();

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


