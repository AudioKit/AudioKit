//
//  AKCombFilterReverbAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

#pragma once
#import "AKAudioUnit.h"

@interface AKCombFilterReverbAudioUnit : AKAudioUnit
@property (nonatomic) float reverbDuration;
- (void)setLoopDuration:(float)duration;
@end

