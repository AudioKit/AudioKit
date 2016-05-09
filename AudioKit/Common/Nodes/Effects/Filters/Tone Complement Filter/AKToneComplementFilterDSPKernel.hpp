//
//  AKToneComplementFilterDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKToneComplementFilterDSPKernel_hpp
#define AKToneComplementFilterDSPKernel_hpp

#import "DSPKernel.hpp"
#import "ParameterRamper.hpp"

#import <AudioKit/AudioKit-Swift.h>

extern "C" {
#include "soundpipe.h"
}

enum {
    halfPowerPointAddress = 0
};

class AKToneComplementFilterDSPKernel : public DSPKernel {
public:
    // MARK: Member Functions

    AKToneComplementFilterDSPKernel() {}

    void init(int channelCount, double inSampleRate) {
        channels = channelCount;

        sampleRate = float(inSampleRate);

        sp_create(&sp);
        sp->sr = sampleRate;
        sp->nchan = channels;
        sp_atone_create(&atone);
        sp_atone_init(sp, atone);
        atone->hp = 1000;
    }

    void start() {
        started = true;
    }

    void stop() {
        started = false;
    }

    void destroy() {
        sp_atone_destroy(&atone);
        sp_destroy(&sp);
    }

    void reset() {
        resetted = true;
    }

    void setHalfPowerPoint(float hp) {
        halfPowerPoint = hp;
        halfPowerPointRamper.setImmediate(hp);
    }


    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case halfPowerPointAddress:
                halfPowerPointRamper.setUIValue(clamp(value, (float)12.0, (float)20000.0));
                break;

        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case halfPowerPointAddress:
                return halfPowerPointRamper.getUIValue();

            default: return 0.0f;
        }
    }

    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
            case halfPowerPointAddress:
                halfPowerPointRamper.startRamp(clamp(value, (float)12.0, (float)20000.0), duration);
                break;

        }
    }

    void setBuffers(AudioBufferList *inBufferList, AudioBufferList *outBufferList) {
        inBufferListPtr = inBufferList;
        outBufferListPtr = outBufferList;
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        
        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            
            int frameOffset = int(frameIndex + bufferOffset);

            halfPowerPoint = halfPowerPointRamper.getAndStep();
            atone->hp = (float)halfPowerPoint;

            for (int channel = 0; channel < channels; ++channel) {
                
                float *in  = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;
                
                if (started) {
                    sp_atone_compute(sp, atone, in, out);
                } else {
                    *out = *in;
                }
            }
        }
    }

    // MARK: Member Variables

private:

    int channels = AKSettings.numberOfChannels;
    float sampleRate = AKSettings.sampleRate;

    AudioBufferList *inBufferListPtr = nullptr;
    AudioBufferList *outBufferListPtr = nullptr;

    sp_data *sp;
    sp_atone *atone;

    float halfPowerPoint = 1000;

public:
    bool started = true;
    bool resetted = false;
    ParameterRamper halfPowerPointRamper = 1000;
};

#endif /* AKToneComplementFilterDSPKernel_hpp */
