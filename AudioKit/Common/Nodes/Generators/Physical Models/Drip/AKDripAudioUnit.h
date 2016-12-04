//
//  AKDripAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKDripAudioUnit_h
#define AKDripAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>
#import "AKAudioUnitType.h"

@interface AKDripAudioUnit : AUAudioUnit<AKAudioUnitType>
@property (nonatomic) float intensity;
@property (nonatomic) float dampingFactor;
@property (nonatomic) float energyReturn;
@property (nonatomic) float mainResonantFrequency;
@property (nonatomic) float firstResonantFrequency;
@property (nonatomic) float secondResonantFrequency;
@property (nonatomic) float amplitude;

- (void)trigger;

@property double rampTime;

@end

#endif /* AKDripAudioUnit_h */
