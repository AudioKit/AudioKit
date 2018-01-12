//
//  AKBitCrusherDSP.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import <Foundation/Foundation.h>

typedef NS_ENUM(int64_t, AKBitCrusherParameter) {
    AKBitCrusherParameterBitDepth,
    AKBitCrusherParameterSampleRate,
    AKBitCrusherParameterRampTime
};

#import "AKLinearParameterRamp.hpp"  // have to put this here to get it included in umbrella header

#ifndef __cplusplus

void* createBitCrusherDSP(int nChannels, double sampleRate);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKBitCrusherDSP : public AKSoundpipeDSPBase {

    sp_bitcrush *_bitcrush0;
    sp_bitcrush *_bitcrush1;

private:
    AKLinearParameterRamp bitDepthRamp;
    AKLinearParameterRamp sampleRateRamp;
   
public:
    AKBitCrusherDSP() {
        bitDepthRamp.setTarget(8, true);
        bitDepthRamp.setDurationInSamples(10000);
        sampleRateRamp.setTarget(10000, true);
        sampleRateRamp.setDurationInSamples(10000);
    }

    /** Uses the ParameterAddress as a key */
    void setParameter(uint64_t address, float value, bool immediate) override {
        switch (address) {
            case AKBitCrusherParameterBitDepth:
                bitDepthRamp.setTarget(value, immediate);
                break;
            case AKBitCrusherParameterSampleRate:
                sampleRateRamp.setTarget(value, immediate);
                break;
            case AKBitCrusherParameterRampTime:
                bitDepthRamp.setRampTime(value, _sampleRate);
                sampleRateRamp.setRampTime(value, _sampleRate);
                break;
        }
    }

    /** Uses the ParameterAddress as a key */
    float getParameter(uint64_t address) override {
        switch (address) {
            case AKBitCrusherParameterBitDepth:
                return bitDepthRamp.getTarget();
            case AKBitCrusherParameterSampleRate:
                return sampleRateRamp.getTarget();
            case AKBitCrusherParameterRampTime:
                return bitDepthRamp.getRampTime(_sampleRate);
        }
        return 0;
    }

    void init(int _channels, double _sampleRate) override {
        AKSoundpipeDSPBase::init(_channels, _sampleRate);
        sp_bitcrush_create(&_bitcrush0);
        sp_bitcrush_create(&_bitcrush1);
        sp_bitcrush_init(_sp, _bitcrush0);
        sp_bitcrush_init(_sp, _bitcrush1);
        _bitcrush0->bitdepth = 8;
        _bitcrush1->bitdepth = 8;
        _bitcrush0->srate = 10000;
        _bitcrush1->srate = 10000;
    }

    void destroy() {
        sp_bitcrush_destroy(&_bitcrush0);
        sp_bitcrush_destroy(&_bitcrush1);
        AKSoundpipeDSPBase::destroy();
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            // do gain ramping every 8 samples
            if ((frameOffset & 0x7) == 0) {
                bitDepthRamp.advanceTo(_now + frameOffset);
                sampleRateRamp.advanceTo(_now + frameOffset);
            }
            _bitcrush0->bitdepth = bitDepthRamp.getValue();
            _bitcrush1->bitdepth = bitDepthRamp.getValue();            
            _bitcrush0->srate = sampleRateRamp.getValue();
            _bitcrush1->srate = sampleRateRamp.getValue();            

            float *tmpin[2];
            float *tmpout[2];
            for (int channel = 0; channel < _nChannels; ++channel) {
                float* in  = (float*)_inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                float* out = (float*)_outBufferListPtr->mBuffers[channel].mData + frameOffset;

                if (channel < 2) {
                    tmpin[channel] = in;
                    tmpout[channel] = out;
                }
                if (!_playing) {
                    *out = *in;
                }
                if (channel == 0) {
                    sp_bitcrush_compute(_sp, _bitcrush0, in, out);
                } else {
                    sp_bitcrush_compute(_sp, _bitcrush1, in, out);
                }
            }
            if (_playing) {
            }
        }
    }
};

#endif
