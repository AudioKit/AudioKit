// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

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
