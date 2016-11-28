//
//  AKBitCrusherAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKBitCrusherAudioUnit_h
#define AKBitCrusherAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>
#import "AKAudioUnitType.h"

@interface AKBitCrusherAudioUnit : AUAudioUnit<AKAudioUnitType>
@property (nonatomic) float bitDepth;
@property (nonatomic) float sampleRate;

@property double rampTime;

@end

#endif /* AKBitCrusherAudioUnit_h */
