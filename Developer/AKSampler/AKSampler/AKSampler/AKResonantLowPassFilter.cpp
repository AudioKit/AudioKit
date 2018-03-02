//
//  AKResonantLowPassFilter.mm
//  ExtendingAudioKit
//
//  Created by Shane Dunne on 2018-02-23.
//  Copyright © 2018 Shane Dunne & Associates. All rights reserved.
//

#include "AKResonantLowPassFilter.hpp"
#include <math.h>

static const float kMinCutoffHz = 12.0;
//static const float kDefaultCutoff = 1000.0;
static const float kMinResonance = -20.0;
static const float kMaxResonance = 20.0;
//static const float kDefaultResonance = 0;


AKResonantLowPassFilter::AKResonantLowPassFilter()
{
    init(44100.0);
}

void AKResonantLowPassFilter::init(double sampleRateHz)
{
    this->sampleRateHz = sampleRateHz;
    
    // initialize filter state
    mX1 = mX2 = mY1 = mY1 = 0.0;
    
    // force filter coefficient calculation
    mLastCutoffHz = mLastResonanceDb = -1.0;
}

void AKResonantLowPassFilter::setParams(double newCutoffHz, double newResonanceDb)
{
    // only calculate the filter coefficients if the parameters have changed from last time
    if (newCutoffHz == mLastCutoffHz && newResonanceDb == mLastResonanceDb) return;
        
    if (newCutoffHz < kMinCutoffHz) newCutoffHz = kMinCutoffHz;
    if (newResonanceDb < kMinResonance ) newResonanceDb = kMinResonance;
    if (newResonanceDb > kMaxResonance ) newResonanceDb = kMaxResonance;
    
    // convert cutoff from Hz to 0->1 normalized frequency
    double cutoff = 2.0 * newCutoffHz / sampleRateHz;
    if (cutoff > 0.99) cutoff = 0.99;   // clip
    
    mLastCutoffHz = newCutoffHz;
    mLastResonanceDb = newResonanceDb;
    
    double r = pow(10.0, 0.05 * -newResonanceDb);        // convert resonance from decibels to linear
    
    double k = 0.5 * r * sin(M_PI * cutoff);
    double c1 = 0.5 * (1.0 - k) / (1.0 + k);
    double c2 = (0.5 + c1) * cos(M_PI * cutoff);
    double c3 = (0.5 + c1 - c2) * 0.25;
    
    mA0 = 2.0 * c3;
    mA1 = 2.0 * 2.0 * c3;
    mA2 = 2.0 * c3;
    mB1 = 2.0 * -c2;
    mB2 = 2.0 * c1;
}

void AKResonantLowPassFilter::process(const float *sourceP, float *destP, int inFramesToProcess)
{
    while (inFramesToProcess--)
    {
        float input = *sourceP++;
        float output = mA0*input + mA1*mX1 + mA2*mX2 - mB1*mY1 - mB2*mY2;
        
        mX2 = mX1;
        mX1 = input;
        mY2 = mY1;
        mY1 = output;
        
        *destP++ = output;
    }
}
