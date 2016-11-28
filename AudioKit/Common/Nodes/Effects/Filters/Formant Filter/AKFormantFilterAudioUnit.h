//
//  AKFormantFilterAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKFormantFilterAudioUnit_h
#define AKFormantFilterAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>
#import "AKAudioUnitType.h"

@interface AKFormantFilterAudioUnit : AUAudioUnit<AKAudioUnitType>
@property (nonatomic) float x;
@property (nonatomic) float y;

@property double rampTime;

@end

#endif /* AKFormantFilterAudioUnit_h */
