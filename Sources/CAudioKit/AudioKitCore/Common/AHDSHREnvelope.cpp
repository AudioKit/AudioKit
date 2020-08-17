// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AHDSHREnvelope.hpp"

#include <cmath>

namespace AudioKitCore
{

    AHDSHREnvelopeParameters::AHDSHREnvelopeParameters()
        : sampleRateHz(44100.0f) // a guess, will be overridden later by a call to init(,,,,)
    {
        init(0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f);
    }

    void AHDSHREnvelopeParameters::init(float attackSeconds, float holdSeconds, float decaySeconds,
                                        float susFraction, float releaseHoldSeconds, float releaseSeconds)
    {
        attackSamples = attackSeconds * sampleRateHz;
        holdSamples = holdSeconds * sampleRateHz;
        decaySamples = decaySeconds * sampleRateHz;
        sustainFraction = susFraction;
        releaseHoldSamples = releaseHoldSeconds * sampleRateHz;
        releaseSamples = releaseSeconds * sampleRateHz;
    }

    void AHDSHREnvelopeParameters::init(float newSampleRateHz, float attackSeconds, float holdSeconds, float decaySeconds,
                                        float susFraction, float releaseHoldSeconds, float releaseSeconds)
    {
        sampleRateHz = newSampleRateHz;
        init(attackSeconds, holdSeconds, decaySeconds, susFraction, releaseHoldSeconds, releaseSeconds);
    }

    void AHDSHREnvelopeParameters::updateSampleRate(float newSampleRateHz)
    {
        float scaleFactor = newSampleRateHz / sampleRateHz;
        sampleRateHz = newSampleRateHz;
        attackSamples *= scaleFactor;
        holdSamples *= scaleFactor;
        decaySamples *= scaleFactor;
        releaseHoldSamples *= scaleFactor;
        releaseSamples *= scaleFactor;
    }


    void AHDSHREnvelope::init(CurvatureType curvatureType)
    {
        int silenceSamples = int(0.01 * pParameters->sampleRateHz);     // always 10 mSec
        int attackSamples = int(pParameters->attackSamples);
        int holdSamples = int(pParameters->holdSamples);
        int decaySamples = int(pParameters->decaySamples);
        double sustainFraction = double(pParameters->sustainFraction);
        int releaseHoldSamples = int(pParameters->releaseHoldSamples);
        int releaseSamples = int(pParameters->releaseSamples);

        envDesc.clear();
        envDesc.push_back({ 0.0, 0.0, 0.0, -1 });               // kIdle: 0 forever
        envDesc.push_back({ 1.0, 0.0, 0.0, silenceSamples });   // kSilence in 10 mSec

        if (curvatureType == kAnalogLike)
        {
            envDesc.push_back({ 0.0, 1.0, exp(-1.5), attackSamples });                          // kAttack
            envDesc.push_back({ 1.0, 1.0, 0.0, holdSamples });                                  // kHold
            envDesc.push_back({ 1.0, sustainFraction, exp(-4.95), decaySamples });              // kDecay
            envDesc.push_back({ sustainFraction, sustainFraction, 0.0, -1 });                   // kSustain
            envDesc.push_back({ sustainFraction, sustainFraction, 0.0, releaseHoldSamples });   // kReleaseHold
            envDesc.push_back({ sustainFraction, 0.0, exp(-4.95), releaseSamples });            // kRelease
        }
        else if (curvatureType == kLinearInDb)
        {
            envDesc.push_back({ 0.0, 1.0, 0.99999, attackSamples });                            // kAttack
            envDesc.push_back({ 1.0, 1.0, 0.0, holdSamples });                                  // kHold
            envDesc.push_back({ 1.0, sustainFraction, exp(-11.05), decaySamples });             // kDecay
            envDesc.push_back({ sustainFraction, sustainFraction, 0.0, -1 });                   // kSustain
            envDesc.push_back({ sustainFraction, sustainFraction, 0.0, releaseHoldSamples });   // kReleaseHold
            envDesc.push_back({ sustainFraction, 0.0, exp(-11.05), releaseSamples });           // kRelease
        }
        else
        {
            envDesc.push_back({ 0.0, 1.0, 0.0, attackSamples });                                // kAttack
            envDesc.push_back({ 1.0, 1.0, 0.0, holdSamples });                                  // kHold
            envDesc.push_back({ 1.0, sustainFraction, 0.0, decaySamples });                     // kDecay
            envDesc.push_back({ sustainFraction, sustainFraction, 0.0, -1 });                   // kSustain
            envDesc.push_back({ sustainFraction, sustainFraction, 0.0, releaseHoldSamples });   // kReleaseHold
            envDesc.push_back({ sustainFraction, 0.0, 0.0, releaseSamples });                   // kRelease
        }

        env.reset(&envDesc);
    }

    void AHDSHREnvelope::updateParams()
    {
        if (envDesc.size() < 8) return;
        double sustainFraction = double(pParameters->sustainFraction);

        envDesc[kAttack].lengthSamples = int(pParameters->attackSamples);
        envDesc[kHold].initialValue = 1.0;
        envDesc[kHold].finalValue = 1.0;
        envDesc[kHold].lengthSamples = int(pParameters->holdSamples);
        envDesc[kDecay].finalValue = sustainFraction;
        envDesc[kDecay].lengthSamples = int(pParameters->decaySamples);
        envDesc[kSustain].initialValue = envDesc[kSustain].finalValue = sustainFraction;
        envDesc[kReleaseHold].initialValue = sustainFraction;
        envDesc[kReleaseHold].finalValue = sustainFraction;
        envDesc[kReleaseHold].lengthSamples = int(pParameters->releaseHoldSamples);
        envDesc[kRelease].initialValue = sustainFraction;
        envDesc[kRelease].lengthSamples = int(pParameters->releaseSamples);
    }

    void AHDSHREnvelope::start()
    {
        env.startAtSegment(kAttack);
    }

    void AHDSHREnvelope::restart()
    {
        env.advanceToSegment(kSilence);
    }

    void AHDSHREnvelope::release()
    {
        //update the 'release section' envelope values to be where the envelope currently is
        envDesc[kReleaseHold].initialValue = env.getValue();
        envDesc[kReleaseHold].finalValue = env.getValue();
        envDesc[kRelease].initialValue = env.getValue();
        env.advanceToSegment(kReleaseHold);
    }

    void AHDSHREnvelope::reset()
    {
        env.reset(&envDesc);
    }

}
