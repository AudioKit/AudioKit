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
}

#import "AKDSPKernel.hpp"

class AKSoundpipeKernel: public AKDSPKernel {
protected:
    sp_data *sp = nullptr;
public:
    //    AKSoundpipeKernel(int _channels, float _sampleRate):
    //        AKDSPKernel(_channels, _sampleRate) {
    //
    //      sp_create(&sp);
    //      sp->sr = _sampleRate;
    //      sp->nchan = _channels;
    //    }

    void init(int _channels, double _sampleRate) override {
        AKDSPKernel::init(_channels, _sampleRate);
        sp_create(&sp);
        sp->sr = _sampleRate;
        sp->nchan = _channels;
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

