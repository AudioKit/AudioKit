//
//  AKFluteAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKFluteAudioUnit_h
#define AKFluteAudioUnit_h

#import "AKAudioUnit.h"

@interface AKFluteAudioUnit : AKAudioUnit
@property (nonatomic) float frequency;
@property (nonatomic) float amplitude;

- (void)triggerFrequency:(float)frequency amplitude:(float)amplitude;

@end

#endif /* AKFluteAudioUnit_h */
