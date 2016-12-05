//
//  AKPluckedStringAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKPluckedStringAudioUnit_h
#define AKPluckedStringAudioUnit_h

#import "AKAudioUnit.h"

@interface AKPluckedStringAudioUnit : AKAudioUnit
@property (nonatomic) float frequency;
@property (nonatomic) float amplitude;

- (void)triggerFrequency:(float)frequency amplitude:(float)amplitude;

@end

#endif /* AKPluckedStringAudioUnit_h */
