//
//  AKDynamicRangeCompressorDSP.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import <Foundation/Foundation.h>

typedef NS_ENUM(int64_t, AKDynamicRangeCompressorParameter) {
    AKDynamicRangeCompressorParameterRatio,
    AKDynamicRangeCompressorParameterThreshold,
    AKDynamicRangeCompressorParameterAttackTime,
    AKDynamicRangeCompressorParameterReleaseTime,
    AKDynamicRangeCompressorParameterRampTime
};

#import "AKLinearParameterRamp.hpp"  // have to put this here to get it included in umbrella header

#ifndef __cplusplus

void* createDynamicRangeCompressorDSP(int nChannels, double sampleRate);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKDynamicRangeCompressorDSP : public AKSoundpipeDSPBase {

    sp_compressor *_compressor0;
    sp_compressor *_compressor1;

private:
    AKLinearParameterRamp ratioRamp;
    AKLinearParameterRamp thresholdRamp;
    AKLinearParameterRamp attackTimeRamp;
    AKLinearParameterRamp releaseTimeRamp;
   
public:
    AKDynamicRangeCompressorDSP() {
        ratioRamp.setTarget(1, true);
        ratioRamp.setDurationInSamples(10000);
        thresholdRamp.setTarget(0.0, true);
        thresholdRamp.setDurationInSamples(10000);
        attackTimeRamp.setTarget(0.1, true);
        attackTimeRamp.setDurationInSamples(10000);
        releaseTimeRamp.setTarget(0.1, true);
        releaseTimeRamp.setDurationInSamples(10000);
    }

    /** Uses the ParameterAddress as a key */
    void setParameter(uint64_t address, float value, bool immediate) override {
        switch (address) {
            case AKDynamicRangeCompressorParameterRatio:
                ratioRamp.setTarget(value, immediate);
                break;
            case AKDynamicRangeCompressorParameterThreshold:
                thresholdRamp.setTarget(value, immediate);
                break;
            case AKDynamicRangeCompressorParameterAttackTime:
                attackTimeRamp.setTarget(value, immediate);
                break;
            case AKDynamicRangeCompressorParameterReleaseTime:
                releaseTimeRamp.setTarget(value, immediate);
                break;
            case AKDynamicRangeCompressorParameterRampTime:
                ratioRamp.setRampTime(value, _sampleRate);
                thresholdRamp.setRampTime(value, _sampleRate);
                attackTimeRamp.setRampTime(value, _sampleRate);
                releaseTimeRamp.setRampTime(value, _sampleRate);
                break;
        }
    }

    /** Uses the ParameterAddress as a key */
    float getParameter(uint64_t address) override {
        switch (address) {
            case AKDynamicRangeCompressorParameterRatio:
                return ratioRamp.getTarget();
            case AKDynamicRangeCompressorParameterThreshold:
                return thresholdRamp.getTarget();
            case AKDynamicRangeCompressorParameterAttackTime:
                return attackTimeRamp.getTarget();
            case AKDynamicRangeCompressorParameterReleaseTime:
                return releaseTimeRamp.getTarget();
            case AKDynamicRangeCompressorParameterRampTime:
                return ratioRamp.getRampTime(_sampleRate);
                return thresholdRamp.getRampTime(_sampleRate);
                return attackTimeRamp.getRampTime(_sampleRate);
                return releaseTimeRamp.getRampTime(_sampleRate);
        }
        return 0;
    }

    void init(int _channels, double _sampleRate) override {
        AKSoundpipeDSPBase::init(_channels, _sampleRate);
        sp_compressor_create(&_compressor0);
        sp_compressor_create(&_compressor1);
        sp_compressor_init(_sp, _compressor0);
        sp_compressor_init(_sp, _compressor1);
        *_compressor0->ratio = 1;
        *_compressor1->ratio = 1;
        *_compressor0->thresh = 0.0;
        *_compressor1->thresh = 0.0;
        *_compressor0->atk = 0.1;
        *_compressor1->atk = 0.1;
        *_compressor0->rel = 0.1;
        *_compressor1->rel = 0.1;
    }

    void destroy() {
        sp_compressor_destroy(&_compressor0);
        sp_compressor_destroy(&_compressor1);
        AKSoundpipeDSPBase::destroy();
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            // do gain ramping every 8 samples
            if ((frameOffset & 0x7) == 0) {
                ratioRamp.advanceTo(_now + frameOffset);
                thresholdRamp.advanceTo(_now + frameOffset);
                attackTimeRamp.advanceTo(_now + frameOffset);
                releaseTimeRamp.advanceTo(_now + frameOffset);
            }
            *_compressor0->ratio = ratioRamp.getValue();
            *_compressor1->ratio = ratioRamp.getValue();
            *_compressor0->thresh = thresholdRamp.getValue();
            *_compressor1->thresh = thresholdRamp.getValue();
            *_compressor0->atk = attackTimeRamp.getValue();
            *_compressor1->atk = attackTimeRamp.getValue();
            *_compressor0->rel = releaseTimeRamp.getValue();
            *_compressor1->rel = releaseTimeRamp.getValue();            

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
                    sp_compressor_compute(_sp, _compressor0, in, out);
                } else {
                    sp_compressor_compute(_sp, _compressor1, in, out);
                }
            }
            if (_playing) {
            }
        }
    }
};

#endif
