//
//  AKTremoloDSP.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKTremoloParameter) {
    AKTremoloParameterFrequency,
    AKTremoloParameterDepth,
    AKTremoloParameterRampDuration
};

#import "AKLinearParameterRamp.hpp"  // have to put this here to get it included in umbrella header

#ifndef __cplusplus

void *createTremoloDSP(int nChannels, double sampleRate);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKTremoloDSP : public AKSoundpipeDSPBase {

    sp_osc *_trem;
    sp_ftbl *_tbl;
    UInt32 _tbl_size = 4096;

private:
    AKLinearParameterRamp frequencyRamp;
    AKLinearParameterRamp depthRamp;
   
public:
    AKTremoloDSP() {
        frequencyRamp.setTarget(10.0, true);
        frequencyRamp.setDurationInSamples(10000);
        depthRamp.setTarget(1.0, true);
        depthRamp.setDurationInSamples(10000);
    }

    /** Uses the ParameterAddress as a key */
    void setParameter(AUParameterAddress address, float value, bool immediate) override {
        switch (address) {
            case AKTremoloParameterFrequency:
                frequencyRamp.setTarget(value, immediate);
                break;
            case AKTremoloParameterDepth:
                depthRamp.setTarget(value, immediate);
                break;
            case AKTremoloParameterRampDuration:
                frequencyRamp.setRampDuration(value, _sampleRate);
                depthRamp.setRampDuration(value, _sampleRate);
                break;
        }
    }

    /** Uses the ParameterAddress as a key */
    float getParameter(AUParameterAddress address) override {
        switch (address) {
            case AKTremoloParameterFrequency:
                return frequencyRamp.getTarget();
            case AKTremoloParameterDepth:
                return depthRamp.getTarget();
            case AKTremoloParameterRampDuration:
                return frequencyRamp.getRampDuration(_sampleRate);
                return depthRamp.getRampDuration(_sampleRate);
        }
        return 0;
    }

    void init(int _channels, double _sampleRate) override {
        AKSoundpipeDSPBase::init(_channels, _sampleRate);
        sp_osc_create(&_trem);
        sp_osc_init(_sp, _trem, _tbl, 0);
        _trem->freq = 10.0;
        _trem->amp = 1.0;
    }

    void setupWaveform(uint32_t size) override {
        _tbl_size = size;
        sp_ftbl_create(_sp, &_tbl, _tbl_size);
    }

    void setWaveformValue(uint32_t index, float value) override {
        _tbl->tbl[index] = value;
    }

    void deinit() override {
        sp_osc_destroy(&_trem);
    }

    void process(uint32_t frameCount, uint32_t bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            // do ramping every 8 samples
            if ((frameOffset & 0x7) == 0) {
                frequencyRamp.advanceTo(_now + frameOffset);
                depthRamp.advanceTo(_now + frameOffset);
            }
            _trem->freq = frequencyRamp.getValue()  * 0.5; //Divide by two for stereo
            _trem->amp = depthRamp.getValue();

            float temp = 0;
            for (int channel = 0; channel < _nChannels; ++channel) {
                float *in  = (float *)_inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)_outBufferListPtr->mBuffers[channel].mData + frameOffset;

                if (_playing) {
                    sp_osc_compute(_sp, _trem, NULL, &temp);
                    *out = *in * (1.0 - temp);
                } else {
                    *out = *in;
                }
            }
        }
    }
};

#endif
