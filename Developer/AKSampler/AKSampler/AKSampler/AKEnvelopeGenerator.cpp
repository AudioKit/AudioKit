//
//  AKEnvelopeGenerator.mm
//  ExtendingAudioKit
//
//  Created by Shane Dunne on 2018-02-20.
//  Copyright © 2018 Shane Dunne & Associates. All rights reserved.
//

#include "AKEnvelopeGenerator.hpp"
#include <stdio.h>


AKEnvelopeGeneratorParams::AKEnvelopeGeneratorParams()
: sampleRateHz(44100.0f) // a guess, will be overridden later by a call to init(,,,,)
{
    init(0.0f, 0.0f, 1.0f, 0.0f);
}

void AKEnvelopeGeneratorParams::init(float attackSeconds, float decaySeconds, float susFraction, float releaseSeconds)
{
    attackSamples = attackSeconds * sampleRateHz;
    decaySamples = decaySeconds * sampleRateHz;
    sustainFraction = susFraction;
    releaseSamples = releaseSeconds * sampleRateHz;
}

void AKEnvelopeGeneratorParams::init(float newSampleRateHz, float attackSeconds, float decaySeconds, float susFraction, float releaseSeconds)
{
    sampleRateHz = newSampleRateHz;
    init(attackSeconds, decaySeconds, susFraction, releaseSeconds);
}

void AKEnvelopeGeneratorParams::updateSampleRate(float newSampleRateHz)
{
    float scaleFactor = newSampleRateHz / sampleRateHz;
    sampleRateHz = newSampleRateHz;
    attackSamples *= scaleFactor;
    decaySamples *= scaleFactor;
    releaseSamples *= scaleFactor;
}


void AKEnvelopeGenerator::init()
{
    segment = kIdle;
    ramper.init(0.0f);
}

void AKEnvelopeGenerator::start()
{
    if (segment == kIdle)
    {
        // start new attack segment from zero
        ramper.init(0.0f, 1.0f, pParams->attackSamples);
    }
    else
    {
        // envelope has been retriggered; start new attack from where we are
        ramper.reinit(1.0f, pParams->attackSamples);
    }
    
    segment = kAttack;
}

void AKEnvelopeGenerator::release()
{
    segment = kRelease;
    ramper.reinit(0.0f, pParams->releaseSamples);
}

void AKEnvelopeGenerator::reset()
{
    ramper.init(0.0f);
    segment = kIdle;
}
