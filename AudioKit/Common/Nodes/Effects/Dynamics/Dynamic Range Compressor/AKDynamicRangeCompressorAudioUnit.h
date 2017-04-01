//
//  AKDynamicRangeCompressorAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

#pragma once
#import "AKAudioUnit.h"

@interface AKDynamicRangeCompressorAudioUnit : AKAudioUnit
@property (nonatomic) float ratio;
@property (nonatomic) float threshold;
@property (nonatomic) float attackTime;
@property (nonatomic) float releaseTime;
@end
