//
//  AKSamplerDSP.cpp
//  AudioKit Core
//
//  Created by Shane Dunne, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import "AKSamplerDSP.hpp"
#include "wavpack.h"
#include <math.h>

extern "C" void* createAKSamplerDSP(int nChannels, double sampleRate) {
    return new AKSamplerDSP();
}

extern "C" void doAKSamplerLoadData(void* pDSP, AKSampleDataDescriptor* pSDD) {
    ((AKSamplerDSP*)pDSP)->loadSampleData(*pSDD);
}

extern "C" void doAKSamplerLoadCompressedFile(void* pDSP, AKSampleFileDescriptor* pSFD)
{
    char errMsg[100];
    WavpackContext* wpc = WavpackOpenFileInput(pSFD->path, errMsg, OPEN_2CH_MAX, 0);
    if (wpc == 0)
    {
        printf("Wavpack error loading %s: %s\n", pSFD->path, errMsg);
        return;
    }
    
    AKSampleDataDescriptor sdd;
    sdd.sampleDescriptor = pSFD->sampleDescriptor;
    sdd.sampleRate = (float)WavpackGetSampleRate(wpc);
    sdd.channelCount = WavpackGetReducedChannels(wpc);
    sdd.sampleCount = WavpackGetNumSamples(wpc);
    sdd.isInterleaved = sdd.channelCount > 1;
    sdd.data = new float[sdd.channelCount * sdd.sampleCount];
    
    int mode = WavpackGetMode(wpc);
    WavpackUnpackSamples(wpc, (int32_t*)sdd.data, sdd.sampleCount);
    if ((mode & MODE_FLOAT) == 0)
    {
        // convert samples to floating-point
        int bps = WavpackGetBitsPerSample(wpc);
        float scale = 1.0f / (1 << (bps - 1));
        float* pf = sdd.data;
        int32_t* pi = (int32_t*)pf;
        for (int i = 0; i < (sdd.sampleCount * sdd.channelCount); i++)
            *pf++ = scale * *pi++;
    }
    
    ((AKSamplerDSP*)pDSP)->loadSampleData(sdd);
    delete[] sdd.data;
}

extern "C" void doAKSamplerUnloadAllSamples(void* pDSP)
{
    ((AKSamplerDSP*)pDSP)->deinit();
}

extern "C" void doAKSamplerBuildSimpleKeyMap(void* pDSP) {
    ((AKSamplerDSP*)pDSP)->buildSimpleKeyMap();
}

extern "C" void doAKSamplerBuildKeyMap(void* pDSP) {
    ((AKSamplerDSP*)pDSP)->buildKeyMap();
}

extern "C" void doAKSamplerSetLoopThruRelease(void* pDSP, bool value) {
    ((AKSamplerDSP*)pDSP)->setLoopThruRelease(value);
}

extern "C" void doAKSamplerPlayNote(void* pDSP, UInt8 noteNumber, UInt8 velocity, float noteFrequency)
{
    ((AKSamplerDSP*)pDSP)->playNote(noteNumber, velocity, noteFrequency);
}

extern "C" void doAKSamplerStopNote(void* pDSP, UInt8 noteNumber, bool immediate)
{
    ((AKSamplerDSP*)pDSP)->stopNote(noteNumber, immediate);
}

extern "C" void doAKSamplerStopAllVoices(void* pDSP)
{
    ((AKSamplerDSP*)pDSP)->stopAllVoices();
}

extern "C" void doAKSamplerRestartVoices(void* pDSP)
{
    ((AKSamplerDSP*)pDSP)->restartVoices();
}

extern "C" void doAKSamplerSustainPedal(void* pDSP, bool pedalDown)
{
    ((AKSamplerDSP*)pDSP)->sustainPedal(pedalDown);
}


AKSamplerDSP::AKSamplerDSP() : AudioKitCore::Sampler()
{
    masterVolumeRamp.setTarget(1.0, true);
    pitchBendRamp.setTarget(0.0, true);
    vibratoDepthRamp.setTarget(0.0, true);
    filterCutoffRamp.setTarget(4, true);
    filterEgStrengthRamp.setTarget(20.0f, true);
    filterResonanceRamp.setTarget(1.0, true);
}

void AKSamplerDSP::init(int nChannels, double sampleRate)
{
    AKDSPBase::init(nChannels, sampleRate);
    AudioKitCore::Sampler::init(sampleRate);
}

void AKSamplerDSP::deinit()
{
    AudioKitCore::Sampler::deinit();
}

void AKSamplerDSP::setParameter(AUParameterAddress address, float value, bool immediate)
{
    switch (address) {
        case AKSamplerParameterRampDuration:
            masterVolumeRamp.setRampDuration(value, _sampleRate);
            pitchBendRamp.setRampDuration(value, _sampleRate);
            vibratoDepthRamp.setRampDuration(value, _sampleRate);
            filterCutoffRamp.setRampDuration(value, _sampleRate);
            filterEgStrengthRamp.setRampDuration(value, _sampleRate);
            filterResonanceRamp.setRampDuration(value, _sampleRate);
            break;

        case AKSamplerParameterMasterVolume:
            masterVolumeRamp.setTarget(value, immediate);
            break;
        case AKSamplerParameterPitchBend:
            pitchBendRamp.setTarget(value, immediate);
            break;
        case AKSamplerParameterVibratoDepth:
            vibratoDepthRamp.setTarget(value, immediate);
            break;
        case AKSamplerParameterFilterCutoff:
            filterCutoffRamp.setTarget(value, immediate);
            break;
        case AKSamplerParameterFilterEgStrength:
            filterEgStrengthRamp.setTarget(value, immediate);
            break;
        case AKSamplerParameterFilterResonance:
            filterResonanceRamp.setTarget(pow(10.0, -0.05 * value), immediate);
            break;

        case AKSamplerParameterAttackDuration:
            ampEGParams.setAttackTimeSeconds(value);
            break;
        case AKSamplerParameterDecayDuration:
            ampEGParams.setDecayTimeSeconds(value);
            break;
        case AKSamplerParameterSustainLevel:
            ampEGParams.sustainFraction = value;
            break;
        case AKSamplerParameterReleaseDuration:
            ampEGParams.setReleaseTimeSeconds(value);
            break;

        case AKSamplerParameterFilterAttackDuration:
            filterEGParams.setAttackTimeSeconds(value);
            break;
        case AKSamplerParameterFilterDecayDuration:
            filterEGParams.setDecayTimeSeconds(value);
            break;
        case AKSamplerParameterFilterSustainLevel:
            filterEGParams.sustainFraction = value;
            break;
        case AKSamplerParameterFilterReleaseDuration:
            filterEGParams.setReleaseTimeSeconds(value);
            break;
        case AKSamplerParameterFilterEnable:
            filterEnable = value > 0.5f;
            break;
    }
}

float AKSamplerDSP::getParameter(AUParameterAddress address)
{
    switch (address) {
        case AKSamplerParameterRampDuration:
            return pitchBendRamp.getRampDuration(_sampleRate);

        case AKSamplerParameterMasterVolume:
            return masterVolumeRamp.getTarget();
        case AKSamplerParameterPitchBend:
            return pitchBendRamp.getTarget();
        case AKSamplerParameterVibratoDepth:
            return vibratoDepthRamp.getTarget();
        case AKSamplerParameterFilterCutoff:
            return filterCutoffRamp.getTarget();
        case AKSamplerParameterFilterEgStrength:
            return filterEgStrengthRamp.getTarget();
        case AKSamplerParameterFilterResonance:
            return -20.0f * log10(filterResonanceRamp.getTarget());

        case AKSamplerParameterAttackDuration:
            return ampEGParams.getAttackTimeSeconds();
        case AKSamplerParameterDecayDuration:
            return ampEGParams.getDecayTimeSeconds();
        case AKSamplerParameterSustainLevel:
            return ampEGParams.sustainFraction;
        case AKSamplerParameterReleaseDuration:
            return ampEGParams.getReleaseTimeSeconds();

        case AKSamplerParameterFilterAttackDuration:
            return filterEGParams.getAttackTimeSeconds();
        case AKSamplerParameterFilterDecayDuration:
            return filterEGParams.getDecayTimeSeconds();
        case AKSamplerParameterFilterSustainLevel:
            return filterEGParams.sustainFraction;
        case AKSamplerParameterFilterReleaseDuration:
            return filterEGParams.getReleaseTimeSeconds();
        case AKSamplerParameterFilterEnable:
            return filterEnable ? 1.0f : 0.0f;
    }
    return 0;
}

void AKSamplerDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset)
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
        filterEgStrengthRamp.advanceTo(_now + frameOffset);
        cutoffEgStrength = (float)filterEgStrengthRamp.getValue();
        filterResonanceRamp.advanceTo(_now + frameOffset);
        resLinear = (float)filterResonanceRamp.getValue();

        // get data
        float *outBuffers[2];
        outBuffers[0] = (float*)_outBufferListPtr->mBuffers[0].mData + frameOffset;
        outBuffers[1] = (float*)_outBufferListPtr->mBuffers[1].mData + frameOffset;
        unsigned channelCount = _outBufferListPtr->mNumberBuffers;
        AudioKitCore::Sampler::Render(channelCount, chunkSize, outBuffers);
    }
}
