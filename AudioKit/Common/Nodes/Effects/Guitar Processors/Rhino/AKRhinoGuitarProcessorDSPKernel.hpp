//
//  AKRhinoGuitarProcessorDSPKernel.hpp
//  AudioKit
//
//  Created by Mike Gazzaruso, revision history on Github.
//  Copyright © 2017 Mike Gazzaruso, Devoloop Srls. All rights reserved.
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
    distAmountAddress= 6
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
        
        _leftEqLo->calc_filter_coeffs(6, 120.f, (float)_sampleRate, 4.5f, 0.0f, true);
        _rightEqLo->calc_filter_coeffs(6, 120.f, (float)_sampleRate, 4.5f, 0.0f, true);
        
        _leftEqMi->calc_filter_coeffs(6, 2900.f, (float)_sampleRate, 4.f,0.0f, true);
        _rightEqMi->calc_filter_coeffs(6, 2900.f, (float)_sampleRate, 4.f, 0.0f, true);
        
        _leftEqHi->calc_filter_coeffs(6, 10000.f, (float)_sampleRate, 5.f, 0.0f, true);
        _rightEqHi->calc_filter_coeffs(6, 10000.f, (float)_sampleRate, 5.f, 0.0f, true);
        
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
        distAmountRamper.init();
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
        distAmountRamper.reset();
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
    
    void setDistAmount(float value) {
        distAmount = clamp(value, 1.0f, 20.0f);
        distAmountRamper.setImmediate(distAmount);
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
                
            case distAmountAddress:
                distAmountRamper.setUIValue(clamp(value, 1.0f, 20.0f));
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
                
            case distAmountAddress:
                return distAmountRamper.getUIValue();
                
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
                
            case distAmountAddress:
                distAmountRamper.startRamp(clamp(value, 1.0f, 20.0f), duration);
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
            distAmount = distAmountRamper.getAndStep();
            
            _leftEqLo->calc_filter_coeffs(6, 120.f, sampleRate, 4.5f, (50.f * lowGain), true);
            _rightEqLo->calc_filter_coeffs(6, 120.f, sampleRate, 4.5f, (50.f * lowGain), true);
            
            _leftEqMi->calc_filter_coeffs(6, 2900.f, sampleRate, 4.f, 15.0f * midGain, true);
            _rightEqMi->calc_filter_coeffs(6, 2900.f, sampleRate, 4.f, 15.0f * midGain, true);
            
            _leftEqHi->calc_filter_coeffs(6, 10000.f, sampleRate, 5.f, (90.f * highGain), true);
            _rightEqHi->calc_filter_coeffs(6, 10000.f, sampleRate, 5.f, (90.f * highGain), true);
            
            for (int channel = 0; channel < channels; ++channel) {
                float *in  = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;
                
                if (started) {
                    *in = *in * (preGain / 5.0);
                    if (channel == 0) {
                        const float r_Sig = _leftRageProcessor->doRage(*in, distAmount, distAmount);
                        const float e_Sig = _leftEqLo->filter(_leftEqMi->filter(_leftEqHi->filter(r_Sig)));
                        *out = e_Sig * postGain;
                    } else {
                        const float r_Sig = _rightRageProcessor->doRage(*in, distAmount, distAmount);
                        const float e_Sig = _rightEqLo->filter(_rightEqMi->filter(_rightEqHi->filter(r_Sig)));
                        *out = e_Sig * postGain;
                    }
                } else {
                    *out = *in;
                }
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
    float distAmount = 1.0;
    
public:
    bool started = true;
    bool resetted = false;
    ParameterRamper preGainRamper = 5.0;
    ParameterRamper postGainRamper = 0.0;
    ParameterRamper lowGainRamper = 0.0;
    ParameterRamper midGainRamper = 0.0;
    ParameterRamper highGainRamper = 0.0;
    ParameterRamper distTypeRamper = 1.0;
    ParameterRamper distAmountRamper = 1.0;
};
