// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#ifdef __cplusplus
#pragma once

#include "soundpipe.h"

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
        // releasing the memory in the destructor only
        sp_destroy(&sp);
    }

    void destroy() {
        //printf("AKSoundpipeKernel.destroy(), &sp is %p\n", (void *)sp);
    }
};

#endif

