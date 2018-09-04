//
//  AKPannerDSP.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKPannerParameter) {
    AKPannerParameterPan,
    AKPannerParameterRampDuration
};

#import "AKLinearParameterRamp.hpp"  // have to put this here to get it included in umbrella header

#ifndef __cplusplus

void *createPannerDSP(int nChannels, double sampleRate);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKPannerDSP : public AKSoundpipeDSPBase {

    sp_panst *_panst;


private:
    AKLinearParameterRamp panRamp;
   
public:
    AKPannerDSP() {
        panRamp.setTarget(0, true);
        panRamp.setDurationInSamples(10000);
    }

    /** Uses the ParameterAddress as a key */
    void setParameter(AUParameterAddress address, float value, bool immediate) override {
        switch (address) {
            case AKPannerParameterPan:
                panRamp.setTarget(value, immediate);
                break;
            case AKPannerParameterRampDuration:
                panRamp.setRampDuration(value, _sampleRate);
                break;
        }
    }

    /** Uses the ParameterAddress as a key */
    float getParameter(AUParameterAddress address) override {
        switch (address) {
            case AKPannerParameterPan:
                return panRamp.getTarget();
            case AKPannerParameterRampDuration:
                return panRamp.getRampDuration(_sampleRate);
        }
        return 0;
    }

    void init(int _channels, double _sampleRate) override {
        AKSoundpipeDSPBase::init(_channels, _sampleRate);
        sp_panst_create(&_panst);
        sp_panst_init(_sp, _panst);
        _panst->pan = 0;
    }

    void deinit() override {
        sp_panst_destroy(&_panst);
    }

    void process(uint32_t frameCount, uint32_t bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            // do ramping every 8 samples
            if ((frameOffset & 0x7) == 0) {
                panRamp.advanceTo(_now + frameOffset);
            }
            _panst->pan = panRamp.getValue();

            float *tmpin[2];
            float *tmpout[2];
            for (int channel = 0; channel < _nChannels; ++channel) {
                float *in  = (float *)_inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)_outBufferListPtr->mBuffers[channel].mData + frameOffset;

                if (channel < 2) {
                    tmpin[channel] = in;
                    tmpout[channel] = out;
                }
                if (!_playing) {
                    *out = *in;
                }
            }
            if (_playing) {
                sp_panst_compute(_sp, _panst, tmpin[0], tmpin[1], tmpout[0], tmpout[1]);
            }
        }
    }
};

#endif
