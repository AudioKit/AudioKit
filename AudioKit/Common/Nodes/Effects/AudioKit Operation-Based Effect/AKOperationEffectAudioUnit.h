//
//  AKOperationEffectAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

#pragma once

#import "AKAudioUnit.h"

@class AKCustomUgen;

@interface AKOperationEffectAudioUnit : AKAudioUnit
@property (nonatomic) NSArray *parameters;
- (void)setSporth:(NSString *)sporth;
- (void)addCustomUgen:(AKCustomUgen *)ugen;
@end

@interface SporthStack : NSObject
- (char *)popString;
- (float)popFloat;

- (void)pushFloat:(float)f;
- (void)pushString:(char *)str;
@end
