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
    RageProcessor *leftRageProcessor;
    RageProcessor *rightRageProcessor;
    Equalisator *leftEqLo;
    Equalisator *rightEqLo;
    Equalisator *leftEqGtr;
    Equalisator *rightEqGtr;
    Equalisator *leftEqMi;
    Equalisator *rightEqMi;
    Equalisator *leftEqHi;
    Equalisator *rightEqHi;
    MikeFilter *mikeFilterL;
    MikeFilter *mikeFilterR;

    float sampleRate;

    float preGain = 5.0;
    float postGain = 0.7;
    float lowGain = 0.0;
    float midGain = 0.0;
    float highGain = 0.0;
    float distortion = 1.0;
};

AKRhinoGuitarProcessorDSPKernel::AKRhinoGuitarProcessorDSPKernel() : data(new InternalData) {}

AKRhinoGuitarProcessorDSPKernel::~AKRhinoGuitarProcessorDSPKernel() = default;

void AKRhinoGuitarProcessorDSPKernel::init(int channelCount, double sampleRate) {
    AKDSPKernel::init(channelCount, sampleRate);

    sampleRate = (float)sampleRate;

    data->leftEqLo = new Equalisator();
    data->rightEqLo = new Equalisator();
    data->leftEqGtr = new Equalisator();
    data->rightEqGtr = new Equalisator();
    data->leftEqMi = new Equalisator();
    data->rightEqMi = new Equalisator();
    data->leftEqHi = new Equalisator();
    data->rightEqHi = new Equalisator();
    data->mikeFilterL = new MikeFilter();
    data->mikeFilterR = new MikeFilter();

    data->leftRageProcessor = new RageProcessor((int)sampleRate);
    data->rightRageProcessor = new RageProcessor((int)sampleRate);

    data->leftEqLo->calc_filter_coeffs(7, 120.f, (float)sampleRate, 0.75, -2.f, false);
    data->rightEqLo->calc_filter_coeffs(7, 120.f, (float)sampleRate, 0.75, -2.f, false);

    data->leftEqMi->calc_filter_coeffs(6, 2450, sampleRate, 1.5, 6.5, true);
    data->rightEqMi->calc_filter_coeffs(6, 2450, sampleRate, 1.5, 6.5, true);

    data->leftEqHi->calc_filter_coeffs(8, 6100, sampleRate, 1.6,-15, false);
    data->rightEqHi->calc_filter_coeffs(8, 6100, sampleRate, 1.6,-15, false);

    data->mikeFilterL->calc_filter_coeffs(2500.f, sampleRate);
    data->mikeFilterR->calc_filter_coeffs(2500.f, sampleRate);

    data->lowGain = 0.0f;
    data->midGain = 0.0f;
    data->highGain = 0.0f;

    preGainRamper.init();
    postGainRamper.init();
    lowGainRamper.init();
    midGainRamper.init();
    highGainRamper.init();
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
            lowGainRamper.startRamp(clamp(value, -10.0f, 10.0f), duration);

            break;

        case midGainAddress:
            midGainRamper.startRamp(clamp(value, -10.0f, 10.0f), duration);
            break;

        case highGainAddress:
            highGainRamper.startRamp(clamp(value, -10.0f, 10.0f), duration);
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
        data->distortion = distortionRamper.getAndStep();

        data->leftEqLo->calc_filter_coeffs(7, 120, sampleRate, 0.75, -2 * -data->lowGain, false);
        data->rightEqLo->calc_filter_coeffs(7, 120, sampleRate, 0.75, -2 * -data->lowGain, false);

        data->leftEqMi->calc_filter_coeffs(6, 2450, sampleRate, 1.7, 2.5 * data->midGain, true);
        data->rightEqMi->calc_filter_coeffs(6, 2450, sampleRate, 1.7, 2.5 * data->midGain, true);

        data->leftEqHi->calc_filter_coeffs(8, 6100, sampleRate, 1.6, -15 * -data->highGain, false);
        data->rightEqHi->calc_filter_coeffs(8, 6100, sampleRate, 1.6, -15 * -data->highGain, false);

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
            const float r_Sig = data->leftRageProcessor->doRage(*in, data->distortion * 2, data->distortion * 2);
            const float e_Sig = data->leftEqLo->filter(data->leftEqMi->filter(data->leftEqHi->filter(r_Sig))) *
            (1 / (data->distortion*0.8));
            *out = e_Sig * data->postGain;
        }
    }
}
