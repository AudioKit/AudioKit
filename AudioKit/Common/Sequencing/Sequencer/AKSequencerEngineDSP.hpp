// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import <AVFoundation/AVFoundation.h>
#import "AKInterop.h"

typedef NS_ENUM(AUParameterAddress, AKSequencerEngineParameter) {
    AKSequencerEngineParameterTempo,
    AKSequencerEngineParameterLength,
    AKSequencerEngineParameterMaximumPlayCount,
    AKSequencerEngineParameterPosition,
    AKSequencerEngineParameterLoopEnabled
};

AK_API AKDSPRef createAKSequencerEngineDSP(void);

AK_API void sequencerEngineAddMIDIEvent(AKDSPRef dsp, uint8_t status, uint8_t data1, uint8_t data2, double beat);
AK_API void sequencerEngineAddMIDINote(AKDSPRef dsp, uint8_t noteNumber, uint8_t velocity, double beat, double duration);
AK_API void sequencerEngineRemoveMIDIEvent(AKDSPRef dsp, double beat);
AK_API void sequencerEngineRemoveMIDINote(AKDSPRef dsp, double beat);
AK_API void sequencerEngineRemoveSpecificMIDINote(AKDSPRef dsp, double beat, uint8_t noteNumber);
AK_API void sequencerEngineRemoveAllInstancesOf(AKDSPRef dsp, uint8_t noteNumber);

AK_API void sequencerEngineStopPlayingNotes(AKDSPRef dsp);
AK_API void sequencerEngineClear(AKDSPRef dsp);

AK_API void sequencerEngineSetAUTarget(AKDSPRef dsp, AudioUnit audioUnit);
