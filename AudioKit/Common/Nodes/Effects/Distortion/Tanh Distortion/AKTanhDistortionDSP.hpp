//
//  AKTanhDistortionDSP.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import <Foundation/Foundation.h>

typedef NS_ENUM(int64_t, AKTanhDistortionParameter) {
    AKTanhDistortionParameterPregain,
    AKTanhDistortionParameterPostgain,
    AKTanhDistortionParameterPositiveShapeParameter,
    AKTanhDistortionParameterNegativeShapeParameter,
    AKTanhDistortionParameterRampTime
};

#import "AKLinearParameterRamp.hpp"  // have to put this here to get it included in umbrella header

#ifndef __cplusplus

void* createTanhDistortionDSP(int nChannels, double sampleRate);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKTanhDistortionDSP : public AKSoundpipeDSPBase {

    sp_dist *_dist0;
    sp_dist *_dist1;

private:
    AKLinearParameterRamp pregainRamp;
    AKLinearParameterRamp postgainRamp;
    AKLinearParameterRamp positiveShapeParameterRamp;
    AKLinearParameterRamp negativeShapeParameterRamp;
   
public:
    AKTanhDistortionDSP() {
        pregainRamp.setTarget(2.0, true);
        pregainRamp.setDurationInSamples(10000);
        postgainRamp.setTarget(0.5, true);
        postgainRamp.setDurationInSamples(10000);
        positiveShapeParameterRamp.setTarget(0.0, true);
        positiveShapeParameterRamp.setDurationInSamples(10000);
        negativeShapeParameterRamp.setTarget(0.0, true);
        negativeShapeParameterRamp.setDurationInSamples(10000);
    }

    /** Uses the ParameterAddress as a key */
    void setParameter(AUParameterAddress address, float value, bool immediate) override {
        switch (address) {
            case AKTanhDistortionParameterPregain:
                pregainRamp.setTarget(value, immediate);
                break;
            case AKTanhDistortionParameterPostgain:
                postgainRamp.setTarget(value, immediate);
                break;
            case AKTanhDistortionParameterPositiveShapeParameter:
                positiveShapeParameterRamp.setTarget(value, immediate);
                break;
            case AKTanhDistortionParameterNegativeShapeParameter:
                negativeShapeParameterRamp.setTarget(value, immediate);
                break;
            case AKTanhDistortionParameterRampTime:
                pregainRamp.setRampTime(value, _sampleRate);
                postgainRamp.setRampTime(value, _sampleRate);
                positiveShapeParameterRamp.setRampTime(value, _sampleRate);
                negativeShapeParameterRamp.setRampTime(value, _sampleRate);
                break;
        }
    }

    /** Uses the ParameterAddress as a key */
    float getParameter(AUParameterAddress address) override {
        switch (address) {
            case AKTanhDistortionParameterPregain:
                return pregainRamp.getTarget();
            case AKTanhDistortionParameterPostgain:
                return postgainRamp.getTarget();
            case AKTanhDistortionParameterPositiveShapeParameter:
                return positiveShapeParameterRamp.getTarget();
            case AKTanhDistortionParameterNegativeShapeParameter:
                return negativeShapeParameterRamp.getTarget();
            case AKTanhDistortionParameterRampTime:
                return pregainRamp.getRampTime(_sampleRate);
        }
        return 0;
    }

    void init(int _channels, double _sampleRate) override {
        AKSoundpipeDSPBase::init(_channels, _sampleRate);
        sp_dist_create(&_dist0);
        sp_dist_create(&_dist1);
        sp_dist_init(_sp, _dist0);
        sp_dist_init(_sp, _dist1);
        _dist0->pregain = 2.0;
        _dist1->pregain = 2.0;
        _dist0->postgain = 0.5;
        _dist1->postgain = 0.5;
        _dist0->shape1 = 0.0;
        _dist1->shape1 = 0.0;
        _dist0->shape2 = 0.0;
        _dist1->shape2 = 0.0;
    }

    void destroy() {
        sp_dist_destroy(&_dist0);
        sp_dist_destroy(&_dist1);
        AKSoundpipeDSPBase::destroy();
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            // do gain ramping every 8 samples
            if ((frameOffset & 0x7) == 0) {
                pregainRamp.advanceTo(_now + frameOffset);
                postgainRamp.advanceTo(_now + frameOffset);
                positiveShapeParameterRamp.advanceTo(_now + frameOffset);
                negativeShapeParameterRamp.advanceTo(_now + frameOffset);
            }
            _dist0->pregain = pregainRamp.getValue();
            _dist1->pregain = pregainRamp.getValue();            
            _dist0->postgain = postgainRamp.getValue();
            _dist1->postgain = postgainRamp.getValue();            
            _dist0->shape1 = positiveShapeParameterRamp.getValue();
            _dist1->shape1 = positiveShapeParameterRamp.getValue();            
            _dist0->shape2 = negativeShapeParameterRamp.getValue();
            _dist1->shape2 = negativeShapeParameterRamp.getValue();            

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
                    sp_dist_compute(_sp, _dist0, in, out);
                } else {
                    sp_dist_compute(_sp, _dist1, in, out);
                }
            }
            if (_playing) {
            }
        }
    }
};

#endif
