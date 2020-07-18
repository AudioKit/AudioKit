// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#ifdef __cplusplus
#import "DSPKernel.hpp"
#import "ParameterRamper.hpp"

class AKDSPKernel : public DSPKernel {
protected:
    int channels;
    float sampleRate;
public:
    AKDSPKernel(int channelCount, float sampleRate) : channels(channelCount), sampleRate(sampleRate) { }
    AKDSPKernel();
    AKDSPKernel(const AKDSPKernel&) = delete; // non copyable
    AKDSPKernel& operator=( const AKDSPKernel& ) = delete; // non copyable

    float getSampleRate() { return sampleRate; }

    virtual ~AKDSPKernel() { }
    //
    // TODO: these should be constructors but the original samples
    // had init methods
    //

    virtual void init(int channelCount, double sampleRate) {
        channels = channelCount;
        sampleRate = sampleRate;
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

class AKDSPKernelWithParameters : AKDSPKernel, AKParametricKernel {
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

static inline double floatToHz(float noteNumber)
{
    return 440. * exp2((noteNumber - 69.0)/12.);
}

#endif
