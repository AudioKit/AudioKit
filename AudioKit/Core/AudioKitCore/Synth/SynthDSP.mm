//
//  SynthDSP.cpp
//  AudioKit Core
//
//  Created by Shane Dunne, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import "SynthDSP.hpp"
#include <math.h>

extern "C" void* createSynthDSP(int nChannels, double sampleRate) {
    return new SynthDSP();
}

extern "C" void doSynthPlayNote(void* pDSP, UInt8 noteNumber, UInt8 velocity, float noteHz)
{
    ((SynthDSP*)pDSP)->playNote(noteNumber, velocity, noteHz);
}

extern "C" void doSynthStopNote(void* pDSP, UInt8 noteNumber, bool immediate)
{
    ((SynthDSP*)pDSP)->stopNote(noteNumber, immediate);
}

extern "C" void doSynthSustainPedal(void* pDSP, bool pedalDown)
{
    ((SynthDSP*)pDSP)->sustainPedal(pedalDown);
}


SynthDSP::SynthDSP() : AudioKitCore::Synth()
{
    masterVolumeRamp.setTarget(1.0, true);
    pitchBendRamp.setTarget(0.0, true);
    vibratoDepthRamp.setTarget(0.0, true);
    filterCutoffRamp.setTarget(1000.0, true);
    filterResonanceRamp.setTarget(1.0, true);
}

void SynthDSP::init(int nChannels, double sampleRate)
{
    AKDSPBase::init(nChannels, sampleRate);
    AudioKitCore::Synth::init(sampleRate);
}

void SynthDSP::deinit()
{
    AudioKitCore::Synth::deinit();
}

void SynthDSP::setParameter(uint64_t address, float value, bool immediate)
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

        case ampAttackDurationParameter:
            ampEGParameters.setAttackDurationSeconds(value);
            break;
        case ampDecayDurationParameter:
            ampEGParameters.setDecayDurationSeconds(value);
            break;
        case ampSustainLevelParameter:
            ampEGParameters.sustainFraction = value;
            break;
        case ampReleaseDurationParameter:
            ampEGParameters.setReleaseDurationSeconds(value);
            break;

        case filterAttackDurationParameter:
            filterEGParameters.setAttackDurationSeconds(value);
            break;
        case filterDecayDurationParameter:
            filterEGParameters.setDecayDurationSeconds(value);
            break;
        case filterSustainLevelParameter:
            filterEGParameters.sustainFraction = value;
            break;
        case filterReleaseDurationParameter:
            filterEGParameters.setReleaseDurationSeconds(value);
            break;
    }
}

float SynthDSP::getParameter(uint64_t address)
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

        case ampAttackDurationParameter:
            return ampEGParameters.getAttackDurationSeconds();
        case ampDecayDurationParameter:
            return ampEGParameters.getDecayDurationSeconds();
        case ampSustainLevelParameter:
            return ampEGParameters.sustainFraction;
        case ampReleaseDurationParameter:
            return ampEGParameters.getReleaseDurationSeconds();

        case filterAttackDurationParameter:
            return filterEGParameters.getAttackDurationSeconds();
        case filterDecayDurationParameter:
            return filterEGParameters.getDecayDurationSeconds();
        case filterSustainLevelParameter:
            return filterEGParameters.sustainFraction;
        case filterReleaseDurationParameter:
            return filterEGParameters.getReleaseDurationSeconds();
    }
    return 0;
}

void SynthDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset)
{
    // process in chunks of maximum length CHUNKSIZE
    for (int frameIndex = 0; frameIndex < frameCount; frameIndex += CHUNKSIZE) {
        int frameOffset = int(frameIndex + bufferOffset);
        int chunkSize = frameCount - frameIndex;
        if (chunkSize > CHUNKSIZE) chunkSize = CHUNKSIZE;
        
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
        outBuffers[0] = (float*)_outBufferListPtr->mBuffers[0].mData + frameOffset;
        outBuffers[1] = (float*)_outBufferListPtr->mBuffers[1].mData + frameOffset;
        unsigned channelCount = _outBufferListPtr->mNumberBuffers;
        AudioKitCore::Synth::Render(channelCount, chunkSize, outBuffers);
    }
}
