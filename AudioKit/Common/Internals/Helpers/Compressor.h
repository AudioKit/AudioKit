//
//  Compressor.h
//
//  Created by Mike Gazzaruso on 26/05/14.
//
//

#pragma once
#ifndef COMPRESSOR_H
#define COMPRESSOR_H

#include "pluginconstants.h"
#include "Delay.h"

class Compressor
{
    // Public
    public: Compressor(float fThreshold, float fRatio, float fAttack, float fRelease, int iSampleRate);
    public: float Process(float fInputSignal, bool bLimitOn, float fSensitivity);
    public: void setParameters(float fThreshold, float fRatio, float fAttack, float fRelease);
    public: float getCompGain();
    
    // Private
    private: CEnvelopeDetector envDetector;
    private: CDelay delayLookAhead;
    private: float theThreshold, theRatio, theAttack, theRelease;
    private: float calcCompressorGain(float fDetectorValue, float fThreshold, float fRatio, float fKneeWidth, bool bLimit);
    private: float compGain;
};

#endif
