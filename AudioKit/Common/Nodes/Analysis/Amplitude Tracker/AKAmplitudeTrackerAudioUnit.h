// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import "AKAudioUnit.h"

typedef void (^AKThresholdCallback)(BOOL);

@interface AKAmplitudeTrackerAudioUnit : AKAudioUnit
@property (readonly) float leftAmplitude;
@property (readonly) float rightAmplitude;
@property (nonatomic) float threshold;
@property (nonatomic) int mode;
//@property (nonatomic) float smoothness; //in development
@property (nonatomic) AKThresholdCallback thresholdCallback;
- (void)setHalfPowerPoint:(float)halfPowerPoint;
- (void)setMode:(int)mode;
@end

