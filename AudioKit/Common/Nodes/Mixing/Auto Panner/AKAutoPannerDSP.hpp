//
//  AKAutoPannerDSP.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKAutoPannerParameter) {
    AKAutoPannerParameterFrequency,
    AKAutoPannerParameterDepth,
    AKAutoPannerParameterRampDuration
};

#import "AKLinearParameterRamp.hpp"  // have to put this here to get it included in umbrella header

#ifndef __cplusplus

AKDSPRef createAutoPannerDSP(int channelCount, double sampleRate);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKAutoPannerDSP : public AKSoundpipeDSPBase {

    sp_osc *trem;
    sp_ftbl *tbl;
    sp_panst *panst;
    UInt32 tbl_size = 4096;

private:
    AKLinearParameterRamp frequencyRamp;
    AKLinearParameterRamp depthRamp;
   
public:
    AKAutoPannerDSP() {
        frequencyRamp.setTarget(10.0, true);
        frequencyRamp.setDurationInSamples(10000);
        depthRamp.setTarget(1.0, true);
        depthRamp.setDurationInSamples(10000);
    }

    /** Uses the ParameterAddress as a key */
    void setParameter(AUParameterAddress address, float value, bool immediate) override {
        switch (address) {
            case AKAutoPannerParameterFrequency:
                frequencyRamp.setTarget(value, immediate);
                break;
            case AKAutoPannerParameterDepth:
                depthRamp.setTarget(value, immediate);
                break;
            case AKAutoPannerParameterRampDuration:
                frequencyRamp.setRampDuration(value, sampleRate);
                depthRamp.setRampDuration(value, sampleRate);
                break;
        }
    }

    /** Uses the ParameterAddress as a key */
    float getParameter(AUParameterAddress address) override {
        switch (address) {
            case AKAutoPannerParameterFrequency:
                return frequencyRamp.getTarget();
            case AKAutoPannerParameterDepth:
                return depthRamp.getTarget();
            case AKAutoPannerParameterRampDuration:
                return frequencyRamp.getRampDuration(sampleRate);
                return depthRamp.getRampDuration(sampleRate);
        }
        return 0;
    }

    void init(int channelCount, double sampleRate) override {
        AKSoundpipeDSPBase::init(channelCount, sampleRate);
        sp_osc_create(&trem);
        sp_osc_init(sp, trem, tbl, 0);
        trem->freq = 10.0;
        trem->amp = 1.0;
        sp_panst_create(&panst);
        sp_panst_init(sp, panst);
        panst->pan = 0;
    }

    void setupWaveform(uint32_t size) override {
        tbl_size = size;
        sp_ftbl_create(sp, &tbl, tbl_size);
    }

    void setWaveformValue(uint32_t index, float value) override {
        tbl->tbl[index] = value;
    }

    void deinit() override {
        sp_osc_destroy(&trem);
        sp_panst_destroy(&panst);
    }

    void process(uint32_t frameCount, uint32_t bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            // do ramping every 8 samples
            if ((frameOffset & 0x7) == 0) {
                frequencyRamp.advanceTo(now + frameOffset);
                depthRamp.advanceTo(now + frameOffset);
            }
            trem->freq = frequencyRamp.getValue();
            trem->amp = 1;

            float temp = 0;
            float *tmpin[2];
            float *tmpout[2];
            for (int channel = 0; channel < channelCount; ++channel) {
                float *in  = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;

                if (channel < 2) {
                    tmpin[channel] = in;
                    tmpout[channel] = out;
                }
                if (!isStarted) {
                    *out = *in;
                }
            }
            if (isStarted) {
                sp_osc_compute(sp, trem, NULL, &temp);
                panst->pan = (2.0 * temp - 1.0) * depthRamp.getValue();
                sp_panst_compute(sp, panst, tmpin[0], tmpin[1], tmpout[0], tmpout[1]);
            }

        }
    }
};

#endif
