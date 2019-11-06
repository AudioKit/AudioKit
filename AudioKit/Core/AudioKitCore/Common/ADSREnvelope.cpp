//
//  ADSREnvelope.cpp
//  AudioKit Core
//
//  Created by Shane Dunne, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//
#include "ADSREnvelope.hpp"

#include <cmath>

namespace AudioKitCore
{

    ADSREnvelopeParameters::ADSREnvelopeParameters()
        : sampleRateHz(44100.0f) // a guess, will be overridden later by a call to init(,,,,)
    {
        init(0.0f, 0.0f, 1.0f, 0.0f);
    }

    void ADSREnvelopeParameters::init(float attackSeconds, float decaySeconds, float susFraction, float releaseSeconds)
    {
        attackSamples = attackSeconds * sampleRateHz;
        decaySamples = decaySeconds * sampleRateHz;
        sustainFraction = susFraction;
        releaseSamples = releaseSeconds * sampleRateHz;
    }

    void ADSREnvelopeParameters::init(float newSampleRateHz, float attackSeconds, float decaySeconds, float susFraction, float releaseSeconds)
    {
        sampleRateHz = newSampleRateHz;
        init(attackSeconds, decaySeconds, susFraction, releaseSeconds);
    }

    void ADSREnvelopeParameters::updateSampleRate(float newSampleRateHz)
    {
        float scaleFactor = newSampleRateHz / sampleRateHz;
        sampleRateHz = newSampleRateHz;
        attackSamples *= scaleFactor;
        decaySamples *= scaleFactor;
        releaseSamples *= scaleFactor;
    }


    void ADSREnvelope::init(CurvatureType curvatureType)
    {
        int silenceSamples = int(0.01 * pParameters->sampleRateHz);     // always 10 mSec
        int attackSamples = int(pParameters->attackSamples);
        int decaySamples = int(pParameters->decaySamples);
        double sustainFraction = double(pParameters->sustainFraction);
        int releaseSamples = int(pParameters->releaseSamples);

        envDesc.clear();
        envDesc.push_back({ 0.0, 0.0, 0.0, -1 });               // kIdle: 0 forever
        envDesc.push_back({ 1.0, 0.0, 0.0, silenceSamples });   // kSilence in 10 mSec

        if (curvatureType == kAnalogLike)
        {
            envDesc.push_back({ 0.0, 1.0, exp(-1.5), attackSamples });                  // kAttack
            envDesc.push_back({ 1.0, sustainFraction, exp(-4.95), decaySamples });      // kDecay
            envDesc.push_back({ sustainFraction, sustainFraction, 0.0, -1 });           // kSustain
            envDesc.push_back({ sustainFraction, 0.0, exp(-4.95), releaseSamples });    // kRelease
        }
        else if (curvatureType == kLinearInDb)
        {
            envDesc.push_back({ 0.0, 1.0, 0.99999, attackSamples });                    // kAttack
            envDesc.push_back({ 1.0, sustainFraction, exp(-11.05), decaySamples });     // kDecay
            envDesc.push_back({ sustainFraction, sustainFraction, 0.0, -1 });           // kSustain
            envDesc.push_back({ sustainFraction, 0.0, exp(-11.05), releaseSamples });   // kRelease
        }
        else
        {
            envDesc.push_back({ 0.0, 1.0, 0.0, attackSamples });                        // kAttack
            envDesc.push_back({ 1.0, sustainFraction, 0.0, decaySamples });             // kDecay
            envDesc.push_back({ sustainFraction, sustainFraction, 0.0, -1 });           // kSustain
            envDesc.push_back({ sustainFraction, 0.0, 0.0, releaseSamples });           // kRelease
        }

        env.reset(&envDesc);
    }

    void ADSREnvelope::updateParams()
    {
        if (envDesc.size() < 6) return;
        double sustainFraction = double(pParameters->sustainFraction);

        envDesc[kAttack].lengthSamples = int(pParameters->attackSamples);
        envDesc[kDecay].finalValue = sustainFraction;
        envDesc[kDecay].lengthSamples = int(pParameters->decaySamples);
        envDesc[kSustain].initialValue = envDesc[kSustain].finalValue = sustainFraction;
        envDesc[kRelease].initialValue = sustainFraction;
        envDesc[kRelease].lengthSamples = int(pParameters->releaseSamples);
    }

    void ADSREnvelope::start()
    {
        env.advanceToSegment(kAttack);
    }

    void ADSREnvelope::restart()
    {
        env.advanceToSegment(kSilence);
    }

    void ADSREnvelope::release()
    {
        env.advanceToSegment(kRelease);
    }

    void ADSREnvelope::reset()
    {
        env.reset(&envDesc);
    }

}
