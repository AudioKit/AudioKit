//
//  AKFluteDSP.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKFluteParameter) {
    AKFluteParameterFrequency,
    AKFluteParameterAmplitude,
    AKFluteParameterRampDuration
};

#import "AKLinearParameterRamp.hpp"  // have to put this here to get it included in umbrella header

#ifndef __cplusplus

void *createFluteDSP(int nChannels, double sampleRate);

#else

class AKFluteDSP : public AKDSPBase {
private:
    struct _Internal;
    std::unique_ptr<_Internal> _private;

public:

    AKFluteDSP();

    ~AKFluteDSP();

    /** Uses the ParameterAddress as a key */
    void setParameter(AUParameterAddress address, float value, bool immediate) override;

    /** Uses the ParameterAddress as a key */
    float getParameter(AUParameterAddress address) override;

    void init(int _channels, double _sampleRate) override;

    void trigger() override;

    void triggerFrequencyAmplitude(AUValue freq, AUValue amp) override;

    void destroy();

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override;
};

#endif

