//
//  AKCallbackInstrumentAudioUnit.h
//  AudioKit
//
//  Created by Jeff Cooper, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once
#import "AKAudioUnit.h"

typedef void (^AKCMIDICallback)(uint8_t, uint8_t, uint8_t);

@interface AKCallbackInstrumentAudioUnit : AKAudioUnit
@property (nonatomic) AKCMIDICallback callback;
- (void)destroy;
- (void)startNote:(uint8_t)note velocity:(uint8_t)velocity;
- (void)stopNote:(uint8_t)note;

@end


