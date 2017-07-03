//
//  AKDSPKernel.hpp
//  AudioKit For macOS
//
//  Created by Aurelius Prochazka on 7/1/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

#pragma once

#import "DSPKernel.hpp"

class AKDSPKernel: public DSPKernel {
protected:
    int channels = AKSettings.numberOfChannels;
    float sampleRate = AKSettings.sampleRate;
public:
    AKDSPKernel(int _channels, float _sampleRate):
    channels(_channels), sampleRate(_sampleRate) { }
    
    AKDSPKernel(): AKDSPKernel(AKSettings.numberOfChannels, AKSettings.sampleRate) { }
    
    virtual ~AKDSPKernel() { }
    //
    // todo: these should be constructors but the original samples
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
