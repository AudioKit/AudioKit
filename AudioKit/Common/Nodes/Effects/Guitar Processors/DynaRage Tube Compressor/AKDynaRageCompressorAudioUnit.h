//
//  AKDynaRageCompressorAudioUnit.h
//  AudioKit
//
//  Created by Mike Gazzaruso, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once
#import "AKAudioUnit.h"

@interface AKDynaRageCompressorAudioUnit : AKAudioUnit
@property (nonatomic) float ratio;
@property (nonatomic) float threshold;
@property (nonatomic) float attackDuration;
@property (nonatomic) float releaseDuration;
@property (nonatomic) float rage;
@property (nonatomic) BOOL rageIsOn;
@end
