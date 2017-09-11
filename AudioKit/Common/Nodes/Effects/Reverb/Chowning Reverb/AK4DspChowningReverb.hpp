//
//  AKChowningReverbDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

#pragma once

#import "AK4DspSoundPipe.hpp"

class AK4DspChowningReverb : public AK4DspSoundpipeBase {

    sp_jcrev *jcrev0;
    sp_jcrev *jcrev1;

public:
// MARK: Member Functions

    AK4DspChowningReverb() {}

    void init(int _channels, double _sampleRate) override {
        AK4DspSoundpipeBase::init(_channels, _sampleRate);
        sp_jcrev_create(&jcrev0);
        sp_jcrev_init(sp, jcrev0);
        sp_jcrev_create(&jcrev1);
        sp_jcrev_init(sp, jcrev1);
    }

    void destroy() {
        sp_jcrev_destroy(&jcrev0);
        sp_jcrev_destroy(&jcrev1);
        AK4DspSoundpipeBase::destroy();
    }
    
    void processSample(int channel, float* in, float* out) override {
        if (channel == 0) {
            sp_jcrev_compute(sp, jcrev0, in, out);
        } else {
            sp_jcrev_compute(sp, jcrev1, in, out);
        }
    }

};

