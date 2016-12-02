//
//  AKTremoloAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKTremoloAudioUnit_h
#define AKTremoloAudioUnit_h

#import "AKAudioUnit.h"

@interface AKTremoloAudioUnit : AKAudioUnit
@property (nonatomic) float frequency;
@property (nonatomic) float depth;

- (void)setupWaveform:(int)size;
- (void)setWaveformValue:(float)value atIndex:(UInt32)index;

@end

#endif /* AKTremoloAudioUnit_h */
