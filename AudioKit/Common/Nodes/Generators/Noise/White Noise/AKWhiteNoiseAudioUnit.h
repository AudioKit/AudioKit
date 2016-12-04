//
//  AKWhiteNoiseAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKWhiteNoiseAudioUnit_h
#define AKWhiteNoiseAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>
#import "AKAudioUnitType.h"

@interface AKWhiteNoiseAudioUnit : AUAudioUnit<AKAudioUnitType>
@property (nonatomic) float amplitude;

@property double rampTime;

@end

#endif /* AKWhiteNoiseAudioUnit_h */
