//
//  AKSoundPipeKernel.hpp
//  AudioKit For macOS
//
//  Created by Aurelius Prochazka on 7/1/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

#pragma once

#import "AKDSPKernel.hpp"

extern "C" {
#include "soundpipe.h"
}

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
