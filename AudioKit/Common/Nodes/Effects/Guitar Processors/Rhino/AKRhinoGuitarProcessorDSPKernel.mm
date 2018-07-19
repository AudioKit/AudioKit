//
//  AKRhinoGuitarProcessorDSPKernel.cpp
//  AudioKit
//
//  Created by Stéphane Peter, revision history on Githbub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKRhinoGuitarProcessorDSPKernel.hpp"

#import "RageProcessor.h"
#import "Filter.h"
#import "Equalisator.h"
#import <math.h>
#import <iostream>

using namespace std;

struct AKRhinoGuitarProcessorDSPKernel::_Internal {
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
};

AKRhinoGuitarProcessorDSPKernel::AKRhinoGuitarProcessorDSPKernel() : _private(new _Internal) {}

AKRhinoGuitarProcessorDSPKernel::~AKRhinoGuitarProcessorDSPKernel() = default;

void AKRhinoGuitarProcessorDSPKernel::init(int _channels, double _sampleRate) {
    AKDSPKernel::init(_channels, _sampleRate);
    
    sampleRate = (float)_sampleRate;
    
    _private->_leftEqLo = new Equalisator();
    _private->_rightEqLo = new Equalisator();
    _private->_leftEqGtr = new Equalisator();
    _private->_rightEqGtr = new Equalisator();
    _private->_leftEqMi = new Equalisator();
    _private->_rightEqMi = new Equalisator();
    _private->_leftEqHi = new Equalisator();
    _private->_rightEqHi = new Equalisator();
    _private->_mikeFilterL = new MikeFilter();
    _private->_mikeFilterR = new MikeFilter();
    
    _private->_leftRageProcessor = new RageProcessor((int)_sampleRate);
    _private->_rightRageProcessor = new RageProcessor((int)_sampleRate);
    
    _private->_leftEqLo->calc_filter_coeffs(7, 120.f, (float)_sampleRate, 0.75, -2.f, false);
    _private->_rightEqLo->calc_filter_coeffs(7, 120.f, (float)_sampleRate, 0.75, -2.f, false);
    
    _private->_leftEqMi->calc_filter_coeffs(6, 2450, sampleRate, 1.5, 6.5, true);
    _private->_rightEqMi->calc_filter_coeffs(6, 2450, sampleRate, 1.5, 6.5, true);
    
    _private->_leftEqHi->calc_filter_coeffs(8, 6100, sampleRate, 1.6,-15, false);
    _private->_rightEqHi->calc_filter_coeffs(8, 6100, sampleRate, 1.6,-15, false);
    
    _private->_mikeFilterL->calc_filter_coeffs(2500.f, _sampleRate);
    _private->_mikeFilterR->calc_filter_coeffs(2500.f, _sampleRate);
    
    _private->lowGain = 0.0f;
    _private->midGain = 0.0f;
    _private->highGain = 0.0f;
    
    preGainRamper.init();
    postGainRamper.init();
    lowGainRamper.init();
    midGainRamper.init();
    highGainRamper.init();
    distTypeRamper.init();
    distortionRamper.init();
}

void AKRhinoGuitarProcessorDSPKernel::start() {
    started = true;
}

void AKRhinoGuitarProcessorDSPKernel::stop() {
    started = false;
}

void AKRhinoGuitarProcessorDSPKernel::destroy() {
}

void AKRhinoGuitarProcessorDSPKernel::reset() {
    resetted = true;
    preGainRamper.reset();
    postGainRamper.reset();
    lowGainRamper.reset();
    midGainRamper.reset();
    highGainRamper.reset();
    distTypeRamper.reset();
    distortionRamper.reset();
}

void AKRhinoGuitarProcessorDSPKernel::setPreGain(float value) {
    _private->preGain = clamp(value, 0.0f, 10.0f);
    preGainRamper.setImmediate(_private->preGain);
}

void AKRhinoGuitarProcessorDSPKernel::setPostGain(float value) {
    _private->postGain = clamp(value, 0.0f, 1.0f);
    postGainRamper.setImmediate(_private->postGain);
}

void AKRhinoGuitarProcessorDSPKernel::setLowGain(float value) {
    _private->lowGain = clamp(value, -1.0f, 1.0f);
    lowGainRamper.setImmediate(_private->lowGain);
}

void AKRhinoGuitarProcessorDSPKernel::setMidGain(float value) {
    _private->midGain = clamp(value, -1.0f, 1.0f);
    midGainRamper.setImmediate(_private->midGain);
}

void AKRhinoGuitarProcessorDSPKernel::setHighGain(float value) {
    _private->highGain = clamp(value, -1.0f, 1.0f);
    highGainRamper.setImmediate(_private->highGain);
}

void AKRhinoGuitarProcessorDSPKernel::setDistType(float value) {
    _private->distType = clamp(value, -1.0f, 3.0f);
    distTypeRamper.setImmediate(_private->distType);
}

void AKRhinoGuitarProcessorDSPKernel::setDistortion(float value) {
    _private->distortion = clamp(value, 1.0f, 20.0f);
    distortionRamper.setImmediate(_private->distortion);
}

void AKRhinoGuitarProcessorDSPKernel::setParameter(AUParameterAddress address, AUValue value) {
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

AUValue AKRhinoGuitarProcessorDSPKernel::getParameter(AUParameterAddress address) {
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

void AKRhinoGuitarProcessorDSPKernel::startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) {
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

void AKRhinoGuitarProcessorDSPKernel::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {
    
    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        
        int frameOffset = int(frameIndex + bufferOffset);
        
        _private->preGain = preGainRamper.getAndStep();
        _private->postGain = postGainRamper.getAndStep();
        _private->lowGain = lowGainRamper.getAndStep();
        _private->midGain = midGainRamper.getAndStep();
        _private->highGain = highGainRamper.getAndStep();
        _private->distType = distTypeRamper.getAndStep();
        _private->distortion = distortionRamper.getAndStep();
        
        _private->_leftEqLo->calc_filter_coeffs(7, 120, sampleRate, 0.75, -2 * -_private->lowGain, false);
        _private->_rightEqLo->calc_filter_coeffs(7, 120, sampleRate, 0.75, -2 * -_private->lowGain, false);
        
        _private->_leftEqMi->calc_filter_coeffs(6, 2450, sampleRate, 1.7, 2.5 * _private->midGain, true);
        _private->_rightEqMi->calc_filter_coeffs(6, 2450, sampleRate, 1.7, 2.5 * _private->midGain, true);
        
        _private->_leftEqHi->calc_filter_coeffs(8, 6100, sampleRate, 1.6, -15 * -_private->highGain, false);
        _private->_rightEqHi->calc_filter_coeffs(8, 6100, sampleRate, 1.6, -15 * -_private->highGain, false);
        
        float *in  = (float *)inBufferListPtr->mBuffers[0].mData  + frameOffset;
        float *outL = (float *)outBufferListPtr->mBuffers[0].mData + frameOffset;
        float *outR = (float *)outBufferListPtr->mBuffers[1].mData + frameOffset;
        
        if (started) {
            *in = *in * (_private->preGain);
            const float r_Sig = _private->_leftRageProcessor->doRage(*in, _private->distortion * 2, _private->distortion * 2);
            const float e_Sig = _private->_leftEqLo->filter(_private->_leftEqMi->filter(_private->_leftEqHi->filter(r_Sig))) *
                            (1 / (_private->distortion*0.8));
            *outL = e_Sig * _private->postGain;
            *outR = e_Sig * _private->postGain;
        } else {
            *outL = *in;
            *outR = *in;
        }
    }
}
