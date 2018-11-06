//
//  AKDoNothingDSPKernel.hpp
//  AudioKit
//
//  Created by Jeff Cooper, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once
#import "AKSoundpipeKernel.hpp"

class AKDoNothingDSPKernel : public AKSoundpipeKernel, public AKOutputBuffered {
public:
    // MARK: Member Functions

    AKDoNothingDSPKernel() {}

    void init(int _channels, double _sampleRate) override {
        AKSoundpipeKernel::init(_channels, _sampleRate);
    }

    void destroy() {
        AKSoundpipeKernel::destroy();
    }
    void start() {
        started = true;
    }

    void stop() {
        started = false;
    }

    void reset() {
        resetted = true;
    }

    void setParameter(AUParameterAddress address, AUValue value) {

    }

    AUValue getParameter(AUParameterAddress address) {
        return 0.0f;
    }

    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {

    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        //do nothing
    }

private:

public:
    bool started = false;
    bool resetted = false;
};


