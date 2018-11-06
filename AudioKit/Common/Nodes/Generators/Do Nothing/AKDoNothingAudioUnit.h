//
//  AKDoNothingAudioUnit.h
//  AudioKit
//
//  Created by Jeff Cooper, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once
#import "AKAudioUnit.h"

typedef void (^AKCMIDICallback)(uint8_t, uint8_t, uint8_t);

@interface AKDoNothingAudioUnit : AKAudioUnit
@property (nonatomic) AKCMIDICallback callback;
- (void)destroy;

@end


