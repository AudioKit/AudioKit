//
//  AKDSPBase.cpp
//  AudioKit
//
//  Created by Stéphane Peter, revision history on Githbub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import "AKDSPBase.hpp"
#import "ParameterRamper.hpp"

extern "C" AUInternalRenderBlock internalRenderBlockDSP(AKDSPRef pDSP)
{
    return pDSP->internalRenderBlock();
}

extern "C" size_t inputBusCountDSP(AKDSPRef pDSP)
{
    return pDSP->inputBufferLists.size();
}

extern "C" size_t outputBusCountDSP(AKDSPRef pDSP)
{
    return pDSP->outputBufferLists.size();
}

extern "C" bool canProcessInPlaceDSP(AKDSPRef pDSP)
{
    return pDSP->canProcessInPlace();
}

extern "C" void setBufferDSP(AKDSPRef pDSP, AVAudioPCMBuffer* buffer, size_t busIndex)
{
    pDSP->setBuffer(buffer, busIndex);
}

extern "C" void allocateRenderResourcesDSP(AKDSPRef pDSP, AVAudioFormat* format)
{
    pDSP->init(format.channelCount, format.sampleRate);
}

extern "C" void deallocateRenderResourcesDSP(AKDSPRef pDSP)
{
    pDSP->deinit();
}

extern "C" void resetDSP(AKDSPRef pDSP)
{
    pDSP->reset();
}

extern "C" void setParameterValueDSP(AKDSPRef pDSP, AUParameterAddress address, AUValue value)
{
    pDSP->setParameter(address, value, false);
}

extern "C" AUValue getParameterValueDSP(AKDSPRef pDSP, AUParameterAddress address)
{
    return pDSP->getParameter(address);
}

extern "C" void setParameterRampDurationDSP(AKDSPRef pDSP, AUParameterAddress address, float rampDuration)
{
    pDSP->setParameterRampDuration(address, rampDuration);
}

extern "C" void setParameterRampTaperDSP(AKDSPRef pDSP, AUParameterAddress address, float taper)
{
    pDSP->setParameterRampTaper(address, taper);
}

extern "C" void setParameterRampSkewDSP(AKDSPRef pDSP, AUParameterAddress address, float skew)
{
    pDSP->setParameterRampSkew(address, skew);
}

extern "C" void startDSP(AKDSPRef pDSP)
{
    pDSP->start();
}

extern "C" void stopDSP(AKDSPRef pDSP)
{
    pDSP->stop();
}

extern "C" void triggerDSP(AKDSPRef pDSP)
{
    pDSP->trigger();
}

extern "C" void triggerFrequencyDSP(AKDSPRef pDSP, AUValue frequency, AUValue amplitude)
{
    pDSP->triggerFrequencyAmplitude(frequency, amplitude);
}

extern "C" void setWavetableDSP(AKDSPRef pDSP, const float* table, size_t length, int index)
{
    pDSP->setWavetable(table, length, index);
}

extern "C" void deleteDSP(AKDSPRef pDSP)
{
    delete pDSP;
}

AKDSPBase::AKDSPBase()
: channelCount(2)   // best guess
, sampleRate(44100) // best guess
, inputBufferLists(1)
, outputBufferLists(1)
{
}

void AKDSPBase::setBuffer(const AVAudioPCMBuffer* buffer, size_t busIndex)
{
    if (internalBuffers.size() <= busIndex) internalBuffers.resize(busIndex + 1);
    internalBuffers[busIndex] = buffer;
}

AUInternalRenderBlock AKDSPBase::internalRenderBlock()
{
    return ^AUAudioUnitStatus(
        AudioUnitRenderActionFlags *actionFlags,
        const AudioTimeStamp       *timestamp,
        AUAudioFrameCount           frameCount,
        NSInteger                   outputBusNumber,
        AudioBufferList            *outputData,
        const AURenderEvent        *realtimeEventListHead,
        AURenderPullInputBlock      pullInputBlock)
    {
        if (pullInputBlock) {
            if (bCanProcessInPlace && inputBufferLists.size() == 1) {
                // pull input directly to output buffer
                inputBufferLists[0] = outputData;
                AudioUnitRenderActionFlags inputFlags = 0;
                pullInputBlock(&inputFlags, timestamp, frameCount, 0, inputBufferLists[0]);
            }
            else {
                // pull input to internal buffer
                for (size_t i = 0; i < inputBufferLists.size(); i++) {
                    inputBufferLists[i] = internalBuffers[i].mutableAudioBufferList;
                    
                    UInt32 byteSize = frameCount * sizeof(float);
                    inputBufferLists[i]->mNumberBuffers = internalBuffers[i].audioBufferList->mNumberBuffers;
                    for (UInt32 ch = 0; ch < inputBufferLists[i]->mNumberBuffers; ch++) {
                        inputBufferLists[i]->mBuffers[ch].mDataByteSize = byteSize;
                        inputBufferLists[i]->mBuffers[ch].mNumberChannels = internalBuffers[i].audioBufferList->mBuffers[ch].mNumberChannels;
                        inputBufferLists[i]->mBuffers[ch].mData = internalBuffers[i].audioBufferList->mBuffers[ch].mData;
                    }
                    
                    AudioUnitRenderActionFlags inputFlags = 0;
                    pullInputBlock(&inputFlags, timestamp, frameCount, i, inputBufferLists[i]);
                }
            }
        }
        
        outputBufferLists[0] = outputData;
        
        processWithEvents(timestamp, frameCount, realtimeEventListHead);
        
        return noErr;
    };
}

void AKDSPBase::setParameter(AUParameterAddress address, float value, bool immediate)
{
    const auto& parameter = parameters.find(address);
    if (parameter == parameters.cend()) return;
    
    if (immediate || !isInitialized) {
        parameter->second->setImmediate(value);
    }
    else {
        parameter->second->setUIValue(value);
        parameter->second->dezipperCheck();
    }
}

float AKDSPBase::getParameter(AUParameterAddress address)
{
    const auto& parameter = parameters.find(address);
    if (parameter == parameters.cend()) return 0.f;
    return parameter->second->getUIValue();
}

void AKDSPBase::init(int channelCount, double sampleRate)
{
    this->channelCount = channelCount;
    this->sampleRate = sampleRate;
    isInitialized = true;
    
    // update parameter ramp durations with new sample rate
    for (const auto& parameter : parameters) parameter.second->init(sampleRate);
}

void AKDSPBase::deinit()
{
    isInitialized = false;
}

void AKDSPBase::setParameterRampDuration(AUParameterAddress address, float duration)
{
    const auto& parameter = parameters.find(address);
    if (parameter == parameters.cend()) return;
    parameter->second->setDefaultRampDuration(duration);
}

void AKDSPBase::setParameterRampTaper(AUParameterAddress address, float taper)
{
    const auto& parameter = parameters.find(address);
    if (parameter == parameters.cend()) return;
    parameter->second->setTaper(taper);
}

void AKDSPBase::setParameterRampSkew(AUParameterAddress address, float skew)
{
    const auto& parameter = parameters.find(address);
    if (parameter == parameters.cend()) return;
    parameter->second->setSkew(skew);
}

void AKDSPBase::processWithEvents(AudioTimeStamp const *timestamp, AUAudioFrameCount frameCount,
                                  AURenderEvent const *events)
{
    now = timestamp->mSampleTime;

    AUAudioFrameCount framesRemaining = frameCount;
    AURenderEvent const *event = events;

    while (framesRemaining > 0) {
        // If there are no more events, we can process the entire remaining segment and exit.
        if (event == nullptr) {
            AUAudioFrameCount const bufferOffset = frameCount - framesRemaining;
            process(framesRemaining, bufferOffset);
            return;
        }

        // start late events late.
        auto timeZero = AUEventSampleTime(0);
        auto headEventTime = event->head.eventSampleTime;
        AUAudioFrameCount const framesThisSegment = AUAudioFrameCount(std::max(timeZero, headEventTime - now));

        // Compute everything before the next event.
        if (framesThisSegment > 0) {
            AUAudioFrameCount const bufferOffset = frameCount - framesRemaining;
            process(framesThisSegment, bufferOffset);

            // Advance frames.
            framesRemaining -= framesThisSegment;
            // Advance time.
            now += framesThisSegment;
        }
        performAllSimultaneousEvents(now, event);
    }
    
}

/** From Apple Example code */
void AKDSPBase::performAllSimultaneousEvents(AUEventSampleTime now, AURenderEvent const *&event)
{
    do {
        handleOneEvent(event);
        event = event->head.next;

        // While event is not null and is simultaneous (or late).
    } while (event && event->head.eventSampleTime <= now);
}

/** From Apple Example code */
void AKDSPBase::handleOneEvent(AURenderEvent const *event)
{
    switch (event->head.eventType) {
        case AURenderEventParameter:
        case AURenderEventParameterRamp: {
            startRamp(event->parameter);
            break;
        }
        case AURenderEventMIDI:
            handleMIDIEvent(event->MIDI);
            break;
        default:
            break;
    }
}

void AKDSPBase::startRamp(const AUParameterEvent& event)
{
    const auto& parameterIter = parameters.find(event.parameterAddress & 0xFFFFFFFF);
    if (parameterIter == parameters.cend()) return;
    
    auto& ramper = parameterIter->second;
    switch (event.parameterAddress >> 61) {
        case 0x4: // taper
            ramper->setTaper(event.value);
            break;
        case 0x2: // skew
            ramper->setSkew(event.value);
            break;
        case 0x1: // offset
            ramper->setOffset(event.rampDurationSampleFrames);
            break;
        case 0x0:
            ramper->startRamp(event.value, event.rampDurationSampleFrames);
    }
}
