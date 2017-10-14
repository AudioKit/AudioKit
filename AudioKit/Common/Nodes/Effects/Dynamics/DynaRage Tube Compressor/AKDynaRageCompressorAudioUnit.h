//
//  AKDynaRageCompressorAudioUnit.h
//  AudioKit
//
//  Created by Mike Gazzaruso, revision history on Github.
//  Copyright © 2017 Mike Gazzaruso, Devoloop Srls. All rights reserved.
//

#pragma once
#import "AKAudioUnit.h"

@interface AKDynaRageCompressorAudioUnit : AKAudioUnit
@property (nonatomic) float ratio;
@property (nonatomic) float threshold;
@property (nonatomic) float attackTime;
@property (nonatomic) float releaseTime;
@property (nonatomic) float rageAmount;
@property (nonatomic) BOOL rageIsOn;
@end
