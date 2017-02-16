//
//  AKOperationGeneratorDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

#pragma once

#import "DSPKernel.hpp"
#import "ParameterRamper.hpp"

#import <AudioKit/AudioKit-Swift.h>

extern "C" {
#include "plumber.h"
}


class AKOperationGeneratorDSPKernel : public AKSoundpipeKernel, public AKOutputBuffered {
public:
    // MARK: Member Functions

    AKOperationGeneratorDSPKernel() {}

    void init(int _channels, double _sampleRate) override {
        AKSoundpipeKernel::init(_channels, _sampleRate);

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

    plumber_data pd;
    char *sporthCode = nil;
    
public:
    float parameters[14] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0};
    bool started = false;
};

