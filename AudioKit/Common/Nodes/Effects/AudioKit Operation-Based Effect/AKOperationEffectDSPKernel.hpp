//
//  AKOperationEffectDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import <vector>

#import "AKSoundpipeKernel.hpp"
#import "ParameterRamper.hpp"

#import <AudioKit/AudioKit-Swift.h>

extern "C" {
#include "plumber.h"
}

#import "AKCustomUgenInfo.h"

class AKOperationEffectDSPKernel : public AKSoundpipeKernel, public AKBuffered {
public:
    // MARK: Member Functions

    AKOperationEffectDSPKernel() {}

    void init(int _channels, double _sampleRate) override {
        AKSoundpipeKernel::init(_channels, _sampleRate);
        plumber_register(&pd);
        plumber_init(&pd);

        for (auto info : customUgens) {
            plumber_ftmap_add_function(&pd, info.name, info.func, info.userData);
        }

        pd.sp = sp;
        if (sporthCode != nil) {
            plumber_parse_string(&pd, sporthCode);
            plumber_compute(&pd, PLUMBER_INIT);
        }

    }

    void setSporth(char *sporth, int length) {
        if (sporthCode) {
            free(sporthCode);
            sporthCode = NULL;
        }
        if (length) {
            sporthCode = (char *)malloc(length);
            memcpy(sporthCode, sporth, length);
        }
    }

    void setParameters(float params[]) {
        for (int i = 0; i < 14; i++) {
            parameters[i] = params[i];
        }
    };

    void addCustomUgen(AKCustomUgenInfo info) {
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
    std::vector<AKCustomUgenInfo> customUgens;
public:
    float parameters[14] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0};
    bool started = true;
};

