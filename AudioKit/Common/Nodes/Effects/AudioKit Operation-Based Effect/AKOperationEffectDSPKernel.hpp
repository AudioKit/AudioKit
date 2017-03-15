//
//  AKOperationEffectDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

#pragma once

#import <vector>

#import "DSPKernel.hpp"
#import "ParameterRamper.hpp"

#import <AudioKit/AudioKit-Swift.h>

extern "C" {
#include "plumber.h"

typedef struct CustomUgenInfo {
    const char *name;
    plumber_dyn_func fp;
    void *userData;
} CustomUgenInfo;
}

class AKOperationEffectDSPKernel : public AKSoundpipeKernel, public AKBuffered {
public:
    // MARK: Member Functions

    AKOperationEffectDSPKernel() {}

    void init(int _channels, double _sampleRate) override {
        AKSoundpipeKernel::init(_channels, _sampleRate);

        plumber_register(&pd);
        plumber_init(&pd);

        for (auto info : customUgens) {
          plumber_ftmap_add_function(&pd, info.name, info.fp, info.userData);
        }

        pd.sp = sp;
        if (sporthCode != nil) {
            plumber_parse_string(&pd, sporthCode);
            plumber_compute(&pd, PLUMBER_INIT);
        }
        
    }
    
    void setSporth(char *sporth) {
        sporthCode = sporth;
    }
    
    void setParameters(float params[]) {
        for (int i = 0; i < 14; i++) {
            parameters[i] = params[i];
        }
    };

    void addCustomUgen(CustomUgenInfo info) {
        customUgens.push_back(info);
    }

    void start() {
        started = true;
    }
    
    void stop() {
        started = false;
    }

    void destroy() {
        plumber_clean(&pd);
        AKSoundpipeKernel::destroy();
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

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        
        if (!started) {
            outBufferListPtr->mBuffers[0] = inBufferListPtr->mBuffers[0];
            outBufferListPtr->mBuffers[1] = inBufferListPtr->mBuffers[1];
            return;
        }

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {

            int frameOffset = int(frameIndex + bufferOffset);
            
            for (int channel = 0; channel < channels; ++channel) {
                float *in  = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                if (channel < 2) {
                    pd.p[channel+14] = *in;
                }
            }
            
            for (int i = 0; i < 14; i++) {
                pd.p[i] = parameters[i];
            }
            
            plumber_compute(&pd, PLUMBER_COMPUTE);

            for (int channel = 0; channel < channels; ++channel) {
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;
                *out = sporth_stack_pop_float(&pd.sporth.stack);
            }
            
            for (int i = 0; i < 14; i++) {
                parameters[i] = pd.p[i];
            }
        }
    }

    // MARK: Member Variables

private:

    plumber_data pd;
    char *sporthCode = nil;
    std::vector<CustomUgenInfo> customUgens;
public:
    float parameters[14] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0};
    bool started = true;
};

