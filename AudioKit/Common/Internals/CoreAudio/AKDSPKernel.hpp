//
//  AKDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on GitHub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#ifdef __cplusplus
#pragma once

#import "DSPKernel.hpp"
#import "ParameterRamper.hpp"

class AKDSPKernel : public DSPKernel {
protected:
    int channels;
    float sampleRate;
public:
    AKDSPKernel(int _channels, float _sampleRate) : channels(_channels), sampleRate(_sampleRate) { }

    AKDSPKernel();

    virtual ~AKDSPKernel() { }
    //
    // TODO: these should be constructors but the original samples
    // had init methods
    //

    virtual void init(int _channels, double _sampleRate) {
        channels = _channels;
        sampleRate = _sampleRate;
    }
};

class AKParametricKernel {
protected:
    virtual ParameterRamper& getRamper(AUParameterAddress address) = 0;

public:

    AUValue getParameter(AUParameterAddress address) {
        return getRamper(address).getUIValue();
    }

    void setParameter(AUParameterAddress address, AUValue value) {
        return getRamper(address).setUIValue(value);
    }
    virtual void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) {
        getRamper(address).startRamp(value, duration);
    }
};

class AKOutputBuffered {
protected:
    AudioBufferList *outBufferListPtr = nullptr;
public:
    void setBuffer(AudioBufferList *outBufferList) {
        outBufferListPtr = outBufferList;
    }
};


class AKBuffered: public AKOutputBuffered {
protected:
    AudioBufferList *inBufferListPtr = nullptr;
public:
    void setBuffers(AudioBufferList *inBufferList, AudioBufferList *outBufferList) {
        AKOutputBuffered::setBuffer(outBufferList);
        inBufferListPtr = inBufferList;
    }
};

class AKDSPKernelWithParams : AKDSPKernel, AKParametricKernel {
public:
    void start() {}
    void stop() {}
    bool started;
    bool resetted;

};

static inline double noteToHz(int noteNumber)
{
    return 440. * exp2((noteNumber - 69)/12.);
}

#endif

