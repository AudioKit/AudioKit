//
//  ADSREnvelope.hpp
//  AudioKit Core
//
//  Created by Shane Dunne, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "ADSREnvelope.hpp"
#include <stdio.h>

namespace AudioKitCore
{

    ADSREnvelopeParams::ADSREnvelopeParams()
    : sampleRateHz(44100.0f) // a guess, will be overridden later by a call to init(,,,,)
    {
        init(0.0f, 0.0f, 1.0f, 0.0f);
    }
    
    void ADSREnvelopeParams::init(float attackSeconds, float decaySeconds, float susFraction, float releaseSeconds)
    {
        attackSamples = attackSeconds * sampleRateHz;
        decaySamples = decaySeconds * sampleRateHz;
        sustainFraction = susFraction;
        releaseSamples = releaseSeconds * sampleRateHz;
    }
    
    void ADSREnvelopeParams::init(float newSampleRateHz, float attackSeconds, float decaySeconds, float susFraction, float releaseSeconds)
    {
        sampleRateHz = newSampleRateHz;
        init(attackSeconds, decaySeconds, susFraction, releaseSeconds);
    }
    
    void ADSREnvelopeParams::updateSampleRate(float newSampleRateHz)
    {
        float scaleFactor = newSampleRateHz / sampleRateHz;
        sampleRateHz = newSampleRateHz;
        attackSamples *= scaleFactor;
        decaySamples *= scaleFactor;
        releaseSamples *= scaleFactor;
    }
    
    
    void ADSREnvelope::init()
    {
        segment = kIdle;
        ramper.init(0.0f);
    }
    
    void ADSREnvelope::start()
    {
//        if (segment == kIdle)
//        {
//            // start new attack segment from zero
//            ramper.init(0.0f, 1.0f, pParams->attackSamples);
//        }
//        else
//        {
//            // envelope has been retriggered; start new attack from where we are
//            ramper.reinit(1.0f, pParams->attackSamples);
//        }
        
        ramper.init(0.0f, 1.0f, pParams->attackSamples);
        segment = kAttack;
    }
    
    void ADSREnvelope::release()
    {
        segment = kRelease;
        ramper.reinit(0.0f, pParams->releaseSamples);
    }

    void ADSREnvelope::restart()
    {
        segment = kSilence;
        ramper.reinit(0.0f, 0.01f * pParams->sampleRateHz); // always silence in 10 ms
    }

    void ADSREnvelope::reset()
    {
        ramper.init(0.0f);
        segment = kIdle;
    }

}
