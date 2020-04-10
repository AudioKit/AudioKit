// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once
#import "AKAudioUnit.h"

typedef void (^AKCMIDICallback)(uint8_t, uint8_t, uint8_t);

@interface AKCallbackInstrumentAudioUnit : AKAudioUnit
@property (nonatomic) AKCMIDICallback callback;
- (void)destroy;
- (void)startNote:(uint8_t)note velocity:(uint8_t)velocity;
- (void)stopNote:(uint8_t)note;

@end


