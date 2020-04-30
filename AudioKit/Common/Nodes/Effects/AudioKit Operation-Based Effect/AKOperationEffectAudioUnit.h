// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import "AKAudioUnit.h"

@class AKCustomUgen;

@interface AKOperationEffectAudioUnit : AKAudioUnit
@property (nonatomic) NSArray *parameters;
- (void)setSporth:(NSString *)sporth;
- (void)addCustomUgen:(AKCustomUgen *)ugen;
@end
