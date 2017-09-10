//
//  AKSoundPipeKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka on 7/1/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

#pragma once

#import "AK4DspBase.hpp"

extern "C" {
#include "soundpipe.h"
}

class AK4DspSoundpipeBase: public AK4DspBase {
protected:
    sp_data *sp = nullptr;
public:
    
    void init(int _channels, double _sampleRate) override {
        AK4DspBase::init(_channels, _sampleRate);
        sp_create(&sp);
        sp->sr = _sampleRate;
        sp->nchan = _channels;
    }
    
    ~AK4DspSoundpipeBase() {
        //printf("~AKSoundpipeKernel(), &sp is %p\n", (void *)sp);
        // releasing the memory in the destructor only
        sp_destroy(&sp);
    }
    
    void destroy() {
        //printf("AKSoundpipeKernel.destroy(), &sp is %p\n", (void *)sp);
    }
};
