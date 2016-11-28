//
//  AKAutoWahAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKAutoWahAudioUnit_h
#define AKAutoWahAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>
#import "AKAudioUnitType.h"

@interface AKAutoWahAudioUnit : AUAudioUnit<AKAudioUnitType>
@property (nonatomic) float wah;
@property (nonatomic) float mix;
@property (nonatomic) float amplitude;

@property double rampTime;

@end

#endif /* AKAutoWahAudioUnit_h */
