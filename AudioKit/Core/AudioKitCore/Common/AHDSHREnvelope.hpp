// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/
//
// Attack, Hold, Decay, Sustain, Release-hold, Release envelope
// 1) Attack fades in from 0 for attackSamples
// 2) Holds value at 1 for holdSamples
// 3) Decays to sustainFraction for decaySamples
// 4) Holds value at sustainFraction until release / noteOff
// 5) Holds value at sustainFraction for releaseHoldSamples
// 6) Fades to 0 for releaseSamples

#include "EnvelopeGeneratorBase.hpp"

namespace AudioKitCore
{

    struct AHDSHREnvelopeParameters
    {
        float sampleRateHz;
        float attackSamples, holdSamples, decaySamples, releaseHoldSamples, releaseSamples;
        float sustainFraction;    // [0.0, 1.0]

        AHDSHREnvelopeParameters();
        void init(float newSampleRateHz, float attackSeconds, float holdSeconds, float decaySeconds, float susFraction,
                  float releaseHoldSeconds, float releaseSeconds);
        void init(float attackSeconds, float holdSeconds, float decaySeconds, float susFraction,
                  float releaseHoldSeconds, float releaseSeconds);
        void updateSampleRate(float newSampleRateHz);

        void setAttackDurationSeconds(float attackSeconds) { attackSamples = attackSeconds * sampleRateHz; }
        float getAttackDurationSeconds() { return attackSamples / sampleRateHz; }
        void setHoldDurationSeconds(float holdSeconds) { holdSamples = holdSeconds * sampleRateHz; }
        float getHoldDurationSeconds() { return holdSamples / sampleRateHz; }
        void setDecayDurationSeconds(float decaySeconds) { decaySamples = decaySeconds * sampleRateHz; }
        float getDecayDurationSeconds() { return decaySamples / sampleRateHz; }
        void setReleaseHoldDurationSeconds(float releaseHoldSeconds) { releaseHoldSamples = releaseHoldSeconds * sampleRateHz; }
        float getReleaseHoldDurationSeconds() { return releaseHoldSamples / sampleRateHz; }
        void setReleaseDurationSeconds(float releaseSeconds) { releaseSamples = releaseSeconds * sampleRateHz; }
        float getReleaseDurationSeconds() { return releaseSamples / sampleRateHz; }
    };

    struct AHDSHREnvelope
    {
        AHDSHREnvelopeParameters* pParameters; // many ADSREnvelopes can share a common set of parameters

        enum EG_Segment
        {
            kIdle = 0,
            kSilence,
            kAttack,
            kHold,
            kDecay,
            kSustain,
            kReleaseHold,
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
        bool isReleasing() {
            return env.getCurrentSegmentIndex() == kReleaseHold || env.getCurrentSegmentIndex() == kRelease;
        }

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
