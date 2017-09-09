//
//  SimpleAU.h
//  TryAVAudioEngine
//
//  Created by Andrew Voelkel on 8/29/17.
//  Copyright © 2017 Andrew Voelkel. All rights reserved.
//

#pragma once

#include "AudioUnitBase.h"

@interface GainAudioUnit : AudioUnitBase

@property float gain;

@end

#ifdef __cplusplus 

#import <AudioToolbox/AudioToolbox.h>
#import <AudioUnit/AudioUnit.h>
#import <AVFoundation/AVFoundation.h>

/**
 A butt simple DSP kernel. Most of the plumbing is in the base class. All the code at this
 level has to do is supply the core of the rendering code. A less trivial example would probably
 need to coordinate the updating of DSP parameters, which would probably involve thread locks,
 etc.
 */

struct DspGainEffect : DspBase {
    
private:
    
    double Gain = 1.0;
    
public:
    
    // Largely lifted from the example code, though this is simpler since the Apple code
    // implements a time varying filter
    
    void process(uint32_t frameCount, uint32_t bufferOffset) override {
        
        // For each sample.
        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);
            for (int channel = 0; channel < nChannels; ++channel) {
                float* in  = (float*)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                float* out = (float*)outBufferListPtr->mBuffers[channel].mData + frameOffset;
                // After all this scaffolding, the only thing we are doing is scaling the input
                *out = Gain * *in;
                
            }
        }
    }
};

#endif




