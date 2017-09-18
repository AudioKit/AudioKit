//
//  SimpleAU.h
//  TryAVAudioEngine
//
//  Created by Andrew Voelkel on 8/29/17.
//  Copyright © 2017 Andrew Voelkel. All rights reserved.
//

#pragma once

#include "AK4AudioUnitBase.h"

@interface GainAudioUnit : AK4AudioUnitBase

@property float gain;

@end

#ifdef __cplusplus 

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

struct DspGainEffect : AK4DspBase {
    
private:
    
    const uint64_t kGainAddr = 0;
    AK4LinearParamRamp gainRamp;
    
public:
    
    DspGainEffect() { gainRamp.value = 1.0; }
    
    /** Uses the ParameterAddress as a key */
    void setParameter(uint64_t address, float value) override {
        if (address == kGainAddr) {
            gainRamp.setTarget(value, _now);
        }
    }
    
    /** Uses the ParameterAddress as a key */
    float getParameter(uint64_t address) override {
        if (address == kGainAddr) { return gainRamp.target; }
        else return 0;
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
                float* in  = (float*)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                float* out = (float*)outBufferListPtr->mBuffers[channel].mData + frameOffset;
                *out = gainRamp.value * *in;
            }
        }
    }
};

#endif




