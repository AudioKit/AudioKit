//
//  AKMandolinDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once
#import "AKDSPKernel.hpp"
#import "ParameterRamper.hpp"

#import <AudioKit/AudioKit-Swift.h>

class AKMandolinDSPKernel : public AKDSPKernel, public AKOutputBuffered {
public:
    // MARK: Member Functions
    enum {
        detuneAddress = 0,
        bodySizeAddress = 1,
    };
    
    AKMandolinDSPKernel();
    
    ~AKMandolinDSPKernel();

    void init(int channelCount, double sampleRate) override;

    void destroy();

    void reset();

    void setDetune(float value);

    void setBodySize(float value);

    void setFrequency(float frequency, int course);
    
    void pluck(int course, float position, int velocity);
    
    void mute(int course);

    void setParameter(AUParameterAddress address, AUValue value);
    AUValue getParameter(AUParameterAddress address);

    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override;

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override;

    // MARK: Member Variables

private:
    struct InternalData;
    std::unique_ptr<InternalData> data;
    
public:
    bool started = false;
    bool resetted = false;

    ParameterRamper detuneRamper = 1;
    ParameterRamper bodySizeRamper = 1;
};


