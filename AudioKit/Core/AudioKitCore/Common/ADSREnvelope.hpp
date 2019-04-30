//
//  ADSREnvelope.hpp
//  AudioKit Core
//
//  Created by Shane Dunne, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//
#include "EnvelopeGeneratorBase.hpp"

namespace AudioKitCore
{

    struct ADSREnvelopeParameters
    {
        float sampleRateHz;
        float attackSamples, decaySamples, releaseSamples;
        float sustainFraction;    // [0.0, 1.0]

        ADSREnvelopeParameters();
        void init(float newSampleRateHz, float attackSeconds, float decaySeconds, float susFraction, float releaseSeconds);
        void init(float attackSeconds, float decaySeconds, float susFraction, float releaseSeconds);
        void updateSampleRate(float newSampleRateHz);

        void setAttackDurationSeconds(float attackSeconds) { attackSamples = attackSeconds * sampleRateHz; }
        float getAttackDurationSeconds() { return attackSamples / sampleRateHz; }
        void setDecayDurationSeconds(float decaySeconds) { decaySamples = decaySeconds * sampleRateHz; }
        float getDecayDurationSeconds() { return decaySamples / sampleRateHz; }
        void setReleaseDurationSeconds(float releaseSeconds) { releaseSamples = releaseSeconds * sampleRateHz; }
        float getReleaseDurationSeconds() { return releaseSamples / sampleRateHz; }
    };

    struct ADSREnvelope
    {
        ADSREnvelopeParameters* pParameters; // many ADSREnvelopes can share a common set of parameters

        enum EG_Segment
        {
            kIdle = 0,
            kSilence,
            kAttack,
            kDecay,
            kSustain,
            kRelease
        };

        enum CurvatureType
        {
            kLinear,        // all segments linear
            kAnalogLike,    // models CEM3310 integrated circuit
            kLinearInDb     // decay and release are linear-in-dB
        };

        void init(CurvatureType curvatureType = kAnalogLike);
        void updateParams();

        void start();       // called for note-on
        void restart();     // quickly dampen note then start again
        void release();     // called for note-off
        void reset();       // reset to idle state
        bool isIdle() { return env.getCurrentSegmentIndex() == kIdle; }
        bool isPreStarting() { return env.getCurrentSegmentIndex() == kSilence; }
        bool isReleasing() { return env.getCurrentSegmentIndex() == kRelease; }

        inline float getValue()
        {
            return env.getValue();
        }
        
        inline float getSample()
        {
            float sample;
            env.getSample(sample);
            return sample;
        }

    protected:
        MultiSegmentEnvelopeGenerator env;
        MultiSegmentEnvelopeGenerator::Descriptor envDesc;
    };

}
