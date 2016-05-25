//
//  AKOperationGeneratorDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#ifndef AKOperationGeneratorDSPKernel_hpp
#define AKOperationGeneratorDSPKernel_hpp

#import "DSPKernel.hpp"
#import "ParameterRamper.hpp"

#import <AudioKit/AudioKit-Swift.h>

extern "C" {
#include "plumber.h"
}


class AKOperationGeneratorDSPKernel : public DSPKernel {
public:
    // MARK: Member Functions

    AKOperationGeneratorDSPKernel() {}

    void init(int channelCount, double inSampleRate) {
        channels = channelCount;

        sampleRate = float(inSampleRate);

        sp_create(&sp);
        sp->sr = sampleRate;
        sp->nchan = channels;
        plumber_register(&pd);
        plumber_init(&pd);
        pd.sp = sp;
        if (sporthCode != nil) {
            plumber_parse_string(&pd, sporthCode);
            plumber_compute(&pd, PLUMBER_INIT);
        }
        
    }
    
    void setSporth(char *sporth) {
        sporthCode = sporth;
    }
    
    void trigger(float params[]) {
        internalTrigger = 1;
        pd.p[0] = internalTrigger;
        pd.p[1] = internalTrigger;
        setParameters(params);
    }
    
    void setParameters(float params[]) {
        for (int i = 0; i < 10; i++) {
            parameters[i] = params[i];
        }
    };
    
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

    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            default: return 0.0f;
        }
    }

    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
        }
    }

    void setBuffer(AudioBufferList *outBufferList) {
        outBufferListPtr = outBufferList;
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {

            int frameOffset = int(frameIndex + bufferOffset);
            
            pd.p[0] = internalTrigger;
            pd.p[1] = internalTrigger;
            for (int i = 0; i < 10; i++) {
                pd.p[i+2] = parameters[i];
            }
            if (started) {
                plumber_compute(&pd, PLUMBER_COMPUTE);
            }

            for (int channel = 0; channel < channels; ++channel) {
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;
                if (started) {
                    *out = sporth_stack_pop_float(&pd.sporth.stack);
                } else {
                    *out = 0;
                }
            }
        }
        if (internalTrigger == 1) {
            internalTrigger = 0;
        }
    }

    // MARK: Member Variables

private:

    int channels = AKSettings.numberOfChannels;
    float sampleRate = AKSettings.sampleRate;
    int internalTrigger = 0;
    float parameters[10] = {0,0,0,0,0,0,0,0,0,0};

    AudioBufferList *outBufferListPtr = nullptr;

    sp_data *sp;
    plumber_data pd;
    char *sporthCode = nil;
    
public:
    bool started = false;
};

#endif /* AKOperationGeneratorDSPKernel_hpp */
