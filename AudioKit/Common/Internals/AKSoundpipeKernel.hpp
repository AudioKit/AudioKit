//
//  AKSoundpipeKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on GitHub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#ifdef __cplusplus
#pragma once

extern "C" {
#include "soundpipe.h"
#include "soundpipeextension.h"
}

#import "AKDSPKernel.hpp"

class AKSoundpipeKernel: public AKDSPKernel {
protected:
    sp_data *sp = nullptr;
public:
    sp_data *getSpData() { return sp; }

    // The default constructor should be deleted,
    // but we're keeping it to not break the API
    AKSoundpipeKernel() = default;

    AKSoundpipeKernel(int channelCount, double sampleRate) :
        AKDSPKernel(channelCount, sampleRate) {
        sp_create(&sp);
        sp->sr = sampleRate;
        sp->nchan = channelCount;
    }
    
    void init(int channelCount, double sampleRate) override {
        AKDSPKernel::init(channelCount, sampleRate);
        if (sp == nullptr) {
            sp_create(&sp);
        }
        sp->sr = sampleRate;
        sp->nchan = channelCount;
    }

    ~AKSoundpipeKernel() {
        //printf("~AKSoundpipeKernel(), &sp is %p\n", (void *)sp);
        // releasing the memory in the destructor only
        sp_destroy(&sp);
    }

    void destroy() {
        //printf("AKSoundpipeKernel.destroy(), &sp is %p\n", (void *)sp);
    }
};

#endif

