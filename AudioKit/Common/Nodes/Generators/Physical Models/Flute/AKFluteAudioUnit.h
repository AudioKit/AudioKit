//
//  AKFluteAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKFluteAudioUnit_h
#define AKFluteAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>
#import "AKAudioUnitType.h"

@interface AKFluteAudioUnit : AUAudioUnit<AKAudioUnitType>
@property (nonatomic) float frequency;
@property (nonatomic) float amplitude;

- (void)triggerFrequency:(float)frequency amplitude:(float)amplitude;

@property double rampTime;

@end

#endif /* AKFluteAudioUnit_h */
