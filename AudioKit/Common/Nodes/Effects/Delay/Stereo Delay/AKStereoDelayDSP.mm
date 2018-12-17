//
//  AKStereoDelayDSP.mm
//  AudioKit
//
//  Created by Shane Dunne, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKStereoDelayDSP.hpp"
#include "StereoDelay.hpp"
#include "DSPKernel.hpp" // for clamp()

extern "C" AKDSPRef createStereoDelayDSP(int nChannels, double sampleRate) {
    AKStereoDelayDSP *dsp = new AKStereoDelayDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}

struct AKStereoDelayDSP::_Internal {
    AudioKitCore::StereoDelay delay;

    AKLinearParameterRamp timeRamp;
    AKLinearParameterRamp feedbackRamp;
    AKLinearParameterRamp dryWetMixRamp;
    
};

AKStereoDelayDSP::AKStereoDelayDSP() : _private(new _Internal) {
    _private->timeRamp.setTarget(defaultTime, true);
    _private->timeRamp.setDurationInSamples(defaultRampDurationSamples);
    _private->feedbackRamp.setTarget(defaultFeedback, true);
    _private->feedbackRamp.setDurationInSamples(defaultRampDurationSamples);
    _private->dryWetMixRamp.setTarget(defaultDryWetMix, true);
    _private->dryWetMixRamp.setDurationInSamples(defaultRampDurationSamples);
}

// Uses the ParameterAddress as a key
void AKStereoDelayDSP::setParameter(AUParameterAddress address, AUValue value, bool immediate) {
    switch (address) {
        case AKStereoDelayParameterTime:
            _private->timeRamp.setTarget(clamp(value, timeLowerBound, timeUpperBound), immediate);
            break;
        case AKStereoDelayParameterFeedback:
            _private->feedbackRamp.setTarget(clamp(value, feedbackLowerBound, feedbackUpperBound), immediate);
            break;
        case AKStereoDelayParameterDryWetMix:
            _private->dryWetMixRamp.setTarget(clamp(value, dryWetMixLowerBound, dryWetMixUpperBound), immediate);
            break;
        case AKStereoDelayParameterPingPong:
            _private->delay.setPingPongMode(value > 0.5f);
            break;
        case AKStereoDelayParameterRampDuration:
            _private->timeRamp.setRampDuration(value, _sampleRate);
            _private->feedbackRamp.setRampDuration(value, _sampleRate);
            _private->dryWetMixRamp.setRampDuration(value, _sampleRate);
            break;
    }
}

// Uses the ParameterAddress as a key
float AKStereoDelayDSP::getParameter(uint64_t address) {
    switch (address) {
        case AKStereoDelayParameterTime:
            return _private->timeRamp.getTarget();
        case AKStereoDelayParameterFeedback:
            return _private->feedbackRamp.getTarget();
        case AKStereoDelayParameterDryWetMix:
            return _private->dryWetMixRamp.getTarget();
        case AKStereoDelayParameterPingPong:
            return _private->delay.getPingPongMode() ? 1.0f : 0.0f;
        case AKStereoDelayParameterRampDuration:
            return _private->timeRamp.getRampDuration(_sampleRate);
    }
    return 0;
}

void AKStereoDelayDSP::init(int _channels, double _sampleRate) {
    // TODO add something to handle 1 vs 2 channels
    _private->delay.init(_sampleRate, timeUpperBound * 1000.0);
}

void AKStereoDelayDSP::deinit() {
    _private->delay.deinit();
}

void AKStereoDelayDSP::clear() {
    _private->delay.clear();
}

#define CHUNKSIZE 8     // defines ramp interval

void AKStereoDelayDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset)
{
    const float *inBuffers[2];
    float *outBuffers[2];
    inBuffers[0]  = (const float *)_inBufferListPtr->mBuffers[0].mData  + bufferOffset;
    inBuffers[1]  = (const float *)_inBufferListPtr->mBuffers[1].mData  + bufferOffset;
    outBuffers[0] = (float *)_outBufferListPtr->mBuffers[0].mData + bufferOffset;
    outBuffers[1] = (float *)_outBufferListPtr->mBuffers[1].mData + bufferOffset;
    //unsigned inChannelCount = _inBufferListPtr->mNumberBuffers;
    //unsigned outChannelCount = _outBufferListPtr->mNumberBuffers;

    if (!_playing)
    {
        // effect bypassed: just copy input to output
        memcpy(outBuffers[0], inBuffers[0], frameCount * sizeof(float));
        memcpy(outBuffers[1], inBuffers[1], frameCount * sizeof(float));
        return;
    }

    // process in chunks of maximum length CHUNKSIZE
    for (int frameIndex = 0; frameIndex < frameCount; frameIndex += CHUNKSIZE)
    {
        int frameOffset = int(frameIndex + bufferOffset);
        int chunkSize = frameCount - frameIndex;
        if (chunkSize > CHUNKSIZE) chunkSize = CHUNKSIZE;
        
        // ramp parameters
        _private->timeRamp.advanceTo(_now + frameOffset);
        _private->feedbackRamp.advanceTo(_now + frameOffset);
        _private->dryWetMixRamp.advanceTo(_now + frameOffset);
        
        // apply changes
        _private->delay.setDelayMs(1000.0 * _private->timeRamp.getValue());
        _private->delay.setFeedback(_private->feedbackRamp.getValue());
        _private->delay.setDryWetMix(_private->dryWetMixRamp.getValue());

        // process
        _private->delay.render(chunkSize, inBuffers, outBuffers);
        
        // advance pointers
        inBuffers[0] += chunkSize;
        inBuffers[1] += chunkSize;
        outBuffers[0] += chunkSize;
        outBuffers[1] += chunkSize;
    }
}
