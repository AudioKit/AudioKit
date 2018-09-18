//
//  AKSynthDSP.cpp
//  AudioKit Core
//
//  Created by Shane Dunne, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import "AKSynthDSP.hpp"
#include <math.h>

extern "C" void *AKSynthCreateDSP(int nChannels, double sampleRate) {
    return new AKSynthDSP();
}

extern "C" void AKSynthPlayNote(void *pDSP, UInt8 noteNumber, UInt8 velocity, float noteFrequency)
{
    ((AKSynthDSP*)pDSP)->playNote(noteNumber, velocity, noteFrequency);
}

extern "C" void AKSynthStopNote(void *pDSP, UInt8 noteNumber, bool immediate)
{
    ((AKSynthDSP*)pDSP)->stopNote(noteNumber, immediate);
}

extern "C" void AKSynthSustainPedal(void *pDSP, bool pedalDown)
{
    ((AKSynthDSP*)pDSP)->sustainPedal(pedalDown);
}


AKSynthDSP::AKSynthDSP() : AKSynth()
{
    masterVolumeRamp.setTarget(1.0, true);
    pitchBendRamp.setTarget(0.0, true);
    vibratoDepthRamp.setTarget(0.0, true);
    filterCutoffRamp.setTarget(1000.0, true);
    filterResonanceRamp.setTarget(1.0, true);
}

void AKSynthDSP::init(int nChannels, double sampleRate)
{
    AKDSPBase::init(nChannels, sampleRate);
    AKSynth::init(sampleRate);
}

void AKSynthDSP::deinit()
{
    AKSynth::deinit();
}

void AKSynthDSP::setParameter(uint64_t address, float value, bool immediate)
{
    switch (address) {
        case rampDurationParameter:
            masterVolumeRamp.setRampDuration(value, _sampleRate);
            pitchBendRamp.setRampDuration(value, _sampleRate);
            vibratoDepthRamp.setRampDuration(value, _sampleRate);
            filterCutoffRamp.setRampDuration(value, _sampleRate);
            filterResonanceRamp.setRampDuration(value, _sampleRate);
            break;

        case masterVolumeParameter:
            masterVolumeRamp.setTarget(value, immediate);
            break;
        case pitchBendParameter:
            pitchBendRamp.setTarget(value, immediate);
            break;
        case vibratoDepthParameter:
            vibratoDepthRamp.setTarget(value, immediate);
            break;
        case filterCutoffParameter:
            filterCutoffRamp.setTarget(value, immediate);
            break;
        case filterResonanceParameter:
            filterResonanceRamp.setTarget(pow(10.0, -0.05 * value), immediate);
            break;

        case attackDurationParameter:
            setAmpAttackDurationSeconds(value);
            break;
        case decayDurationParameter:
            setAmpDecayDurationSeconds(value);
            break;
        case sustainLevelParameter:
            setAmpSustainFraction(value);
            break;
        case releaseDurationParameter:
            setAmpReleaseDurationSeconds(value);
            break;

        case filterAttackDurationParameter:
            setFilterAttackDurationSeconds(value);
            break;
        case filterDecayDurationParameter:
            setFilterDecayDurationSeconds(value);
            break;
        case filterSustainLevelParameter:
            setFilterSustainFraction(value);
            break;
        case filterReleaseDurationParameter:
            setFilterReleaseDurationSeconds(value);
            break;
    }
}

float AKSynthDSP::getParameter(uint64_t address)
{
    switch (address) {
        case rampDurationParameter:
            return pitchBendRamp.getRampDuration(_sampleRate);

        case masterVolumeParameter:
            return masterVolumeRamp.getTarget();
        case pitchBendParameter:
            return pitchBendRamp.getTarget();
        case vibratoDepthParameter:
            return vibratoDepthRamp.getTarget();
        case filterCutoffParameter:
            return filterCutoffRamp.getTarget();
        case filterResonanceParameter:
            return -20.0f * log10(filterResonanceRamp.getTarget());

        case attackDurationParameter:
            return getAmpAttackDurationSeconds();
        case decayDurationParameter:
            return getAmpDecayDurationSeconds();
        case sustainLevelParameter:
            return getAmpSustainFraction();
        case releaseDurationParameter:
            return getAmpReleaseDurationSeconds();

        case filterAttackDurationParameter:
            return getFilterAttackDurationSeconds();
        case filterDecayDurationParameter:
            return getFilterDecayDurationSeconds();
        case filterSustainLevelParameter:
            return getFilterSustainFraction();
        case filterReleaseDurationParameter:
            return getFilterReleaseDurationSeconds();
    }
    return 0;
}

void AKSynthDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset)
{
    // process in chunks of maximum length CHUNKSIZE
    for (int frameIndex = 0; frameIndex < frameCount; frameIndex += AKSYNTH_CHUNKSIZE) {
        int frameOffset = int(frameIndex + bufferOffset);
        int chunkSize = frameCount - frameIndex;
        if (chunkSize > AKSYNTH_CHUNKSIZE) chunkSize = AKSYNTH_CHUNKSIZE;
        
        // ramp parameters
        masterVolumeRamp.advanceTo(_now + frameOffset);
        masterVolume = (float)masterVolumeRamp.getValue();
        pitchBendRamp.advanceTo(_now + frameOffset);
        pitchOffset = (float)pitchBendRamp.getValue();
        vibratoDepthRamp.advanceTo(_now + frameOffset);
        vibratoDepth = (float)vibratoDepthRamp.getValue();
        filterCutoffRamp.advanceTo(_now + frameOffset);
        cutoffMultiple = (float)filterCutoffRamp.getValue();
        filterResonanceRamp.advanceTo(_now + frameOffset);
        resLinear = (float)filterResonanceRamp.getValue();

        // get data
        float *outBuffers[2];
        outBuffers[0] = (float *)_outBufferListPtr->mBuffers[0].mData + frameOffset;
        outBuffers[1] = (float *)_outBufferListPtr->mBuffers[1].mData + frameOffset;
        unsigned channelCount = _outBufferListPtr->mNumberBuffers;
        AKSynth::render(channelCount, chunkSize, outBuffers);
    }
}
