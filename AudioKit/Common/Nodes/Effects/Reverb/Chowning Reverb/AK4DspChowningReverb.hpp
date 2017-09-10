//
//  AKChowningReverbDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

#pragma once

#import "AK4DspSoundPipe.hpp"
#import "AKDSPKernel.hpp"   // TMP KLUDGE

class AK4DspChowningReverb : public AK4DspSoundpipeBase /* , public AKBuffered */ {

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

    void start() override { _playing = true; }
    void stop() override { _playing = false; }
    void reset() override {}

    void destroy() {
        sp_jcrev_destroy(&jcrev0);
        sp_jcrev_destroy(&jcrev1);
        AK4DspSoundpipeBase::destroy();
    }

    void setParameter(AUParameterAddress address, AUValue value) override {}
    AUValue getParameter(AUParameterAddress address) override { return 0.0f; }

    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) {}

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);
            for (int channel = 0; channel <  nChannels; ++channel) {
                float *in  = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;
                
                if (started) {
                    if (channel == 0) {
                        sp_jcrev_compute(sp, jcrev0, in, out);
                    } else {
                        sp_jcrev_compute(sp, jcrev1, in, out);
                    }
                } else {
                    *out = *in;
                }
            }
        }
    }

// MARK: Member Variables


public:
    bool started = true;
    bool resetted = true;
};

