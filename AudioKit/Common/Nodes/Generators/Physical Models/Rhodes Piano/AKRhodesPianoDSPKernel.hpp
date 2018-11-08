//
//  AKRhodesPianoDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once
#import <AudioKit/AudioKit-Swift.h>

#import "AKDSPKernel.hpp"
#import "ParameterRamper.hpp"

class AKRhodesPianoDSPKernel : public AKDSPKernel, public AKOutputBuffered {
public:
    // MARK: Member Functions
    enum {
        frequencyAddress = 0,
        amplitudeAddress = 1
    };
    
    AKRhodesPianoDSPKernel();
    
    ~AKRhodesPianoDSPKernel();

    void init(int _channels, double _sampleRate) override;

    void start();
    void stop();

    void destroy();

    void reset();

    void setFrequency(float freq);

    void setAmplitude(float amp);

    void trigger();

    void setParameter(AUParameterAddress address, AUValue value);

    AUValue getParameter(AUParameterAddress address);

    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override;

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override;

    // MARK: Member Variables

private:
    struct _Internal;
    std::unique_ptr<_Internal> _private;

public:
    bool started = false;
    bool resetted = false;
    ParameterRamper frequencyRamper = 110;
    ParameterRamper amplitudeRamper = 0.5;
};

