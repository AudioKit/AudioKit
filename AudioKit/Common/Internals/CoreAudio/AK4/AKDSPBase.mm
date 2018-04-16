//
//  AKDSPBase.cpp
//  AudioKit
//
//  Created by Stéphane Peter, revision history on Githbub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import "AKDSPBase.hpp"

void AKDSPBase::processWithEvents(AudioTimeStamp const *timestamp, AUAudioFrameCount frameCount,
                                  AURenderEvent const *events)
{
    _now = timestamp->mSampleTime;
    AUAudioFrameCount framesRemaining = frameCount;
    AURenderEvent const *event = events;
    
    while (framesRemaining > 0) {
        // If there are no more events, we can process the entire remaining segment and exit.
        if (event == nullptr) {
            AUAudioFrameCount const bufferOffset = frameCount - framesRemaining;
            process(framesRemaining, bufferOffset);
            return;
        }
        
        // **** start late events late.
        auto timeZero = AUEventSampleTime(0);
        auto headEventTime = event->head.eventSampleTime;
        AUAudioFrameCount const framesThisSegment = AUAudioFrameCount(std::max(timeZero, headEventTime - _now));
        
        // Compute everything before the next event.
        if (framesThisSegment > 0) {
            AUAudioFrameCount const bufferOffset = frameCount - framesRemaining;
            process(framesThisSegment, bufferOffset);
            
            // Advance frames.
            framesRemaining -= framesThisSegment;
            // Advance time.
            _now += framesThisSegment;
        }
        performAllSimultaneousEvents(_now, event);
    }
}

/** From Apple Example code */
void AKDSPBase::handleOneEvent(AURenderEvent const *event) {
    switch (event->head.eventType) {
        case AURenderEventParameter:
        case AURenderEventParameterRamp: {
            // AUParameterEvent const& paramEvent = event->parameter;
            // startRamp(paramEvent.parameterAddress, paramEvent.value, paramEvent.rampDurationSampleFrames);
            break;
        }
        case AURenderEventMIDI:
            // handleMIDIEvent(event->MIDI);
            break;
        default:
            break;
    }
}

/** From Apple Example code */
void AKDSPBase::performAllSimultaneousEvents(AUEventSampleTime now, AURenderEvent const *&event) {
    do {
        handleOneEvent(event);
        event = event->head.next;
        // While event is not null and is simultaneous (or late).
    } while (event && event->head.eventSampleTime <= now);
}
