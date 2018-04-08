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
    sdd.sd = pSFD->sd;
    sdd.sampleRateHz = (float)WavpackGetSampleRate(wpc);
    sdd.nChannels = WavpackGetReducedChannels(wpc);
    sdd.nSamples = WavpackGetNumSamples(wpc);
    sdd.bInterleaved = sdd.nChannels > 1;
    sdd.pData = new float[sdd.nChannels * sdd.nSamples];
    
    int mode = WavpackGetMode(wpc);
    WavpackUnpackSamples(wpc, (int32_t*)sdd.pData, sdd.nSamples);
    if ((mode & MODE_FLOAT) == 0)
    {
        // convert samples to floating-point
        int bps = WavpackGetBitsPerSample(wpc);
        float scale = 1.0f / (1 << (bps - 1));
        float* pf = sdd.pData;
        int32_t* pi = (int32_t*)pf;
        for (int i = 0; i < (sdd.nSamples * sdd.nChannels); i++)
            *pf++ = scale * *pi++;
    }
    
    ((AKSamplerDSP*)pDSP)->loadSampleData(sdd);
    delete[] sdd.pData;
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

extern "C" void doAKSamplerPlayNote(void* pDSP, UInt8 noteNumber, UInt8 velocity, float noteHz)
{
    ((AKSamplerDSP*)pDSP)->playNote(noteNumber, velocity, noteHz);
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

void AKSamplerDSP::setParameter(uint64_t address, float value, bool immediate)
{
    switch (address) {
        case rampTimeParam:
            masterVolumeRamp.setRampTime(value, _sampleRate);
            pitchBendRamp.setRampTime(value, _sampleRate);
            vibratoDepthRamp.setRampTime(value, _sampleRate);
            filterCutoffRamp.setRampTime(value, _sampleRate);
            filterEgStrengthRamp.setRampTime(value, _sampleRate);
            filterResonanceRamp.setRampTime(value, _sampleRate);
            break;

        case masterVolumeParam:
            masterVolumeRamp.setTarget(value, immediate);
            break;
        case pitchBendParam:
            pitchBendRamp.setTarget(value, immediate);
            break;
        case vibratoDepthParam:
            vibratoDepthRamp.setTarget(value, immediate);
            break;
        case filterCutoffParam:
            filterCutoffRamp.setTarget(value, immediate);
            break;
        case filterEgStrengthParam:
            filterEgStrengthRamp.setTarget(value, immediate);
            break;
        case filterResonanceParam:
            filterResonanceRamp.setTarget(pow(10.0, -0.05 * value), immediate);
            break;

        case ampAttackTimeParam:
            ampEGParams.setAttackTimeSeconds(value);
            break;
        case ampDecayTimeParam:
            ampEGParams.setDecayTimeSeconds(value);
            break;
        case ampSustainLevelParam:
            ampEGParams.sustainFraction = value;
            break;
        case ampReleaseTimeParam:
            ampEGParams.setReleaseTimeSeconds(value);
            break;

        case filterAttackTimeParam:
            filterEGParams.setAttackTimeSeconds(value);
            break;
        case filterDecayTimeParam:
            filterEGParams.setDecayTimeSeconds(value);
            break;
        case filterSustainLevelParam:
            filterEGParams.sustainFraction = value;
            break;
        case filterReleaseTimeParam:
            filterEGParams.setReleaseTimeSeconds(value);
            break;
        case filterEnableParam:
            filterEnable = value > 0.5f;
            break;
    }
}

float AKSamplerDSP::getParameter(uint64_t address)
{
    switch (address) {
        case rampTimeParam:
            return pitchBendRamp.getRampTime(_sampleRate);

        case masterVolumeParam:
            return masterVolumeRamp.getTarget();
        case pitchBendParam:
            return pitchBendRamp.getTarget();
        case vibratoDepthParam:
            return vibratoDepthRamp.getTarget();
        case filterCutoffParam:
            return filterCutoffRamp.getTarget();
        case filterEgStrengthParam:
            return filterEgStrengthRamp.getTarget();
        case filterResonanceParam:
            return -20.0f * log10(filterResonanceRamp.getTarget());

        case ampAttackTimeParam:
            return ampEGParams.getAttackTimeSeconds();
        case ampDecayTimeParam:
            return ampEGParams.getDecayTimeSeconds();
        case ampSustainLevelParam:
            return ampEGParams.sustainFraction;
        case ampReleaseTimeParam:
            return ampEGParams.getReleaseTimeSeconds();

        case filterAttackTimeParam:
            return filterEGParams.getAttackTimeSeconds();
        case filterDecayTimeParam:
            return filterEGParams.getDecayTimeSeconds();
        case filterSustainLevelParam:
            return filterEGParams.sustainFraction;
        case filterReleaseTimeParam:
            return filterEGParams.getReleaseTimeSeconds();
        case filterEnableParam:
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
