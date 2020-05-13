//
//  AKDSPBase.cpp
//  AudioKit
//
//  Created by Stéphane Peter, revision history on Githbub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import "AKDSPBase.hpp"
#import "AKParameterRampBase.hpp"

extern "C" AUInternalRenderBlock internalRenderBlockDSP(AKDSPRef pDSP)
{
    return pDSP->internalRenderBlock();
}

extern "C" void allocateRenderResourcesDSP(AKDSPRef pDSP, AVAudioFormat* format, AVAudioPCMBuffer* buffer)
{
    pDSP->setBuffers(buffer);
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

extern "C" bool canProcessInPlaceDSP(AKDSPRef pDSP)
{
    return pDSP->canProcessInPlace();
}

extern "C" void setRampDurationDSP(AKDSPRef pDSP, float rampDuration)
{
    pDSP->setRampDuration(rampDuration);
}

extern "C" void setParameterDSP(AKDSPRef pDSP, AUParameterAddress address, AUValue value)
{
    pDSP->setParameter(address, value, false);
}

extern "C" AUValue getParameterDSP(AKDSPRef pDSP, AUParameterAddress address)
{
    return pDSP->getParameter(address);
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
: sampleRate(44100) // best guess
, channelCount(2)   // best guess
{
}

void AKDSPBase::setBuffers(const AVAudioPCMBuffer* buffer)
{
    internalBuffer = buffer;
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
            if (bCanProcessInPlace) {
                // pull input directly to output buffer
                inBufferListPtr = outputData;
            }
            else {
                // pull input to internal buffer
                inBufferListPtr = internalBuffer.mutableAudioBufferList;
                
                UInt32 byteSize = frameCount * sizeof(float);
                inBufferListPtr->mNumberBuffers = internalBuffer.audioBufferList->mNumberBuffers;
                for (UInt32 i = 0; i < inBufferListPtr->mNumberBuffers; i++) {
                    inBufferListPtr->mBuffers[i].mDataByteSize = byteSize;
                    inBufferListPtr->mBuffers[i].mNumberChannels = internalBuffer.audioBufferList->mBuffers[i].mNumberChannels;
                    inBufferListPtr->mBuffers[i].mData = internalBuffer.audioBufferList->mBuffers[i].mData;
                }
            }
            
            AudioUnitRenderActionFlags inputFlags = 0;
            pullInputBlock(&inputFlags, timestamp, frameCount, 0, inBufferListPtr);
        }
        
        outBufferListPtr = outputData;
        
        processWithEvents(timestamp, frameCount, realtimeEventListHead);
        
        return noErr;
    };
}

void AKDSPBase::setRampDuration(float duration)
{
    rampDuration = duration;
    if (isInitialized) {
        for (const auto& parameter : parameters) {
            parameter.second->setRampDuration(rampDuration, sampleRate);
        }
    }
}

void AKDSPBase::setParameter(AUParameterAddress address, float value, bool immediate)
{
    const auto& parameter = parameters.find(address);
    if (parameter == parameters.cend()) return;
    parameter->second->setTarget(value, immediate || !isInitialized);
}

float AKDSPBase::getParameter(AUParameterAddress address)
{
    const auto& parameter = parameters.find(address);
    if (parameter == parameters.cend()) return 0.f;
    return parameter->second->getTarget();
}

void AKDSPBase::init(int channelCount, double sampleRate)
{
    this->channelCount = channelCount;
    this->sampleRate = sampleRate;
    isInitialized = true;
    
    // update parameter ramp durations with new sample rate
    setRampDuration(rampDuration);
}

void AKDSPBase::deinit()
{
    internalBuffer = nullptr;
    isInitialized = false;
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
            AUParameterEvent const& paramEvent = event->parameter;

            // virtual method, will work if subclass implements it
            // See: AKFaderDSP
            startRamp(paramEvent.parameterAddress, paramEvent.value, paramEvent.rampDurationSampleFrames);
            break;
        }
        case AURenderEventMIDI:
            handleMIDIEvent(event->MIDI);
            break;
        default:
            break;
    }
}
