//
//  AKRhinoGuitarProcessorDSPKernel.hpp
//  AudioKit
//
//  Created by Mike Gazzaruso, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import "AKDSPKernel.hpp"
#import "RageProcessor.h"
#import "Filter.h"
#import "Equalisator.h"
#import <math.h>
#import <iostream>

using namespace std;

enum {
    preGainAddress = 0,
    postGainAddress = 1,
    lowGainAddress = 2,
    midGainAddress = 3,
    highGainAddress = 4,
    distTypeAddress = 5,
    distortionAddress= 6
};

class AKRhinoGuitarProcessorDSPKernel : public AKDSPKernel, public AKBuffered {
public:
    // MARK: Member Functions

    AKRhinoGuitarProcessorDSPKernel() {}

    void init(int _channels, double _sampleRate) override {
        AKDSPKernel::init(_channels, _sampleRate);

        sampleRate = (float)_sampleRate;

        _leftEqLo = new Equalisator();
        _rightEqLo = new Equalisator();
        _leftEqGtr = new Equalisator();
        _rightEqGtr = new Equalisator();
        _leftEqMi = new Equalisator();
        _rightEqMi = new Equalisator();
        _leftEqHi = new Equalisator();
        _rightEqHi = new Equalisator();
        _mikeFilterL = new MikeFilter();
        _mikeFilterR = new MikeFilter();

        _leftRageProcessor = new RageProcessor((int)_sampleRate);
        _rightRageProcessor = new RageProcessor((int)_sampleRate);

        _leftEqLo->calc_filter_coeffs(7, 120.f, (float)_sampleRate, 0.75, -2.f, false);
        _rightEqLo->calc_filter_coeffs(7, 120.f, (float)_sampleRate, 0.75, -2.f, false);

        _leftEqMi->calc_filter_coeffs(6, 2450, sampleRate, 1.5, 6.5, true);
        _rightEqMi->calc_filter_coeffs(6, 2450, sampleRate, 1.5, 6.5, true);

        _leftEqHi->calc_filter_coeffs(8, 6100, sampleRate, 1.6,-15, false);
        _rightEqHi->calc_filter_coeffs(8, 6100, sampleRate, 1.6,-15, false);

        _mikeFilterL->calc_filter_coeffs(2500.f, _sampleRate);
        _mikeFilterR->calc_filter_coeffs(2500.f, _sampleRate);

        lowGain = 0.0f;
        midGain = 0.0f;
        highGain = 0.0f;

        preGainRamper.init();
        postGainRamper.init();
        lowGainRamper.init();
        midGainRamper.init();
        highGainRamper.init();
        distTypeRamper.init();
        distortionRamper.init();
    }

    void start() {
        started = true;
    }

    void stop() {
        started = false;
    }

    void destroy() {
    }

    void reset() {
        resetted = true;
        preGainRamper.reset();
        postGainRamper.reset();
        lowGainRamper.reset();
        midGainRamper.reset();
        highGainRamper.reset();
        distTypeRamper.reset();
        distortionRamper.reset();
    }

    void setPreGain(float value) {
        preGain = clamp(value, 0.0f, 10.0f);
        preGainRamper.setImmediate(preGain);
    }

    void setPostGain(float value) {
        postGain = clamp(value, 0.0f, 1.0f);
        postGainRamper.setImmediate(postGain);
    }

    void setLowGain(float value) {
        lowGain = clamp(value, -1.0f, 1.0f);
        lowGainRamper.setImmediate(lowGain);
    }

    void setMidGain(float value) {
        midGain = clamp(value, -1.0f, 1.0f);
        midGainRamper.setImmediate(midGain);
    }

    void setHighGain(float value) {
        highGain = clamp(value, -1.0f, 1.0f);
        highGainRamper.setImmediate(highGain);
    }

    void setDistType(float value) {
        distType = clamp(value, -1.0f, 3.0f);
        distTypeRamper.setImmediate(distType);
    }

    void setDistortion(float value) {
        distortion = clamp(value, 1.0f, 20.0f);
        distortionRamper.setImmediate(distortion);
    }

    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case preGainAddress:
                preGainRamper.setUIValue(clamp(value, 0.0f, 10.0f));
                break;

            case postGainAddress:
                postGainRamper.setUIValue(clamp(value, 0.0f, 1.0f));
                break;

            case lowGainAddress:
                lowGainRamper.setUIValue(clamp(value, -1.0f, 1.0f));
                break;

            case midGainAddress:
                midGainRamper.setUIValue(clamp(value, -1.0f, 1.0f));
                break;

            case highGainAddress:
                highGainRamper.setUIValue(clamp(value, -1.0f, 1.0f));
                break;

            case distTypeAddress:
                distTypeRamper.setUIValue(clamp(value, 1.0f, 3.0f));
                break;

            case distortionAddress:
                distortionRamper.setUIValue(clamp(value, 1.0f, 20.0f));
                break;
        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case preGainAddress:
                return preGainRamper.getUIValue();

            case postGainAddress:
                return postGainRamper.getUIValue();

            case lowGainAddress:
                return lowGainRamper.getUIValue();

            case midGainAddress:
                return midGainRamper.getUIValue();

            case highGainAddress:
                return highGainRamper.getUIValue();

            case distTypeAddress:
                return distTypeRamper.getUIValue();

            case distortionAddress:
                return distortionRamper.getUIValue();

            default: return 0.0f;
        }
    }

    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
            case preGainAddress:
                preGainRamper.startRamp(clamp(value, 0.0f, 10.0f), duration);
                break;

            case postGainAddress:
                postGainRamper.startRamp(clamp(value, 0.0f, 1.0f), duration);
                break;

            case lowGainAddress:
                lowGainRamper.startRamp(clamp(value, -1.0f, 1.0f), duration);

                break;

            case midGainAddress:
                midGainRamper.startRamp(clamp(value, -1.0f, 1.0f), duration);
                break;

            case highGainAddress:
                highGainRamper.startRamp(clamp(value, -1.0f, 1.0f), duration);
                break;

            case distTypeAddress:
                distTypeRamper.startRamp(clamp(value, 1.0f, 3.0f), duration);
                break;

            case distortionAddress:
                distortionRamper.startRamp(clamp(value, 1.0f, 20.0f), duration);
                break;
        }
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {

            int frameOffset = int(frameIndex + bufferOffset);

            preGain = preGainRamper.getAndStep();
            postGain = postGainRamper.getAndStep();
            lowGain = lowGainRamper.getAndStep();
            midGain = midGainRamper.getAndStep();
            highGain = highGainRamper.getAndStep();
            distType = distTypeRamper.getAndStep();
            distortion = distortionRamper.getAndStep();

            _leftEqLo->calc_filter_coeffs(7, 120, sampleRate, 0.75, -2 * -lowGain, false);
            _rightEqLo->calc_filter_coeffs(7, 120, sampleRate, 0.75, -2 * -lowGain, false);

            _leftEqMi->calc_filter_coeffs(6, 2450, sampleRate, 1.7, 2.5 * midGain, true);
            _rightEqMi->calc_filter_coeffs(6, 2450, sampleRate, 1.7, 2.5 * midGain, true);

            _leftEqHi->calc_filter_coeffs(8, 6100, sampleRate, 1.6, -15 * -highGain, false);
            _rightEqHi->calc_filter_coeffs(8, 6100, sampleRate, 1.6, -15 * -highGain, false);

                float *in  = (float *)inBufferListPtr->mBuffers[0].mData  + frameOffset;
                float *outL = (float *)outBufferListPtr->mBuffers[0].mData + frameOffset;
                float *outR = (float *)outBufferListPtr->mBuffers[1].mData + frameOffset;

                if (started) {
                    *in = *in * (preGain);
                    const float r_Sig = _leftRageProcessor->doRage(*in, distortion * 2, distortion * 2);
                    const float e_Sig = _leftEqLo->filter(_leftEqMi->filter(_leftEqHi->filter(r_Sig))) * (1 / (distortion*0.8));
                    *outL = e_Sig * postGain;
                    *outR = e_Sig * postGain;
                } else {
                    *outL = *in;
                    *outR = *in;
                }
            }

    }

    // MARK: Member Variables

private:

    RageProcessor *_leftRageProcessor;
    RageProcessor *_rightRageProcessor;
    Equalisator *_leftEqLo;
    Equalisator *_rightEqLo;
    Equalisator *_leftEqGtr;
    Equalisator *_rightEqGtr;
    Equalisator *_leftEqMi;
    Equalisator *_rightEqMi;
    Equalisator *_leftEqHi;
    Equalisator *_rightEqHi;
    MikeFilter *_mikeFilterL;
    MikeFilter *_mikeFilterR;

    float sampleRate;

    float preGain = 5.0;
    float postGain = 0.7;
    float lowGain = 0.0;
    float midGain = 0.0;
    float highGain = 0.0;
    float distType = 1.0;
    float distortion = 1.0;

public:
    bool started = true;
    bool resetted = false;
    ParameterRamper preGainRamper = 5.0;
    ParameterRamper postGainRamper = 0.0;
    ParameterRamper lowGainRamper = 0.0;
    ParameterRamper midGainRamper = 0.0;
    ParameterRamper highGainRamper = 0.0;
    ParameterRamper distTypeRamper = 1.0;
    ParameterRamper distortionRamper = 1.0;
};
