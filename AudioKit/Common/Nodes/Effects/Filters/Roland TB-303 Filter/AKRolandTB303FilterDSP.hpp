//
//  AKRolandTB303FilterDSP.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import <Foundation/Foundation.h>

typedef NS_ENUM(int64_t, AKRolandTB303FilterParameter) {
    AKRolandTB303FilterParameterCutoffFrequency,
    AKRolandTB303FilterParameterResonance,
    AKRolandTB303FilterParameterDistortion,
    AKRolandTB303FilterParameterResonanceAsymmetry,
    AKRolandTB303FilterParameterRampTime
};

#import "AKLinearParameterRamp.hpp"  // have to put this here to get it included in umbrella header

#ifndef __cplusplus

void* createRolandTB303FilterDSP(int nChannels, double sampleRate);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKRolandTB303FilterDSP : public AKSoundpipeDSPBase {

    sp_tbvcf *_tbvcf0;
    sp_tbvcf *_tbvcf1;

private:
    AKLinearParameterRamp cutoffFrequencyRamp;
    AKLinearParameterRamp resonanceRamp;
    AKLinearParameterRamp distortionRamp;
    AKLinearParameterRamp resonanceAsymmetryRamp;
   
public:
    AKRolandTB303FilterDSP() {
        cutoffFrequencyRamp.setTarget(500, true);
        cutoffFrequencyRamp.setDurationInSamples(10000);
        resonanceRamp.setTarget(0.5, true);
        resonanceRamp.setDurationInSamples(10000);
        distortionRamp.setTarget(2.0, true);
        distortionRamp.setDurationInSamples(10000);
        resonanceAsymmetryRamp.setTarget(0.5, true);
        resonanceAsymmetryRamp.setDurationInSamples(10000);
    }

    /** Uses the ParameterAddress as a key */
    void setParameter(AUParameterAddress address, float value, bool immediate) override {
        switch (address) {
            case AKRolandTB303FilterParameterCutoffFrequency:
                cutoffFrequencyRamp.setTarget(value, immediate);
                break;
            case AKRolandTB303FilterParameterResonance:
                resonanceRamp.setTarget(value, immediate);
                break;
            case AKRolandTB303FilterParameterDistortion:
                distortionRamp.setTarget(value, immediate);
                break;
            case AKRolandTB303FilterParameterResonanceAsymmetry:
                resonanceAsymmetryRamp.setTarget(value, immediate);
                break;
            case AKRolandTB303FilterParameterRampTime:
                cutoffFrequencyRamp.setRampTime(value, _sampleRate);
                resonanceRamp.setRampTime(value, _sampleRate);
                distortionRamp.setRampTime(value, _sampleRate);
                resonanceAsymmetryRamp.setRampTime(value, _sampleRate);
                break;
        }
    }

    /** Uses the ParameterAddress as a key */
    float getParameter(AUParameterAddress address) override {
        switch (address) {
            case AKRolandTB303FilterParameterCutoffFrequency:
                return cutoffFrequencyRamp.getTarget();
            case AKRolandTB303FilterParameterResonance:
                return resonanceRamp.getTarget();
            case AKRolandTB303FilterParameterDistortion:
                return distortionRamp.getTarget();
            case AKRolandTB303FilterParameterResonanceAsymmetry:
                return resonanceAsymmetryRamp.getTarget();
            case AKRolandTB303FilterParameterRampTime:
                return cutoffFrequencyRamp.getRampTime(_sampleRate);
        }
        return 0;
    }

    void init(int _channels, double _sampleRate) override {
        AKSoundpipeDSPBase::init(_channels, _sampleRate);
        sp_tbvcf_create(&_tbvcf0);
        sp_tbvcf_create(&_tbvcf1);
        sp_tbvcf_init(_sp, _tbvcf0);
        sp_tbvcf_init(_sp, _tbvcf1);
        _tbvcf0->fco = 500;
        _tbvcf1->fco = 500;
        _tbvcf0->res = 0.5;
        _tbvcf1->res = 0.5;
        _tbvcf0->dist = 2.0;
        _tbvcf1->dist = 2.0;
        _tbvcf0->asym = 0.5;
        _tbvcf1->asym = 0.5;
    }

    void destroy() {
        sp_tbvcf_destroy(&_tbvcf0);
        sp_tbvcf_destroy(&_tbvcf1);
        AKSoundpipeDSPBase::destroy();
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            // do gain ramping every 8 samples
            if ((frameOffset & 0x7) == 0) {
                cutoffFrequencyRamp.advanceTo(_now + frameOffset);
                resonanceRamp.advanceTo(_now + frameOffset);
                distortionRamp.advanceTo(_now + frameOffset);
                resonanceAsymmetryRamp.advanceTo(_now + frameOffset);
            }
            _tbvcf0->fco = cutoffFrequencyRamp.getValue();
            _tbvcf1->fco = cutoffFrequencyRamp.getValue();            
            _tbvcf0->res = resonanceRamp.getValue();
            _tbvcf1->res = resonanceRamp.getValue();            
            _tbvcf0->dist = distortionRamp.getValue();
            _tbvcf1->dist = distortionRamp.getValue();            
            _tbvcf0->asym = resonanceAsymmetryRamp.getValue();
            _tbvcf1->asym = resonanceAsymmetryRamp.getValue();            

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
                    sp_tbvcf_compute(_sp, _tbvcf0, in, out);
                } else {
                    sp_tbvcf_compute(_sp, _tbvcf1, in, out);
                }
            }
            if (_playing) {
            }
        }
    }
};

#endif
