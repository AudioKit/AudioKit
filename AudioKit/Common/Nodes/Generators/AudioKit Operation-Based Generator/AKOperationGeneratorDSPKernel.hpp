//
//  AKOperationGeneratorDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#pragma once

#import "DSPKernel.hpp"
#import "ParameterRamper.hpp"

#import <AudioKit/AudioKit-Swift.h>

extern "C" {
#include "plumber.h"
}


class AKOperationGeneratorDSPKernel : public AKDSPKernel {
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
        plumber_recompile_string(&pd, sporthCode);
    }
    
    void trigger(int trigger) {
        internalTriggers[trigger] = 1;
    }
    
    void setParameters(float params[]) {
        for (int i = 0; i < 14; i++) {
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

            
            for (int i = 0; i < 14; i++) {
                if (internalTriggers[i] == 1) {
                    pd.p[i] = 1.0;
                } else {
                    pd.p[i] = parameters[i];
                }
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
        
        for (int i = 0; i < 14; i++) {
            if (internalTriggers[i] == 1) {
                pd.p[i] = 0.0;
            }
            parameters[i] = pd.p[i];
            internalTriggers[i] = 0;
        }
    }

    // MARK: Member Variables

private:

    int internalTriggers[14] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0};

    AudioBufferList *outBufferListPtr = nullptr;

    sp_data *sp;
    plumber_data pd;
    char *sporthCode = nil;
    
public:
    float parameters[14] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0};
    bool started = false;
};

