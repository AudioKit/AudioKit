//
//  AKSamplerDSP.cpp
//  ExtendingAudioKit
//
//  Created by Shane Dunne on 2018-02-19.
//  Copyright © 2018 Shane Dunne & Associates. All rights reserved.
//

#import "AKSamplerDSP.hpp"

extern "C" void* createAKSamplerDSP(int nChannels, double sampleRate) {
    return new AKSamplerDSP();
}

extern "C" void doAKSamplerLoadData(void* pDSP, AKSampleDataDescriptor* pSDD) {
    ((AKSamplerDSP*)pDSP)->loadSampleData(*pSDD);
}

extern "C" void doAKSamplerLoadCompressedFile(void* pDSP, AKSampleFileDescriptor* pSFD)
{
    ((AKSamplerDSP*)pDSP)->loadCompressedSampleFile(*pSFD);
}

extern "C" void doAKSamplerBuildSimpleKeyMap(void* pDSP) {
    ((AKSamplerDSP*)pDSP)->buildSimpleKeyMap();
}

extern "C" void doAKSamplerBuildKeyMap(void* pDSP) {
    ((AKSamplerDSP*)pDSP)->buildKeyMap();
}

extern "C" void doAKSamplerPlayNote(void* pDSP, UInt8 noteNumber, UInt8 velocity, float noteHz)
{
    ((AKSamplerDSP*)pDSP)->playNote(noteNumber, velocity, noteHz);
}

extern "C" void doAKSamplerStopNote(void* pDSP, UInt8 noteNumber, bool immediate)
{
    ((AKSamplerDSP*)pDSP)->stopNote(noteNumber, immediate);
}

AKSamplerDSP::AKSamplerDSP() : AKSampler()
{
    pitchBendRamp.setTarget(0.0, true);
    vibratoDepthRamp.setTarget(0.0, true);
}

void AKSamplerDSP::init(int nChannels, double sampleRate)
{
    AKDSPBase::init(nChannels, sampleRate);
    AKSampler::init();
}

void AKSamplerDSP::deinit()
{
    AKSampler::deinit();
}

void AKSamplerDSP::setParameter(uint64_t address, float value, bool immediate)
{
    switch (address) {
        case rampTimeParam:
            pitchBendRamp.setRampTime(value, _sampleRate);
            vibratoDepthRamp.setRampTime(value, _sampleRate);
            break;

        case pitchBendParam:
            pitchBendRamp.setTarget(value, immediate);
            break;
        case vibratoDepthParam:
            vibratoDepthRamp.setTarget(value, immediate);
            break;

        case ampAttackTimeParam:
            ampAttackTime = value;
            updateAmpADSR();
            break;
        case ampDecayTimeParam:
            ampDecayTime = value;
            updateAmpADSR();
            break;
        case ampSustainLevelParam:
            ampSustainLevel = value;
            updateAmpADSR();
            break;
        case ampReleaseTimeParam:
            ampReleaseTime = value;
            updateAmpADSR();
            break;

        case filterAttackTimeParam:
            filterAttackTime = value;
            updateFilterADSR();
            break;
        case filterDecayTimeParam:
            filterDecayTime = value;
            updateFilterADSR();
            break;
        case filterSustainLevelParam:
            filterSustainLevel = value;
            updateFilterADSR();
            break;
        case filterReleaseTimeParam:
            filterReleaseTime = value;
            updateFilterADSR();
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

        case pitchBendParam:
            return pitchBendRamp.getTarget();
        case vibratoDepthParam:
            return vibratoDepthRamp.getTarget();

        case ampAttackTimeParam:
            return ampAttackTime;
        case ampDecayTimeParam:
            return ampDecayTime;
        case ampSustainLevelParam:
            return ampSustainLevel;
        case ampReleaseTimeParam:
            return ampReleaseTime;

        case filterAttackTimeParam:
            return filterAttackTime;
        case filterDecayTimeParam:
            return filterDecayTime;
        case filterSustainLevelParam:
            return filterSustainLevel;
        case filterReleaseTimeParam:
            return filterReleaseTime;
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
        pitchBendRamp.advanceTo(_now + frameOffset);
        pitchOffset = (float)pitchBendRamp.getValue();
        vibratoDepthRamp.advanceTo(_now + frameOffset);
        vibratoDepth = (float)vibratoDepthRamp.getValue();
        
        // get data
        float *outBuffers[2];
        outBuffers[0] = (float*)_outBufferListPtr->mBuffers[0].mData + frameOffset;
        outBuffers[1] = (float*)_outBufferListPtr->mBuffers[1].mData + frameOffset;
        unsigned channelCount = _outBufferListPtr->mNumberBuffers;
        AKSampler::Render(channelCount, chunkSize, outBuffers);
    }
}
