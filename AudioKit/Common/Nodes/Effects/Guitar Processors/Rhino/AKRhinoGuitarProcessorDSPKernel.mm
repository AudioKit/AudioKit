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

struct AKRhinoGuitarProcessorDSPKernel::InternalData {
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

AKRhinoGuitarProcessorDSPKernel::AKRhinoGuitarProcessorDSPKernel() : data(new InternalData) {}

AKRhinoGuitarProcessorDSPKernel::~AKRhinoGuitarProcessorDSPKernel() = default;

void AKRhinoGuitarProcessorDSPKernel::init(int _channels, double _sampleRate) {
    AKDSPKernel::init(_channels, _sampleRate);
    
    sampleRate = (float)_sampleRate;
    
    data->_leftEqLo = new Equalisator();
    data->_rightEqLo = new Equalisator();
    data->_leftEqGtr = new Equalisator();
    data->_rightEqGtr = new Equalisator();
    data->_leftEqMi = new Equalisator();
    data->_rightEqMi = new Equalisator();
    data->_leftEqHi = new Equalisator();
    data->_rightEqHi = new Equalisator();
    data->_mikeFilterL = new MikeFilter();
    data->_mikeFilterR = new MikeFilter();
    
    data->_leftRageProcessor = new RageProcessor((int)_sampleRate);
    data->_rightRageProcessor = new RageProcessor((int)_sampleRate);
    
    data->_leftEqLo->calc_filter_coeffs(7, 120.f, (float)_sampleRate, 0.75, -2.f, false);
    data->_rightEqLo->calc_filter_coeffs(7, 120.f, (float)_sampleRate, 0.75, -2.f, false);
    
    data->_leftEqMi->calc_filter_coeffs(6, 2450, sampleRate, 1.5, 6.5, true);
    data->_rightEqMi->calc_filter_coeffs(6, 2450, sampleRate, 1.5, 6.5, true);
    
    data->_leftEqHi->calc_filter_coeffs(8, 6100, sampleRate, 1.6,-15, false);
    data->_rightEqHi->calc_filter_coeffs(8, 6100, sampleRate, 1.6,-15, false);
    
    data->_mikeFilterL->calc_filter_coeffs(2500.f, _sampleRate);
    data->_mikeFilterR->calc_filter_coeffs(2500.f, _sampleRate);
    
    data->lowGain = 0.0f;
    data->midGain = 0.0f;
    data->highGain = 0.0f;
    
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
    data->preGain = clamp(value, 0.0f, 10.0f);
    preGainRamper.setImmediate(data->preGain);
}

void AKRhinoGuitarProcessorDSPKernel::setPostGain(float value) {
    data->postGain = clamp(value, 0.0f, 1.0f);
    postGainRamper.setImmediate(data->postGain);
}

void AKRhinoGuitarProcessorDSPKernel::setLowGain(float value) {
    data->lowGain = clamp(value, -1.0f, 1.0f);
    lowGainRamper.setImmediate(data->lowGain);
}

void AKRhinoGuitarProcessorDSPKernel::setMidGain(float value) {
    data->midGain = clamp(value, -1.0f, 1.0f);
    midGainRamper.setImmediate(data->midGain);
}

void AKRhinoGuitarProcessorDSPKernel::setHighGain(float value) {
    data->highGain = clamp(value, -1.0f, 1.0f);
    highGainRamper.setImmediate(data->highGain);
}

void AKRhinoGuitarProcessorDSPKernel::setDistType(float value) {
    data->distType = clamp(value, -1.0f, 3.0f);
    distTypeRamper.setImmediate(data->distType);
}

void AKRhinoGuitarProcessorDSPKernel::setDistortion(float value) {
    data->distortion = clamp(value, 1.0f, 20.0f);
    distortionRamper.setImmediate(data->distortion);
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
        
        data->preGain = preGainRamper.getAndStep();
        data->postGain = postGainRamper.getAndStep();
        data->lowGain = lowGainRamper.getAndStep();
        data->midGain = midGainRamper.getAndStep();
        data->highGain = highGainRamper.getAndStep();
        data->distType = distTypeRamper.getAndStep();
        data->distortion = distortionRamper.getAndStep();
        
        data->_leftEqLo->calc_filter_coeffs(7, 120, sampleRate, 0.75, -2 * -data->lowGain, false);
        data->_rightEqLo->calc_filter_coeffs(7, 120, sampleRate, 0.75, -2 * -data->lowGain, false);
        
        data->_leftEqMi->calc_filter_coeffs(6, 2450, sampleRate, 1.7, 2.5 * data->midGain, true);
        data->_rightEqMi->calc_filter_coeffs(6, 2450, sampleRate, 1.7, 2.5 * data->midGain, true);
        
        data->_leftEqHi->calc_filter_coeffs(8, 6100, sampleRate, 1.6, -15 * -data->highGain, false);
        data->_rightEqHi->calc_filter_coeffs(8, 6100, sampleRate, 1.6, -15 * -data->highGain, false);

        float *tmpin[2];
        float *tmpout[2];
        for (int channel = 0; channel < 2; ++channel) {
            float *in  = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
            float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;
            if (channel < 2) {
                tmpin[channel] = in;
                tmpout[channel] = out;
            }
            if (!started) {
                *out = *in;
                continue;
            }

            *in = *in * (data->preGain);
            const float r_Sig = data->_leftRageProcessor->doRage(*in, data->distortion * 2, data->distortion * 2);
            const float e_Sig = data->_leftEqLo->filter(data->_leftEqMi->filter(data->_leftEqHi->filter(r_Sig))) *
            (1 / (data->distortion*0.8));
            *out = e_Sig * data->postGain;
        }
    }
}
