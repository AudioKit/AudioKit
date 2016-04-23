//
//  AKVariableDelayDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKVariableDelayDSPKernel_hpp
#define AKVariableDelayDSPKernel_hpp

#import "AKDSPKernel.hpp"
#import "AKParameterRamper.hpp"

#import <AudioKit/AudioKit-Swift.h>

extern "C" {
#include "plumber.h"
}

enum {
    timeAddress = 0,
    feedbackAddress = 1
};

class AKVariableDelayDSPKernel : public AKDSPKernel {
public:
    // MARK: Member Functions
    
    AKVariableDelayDSPKernel() {}
    
    void init(int channelCount, double inSampleRate) {
        channels = channelCount;
        
        sampleRate = float(inSampleRate);
        
        sp_create(&sp);
        sp->sr = sampleRate;
        sp->nchan = channels;
        plumber_register(&pd);
        plumber_init(&pd);
        pd.sp = sp;
        NSString *sporth = [NSString stringWithFormat:@"0 p 1 p 2 p %f vdelay dup", internalMaxDelay];
        char *sporthCode = (char *)[sporth UTF8String];
        plumber_parse_string(&pd, sporthCode);
        plumber_compute(&pd, PLUMBER_INIT);
    }
    
    void start() {
        started = true;
    }
    
    void stop() {
        started = false;
    }
    
    void destroy() {
        plumber_clean(&pd);
        sp_destroy(&sp);
    }
    
    void reset() {
    }
    void setMaxDelayTime(float duration) {
        internalMaxDelay = duration;
    }
    
    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case timeAddress:
                timeRamper.setUIValue(clamp(value, (float)0, (float)10));
                break;
                
            case feedbackAddress:
                feedbackRamper.setUIValue(clamp(value, (float)0, (float)1));
                break;
                
        }
    }
    
    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case timeAddress:
                return timeRamper.getUIValue();
                
            case feedbackAddress:
                return feedbackRamper.getUIValue();
                
            default: return 0.0f;
        }
    }
    
    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
            case timeAddress:
                timeRamper.startRamp(clamp(value, (float)0, (float)10), duration);
                break;
                
            case feedbackAddress:
                feedbackRamper.startRamp(clamp(value, (float)0, (float)1), duration);
                break;
                
        }
    }
    
    void setBuffers(AudioBufferList *inBufferList, AudioBufferList *outBufferList) {
        inBufferListPtr = inBufferList;
        outBufferListPtr = outBufferList;
    }
    
    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        // For each sample.
        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            double time = double(timeRamper.getAndStep());
            double feedback = double(feedbackRamper.getAndStep());
            
            int frameOffset = int(frameIndex + bufferOffset);
            
            if (!started) {
                outBufferListPtr->mBuffers[0] = inBufferListPtr->mBuffers[0];
                outBufferListPtr->mBuffers[1] = inBufferListPtr->mBuffers[1];
                return;
            }
            for (int channel = 0; channel < channels; ++channel) {
                float *in  = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                if (channel < 2) {
                    pd.p[channel] = *in;
                }
            }
            pd.p[1] = (float)feedback;
            pd.p[2] = (float)time;
            plumber_compute(&pd, PLUMBER_COMPUTE);
            
            for (int channel = 0; channel < channels; ++channel) {
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;
                *out = sporth_stack_pop_float(&pd.sporth.stack);
            }
        }
    }
    
    // MARK: Member Variables
    
private:
    
    int channels = AKSettings.numberOfChannels;
    float sampleRate = AKSettings.sampleRate;
    
    AudioBufferList *inBufferListPtr = nullptr;
    AudioBufferList *outBufferListPtr = nullptr;
    
    sp_data *sp;
    plumber_data pd;
    
    float internalMaxDelay = 5.0;
    
public:
    bool started = true;
    AKParameterRamper timeRamper = 1;
    AKParameterRamper feedbackRamper = 0;
};

#endif /* AKVariableDelayDSPKernel_hpp */