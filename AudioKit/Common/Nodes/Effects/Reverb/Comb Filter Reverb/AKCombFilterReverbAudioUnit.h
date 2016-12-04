//
//  AKCombFilterReverbAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKCombFilterReverbAudioUnit_h
#define AKCombFilterReverbAudioUnit_h

#import "AKAudioUnit.h"

@interface AKCombFilterReverbAudioUnit : AKAudioUnit
@property (nonatomic) float reverbDuration;
- (void)setLoopDuration:(float)duration;
@end

#endif /* AKCombFilterReverbAudioUnit_h */
