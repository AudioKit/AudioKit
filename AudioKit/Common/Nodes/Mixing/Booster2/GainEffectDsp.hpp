//
//  GainEffectDsp.hpp
//  AudioKit
//
//  Created by Andrew Voelkel on 9/23/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

#pragma once

#import <Foundation/Foundation.h>

typedef NS_ENUM(int64_t, GainEffectParam) {
    GainEffectParamGain,
    GainEffectParamRampTime
};

#ifndef __cplusplus

void* createGainEffectDsp(int nChannels, double sampleRate);

#else

#import <AudioToolbox/AudioToolbox.h>
#import <AudioUnit/AudioUnit.h>
#import <AVFoundation/AVFoundation.h>
#import "AK4LinearParamRamp.hpp"

/**
 A butt simple DSP kernel. Most of the plumbing is in the base class. All the code at this
 level has to do is supply the core of the rendering code. A less trivial example would probably
 need to coordinate the updating of DSP parameters, which would probably involve thread locks,
 etc.
 */

struct AK4GainEffectDsp : AK4DspBase {
    
private:
    AK4LinearParamRamp gainRamp;
    
public:
    
    AK4GainEffectDsp() {
        gainRamp.setTarget(1.0, 0);
        gainRamp.setDurationInSamples(10000);
    }
    
    /** Uses the ParameterAddress as a key */
    void setParameter(uint64_t address, float value) override {
        switch (address) {
            case GainEffectParamGain:
                gainRamp.setTarget(value, _now);
                break;
            case GainEffectParamRampTime:
                gainRamp.setRampTime(value, _sampleRate);
                break;
        }
    }
    
    /** Uses the ParameterAddress as a key */
    float getParameter(uint64_t address) override {
        switch (address) {
            case GainEffectParamGain:
                return gainRamp.getTarget();
            case GainEffectParamRampTime:
                return gainRamp.getRampTime(_sampleRate);
        }
        return 0;
    }
    
    // Largely lifted from the example code, though this is simpler since the Apple code
    // implements a time varying filter
    
    void process(uint32_t frameCount, uint32_t bufferOffset) override {
        
        // For each sample.
        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);
            // do gain ramping every 8 samples
            if ((frameOffset & 0x7) == 0) {
                gainRamp.advanceTo(_now + frameOffset);
            }
            // do actual signal processing
            // After all this scaffolding, the only thing we are doing is scaling the input
            for (int channel = 0; channel < _nChannels; ++channel) {
                float* in  = (float*)_inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                float* out = (float*)_outBufferListPtr->mBuffers[channel].mData + frameOffset;
                *out = gainRamp.getValue() * *in;
            }
        }
    }
    
};

#endif




