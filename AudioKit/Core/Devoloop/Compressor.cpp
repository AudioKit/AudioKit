//
//  Compressor.cpp
//  SilenceDetectionEffect
//
//  Created by Mike Gazzaruso, revision history on Githbub.
//
//

#include "Compressor.h"

Compressor::Compressor(float fThreshold, float fRatio, float fAttack,
                       float fRelease, int iSampleRate)
: envDetector((double)iSampleRate), compGain(0.0f) {
    theThreshold = fThreshold;
    theRatio = fRatio;
    
    envDetector.init((float)iSampleRate, fAttack, fRelease, false,
                     DETECT_MODE_RMS, true);
    
    delayLookAhead.init(1 * iSampleRate);
    
    // set the current value
    delayLookAhead.setDelay_mSec(0.0f);
    
    // flush delays
    delayLookAhead.resetDelay();
}

void Compressor::setParameters(float fThreshold, float fRatio, float fAttack,
                               float fRelease) {
    this->theThreshold = fThreshold;
    this->theRatio = fRatio;
    this->envDetector.setAttackDuration(fAttack);
    this->envDetector.setReleaseDuration(fRelease);
}

float Compressor::Process(float fInputSignal, bool bLimitOn,
                          float fSensitivity) {
    float fOutputSignal;
    
    float fDetector = envDetector.detect(fInputSignal * fSensitivity);
    
    float fGn = 1.0;
    
    fGn = calcCompressorGain(fDetector, theThreshold, theRatio, 1.0f, bLimitOn);
    this->compGain = fGn;
    
    float fLookAheadOut = 0.0f;
    delayLookAhead.processAudio(&fInputSignal, &fLookAheadOut);
    
    fOutputSignal = fGn * fLookAheadOut;
    
    return fOutputSignal;
}

float Compressor::calcCompressorGain(float fDetectorValue, float fTheThreshold,
                                     float fTheRatio, float fKneeWidth,
                                     bool bLimit) {
    // slope variable
    float CS = 1.0f - 1.0f / fTheRatio; // [Eq. 13.1]
    
    // limiting is infinite ratio thus CS->1.0
    if (bLimit)
        CS = 1;
    
    // soft-knee with detection value in range?
    if (fKneeWidth > 0 && fDetectorValue > (fTheThreshold - fKneeWidth / 2.0) &&
        fDetectorValue < fTheThreshold + fKneeWidth / 2.0) {
        // setup for Lagrange
        double x[2];
        double y[2];
        x[0] = fTheThreshold - fKneeWidth / 2.0;
        x[1] = fTheThreshold + fKneeWidth / 2.0;
        x[1] = min(0, x[1]); // top limit is 0dBFS
        y[0] = 0;            // CS = 0 for 1:1 ratio
        y[1] = CS;           // current CS
        
        // interpolate & overwrite CS
        CS = (float)lagrpol(&x[0], &y[0], 2, fDetectorValue);
    }
    
    // compute gain; threshold and detection values are in dB
    float yG = CS * (fTheThreshold - fDetectorValue); // [Eq. 13.1]
    
    // clamp; this allows ratios of 1:1 to still operate
    yG = min(0, yG);
    
    // convert back to linear
    return powf(10.0f, yG / 20.0f);
}

float Compressor::getCompGain() { return this->compGain; }
