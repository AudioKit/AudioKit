//
//  AKShakerDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import "AKDSPKernel.hpp"
#import "ParameterRamper.hpp"

#import <AudioKit/AudioKit-Swift.h>

class AKShakerDSPKernel : public AKDSPKernel, public AKOutputBuffered {
public:

    enum {
        amplitudeAddress = 0
    };
    
    // MARK: Member Functions

    AKShakerDSPKernel();
    ~AKShakerDSPKernel();

    void init(int _channels, double _sampleRate) override;

    void start();

    void stop();

    void destroy();

    void reset();

    void setType(UInt8 typ);

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
    ParameterRamper amplitudeRamper = 0.5;
};

