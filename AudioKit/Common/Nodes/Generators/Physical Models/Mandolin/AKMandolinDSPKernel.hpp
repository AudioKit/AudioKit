//
//  AKMandolinDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2017 Aurelius Prochazka. All rights reserved.
//

#pragma once
#import "DSPKernel.hpp"
#import "ParameterRamper.hpp"

#import <AudioKit/AudioKit-Swift.h>

#include "Mandolin.h"

enum {
    detuneAddress = 0,
    bodySizeAddress = 1,
};

static inline double noteToHz(int noteNumber)
{
    return 440. * exp2((noteNumber - 69)/12.);
}

class AKMandolinDSPKernel : public AKDSPKernel, public AKOutputBuffered {
public:
    // MARK: Member Functions
    
    AKMandolinDSPKernel() {}
    
    void init(int _channels, double _sampleRate) override {
        AKDSPKernel::init(_channels, _sampleRate);

        // iOS Hack
        NSBundle *frameworkBundle = [NSBundle bundleForClass:[AKOscillator class]];
        NSString *resourcePath = [frameworkBundle resourcePath];
        stk::Stk::setRawwavePath([resourcePath cStringUsingEncoding:NSUTF8StringEncoding]);
        
        stk::Stk::setSampleRate(sampleRate);
    }
    
    void destroy() {

    }
    
    void reset() {
        resetted = true;
    }
    
    void setDetune(float value) {
        detune = clamp(value, 0.0f, 10.0f);
        detuneRamper.setImmediate(detune);
    }

    void setBodySize(float value) {
        bodySize = clamp(value, 0.0f, 3.0f);
        bodySizeRamper.setImmediate(bodySize);
    }
    
    void setFrequency(float frequency, int course) {
        mandolins[course].setFrequency(frequency);
    }
    void pluck(int course, float position, int velocity) {
        started = true;
        mandolins[course].pluck((float)velocity/127.0, position);
    }
    void mute(int course) {
        // How to stop?
    }
    
    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case detuneAddress:
                detuneRamper.setUIValue(clamp(value, 0.0f, 10.0f));
                break;

            case bodySizeAddress:
                bodySizeRamper.setUIValue(clamp(value, 0.0f, 3.0f));
                break;
        }
    }
    
    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case detuneAddress:
                return detuneRamper.getUIValue();
                
            case bodySizeAddress:
                return bodySizeRamper.getUIValue();

            default: return 0.0f;
        }
    }
    
    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
            case detuneAddress:
                detuneRamper.startRamp(clamp(value, 0.0f, 10.0f), duration);
                break;
                
            case bodySizeAddress:
                bodySizeRamper.startRamp(clamp(value, 0.0f, 3.0f), duration);
                break;
        }
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        
        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            
            int frameOffset = int(frameIndex + bufferOffset);
            
            detune = detuneRamper.getAndStep();
            bodySize = bodySizeRamper.getAndStep();

            for (auto & mandolin : mandolins) {
              mandolin.setDetune(detune);
              mandolin.setBodySize(1 / bodySize);
            }

            for (int channel = 0; channel < channels; ++channel) {
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;
                if (started) {
                    *out = mandolins[0].tick();
                    *out += mandolins[1].tick();
                    *out += mandolins[2].tick();
                    *out += mandolins[3].tick();
                } else {
                    *out = 0.0;
                }
            }
        }
    }
    
    // MARK: Member Variables
    
private:
  //    float internalTrigger = 0;

    stk::Mandolin mandolins[4] = { stk::Mandolin(100),
                                   stk::Mandolin(100),
                                   stk::Mandolin(100),
                                   stk::Mandolin(100) };
    float detune = 1;
    float bodySize = 1;
    
public:
    bool started = false;
    bool resetted = false;
    
    ParameterRamper detuneRamper = 1;
    ParameterRamper bodySizeRamper = 1;
};


