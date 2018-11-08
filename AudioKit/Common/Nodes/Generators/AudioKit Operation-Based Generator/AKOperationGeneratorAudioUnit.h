//
//  AKOperationGeneratorAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once
#import "AKAudioUnit.h"

@class AKCustomUgen;

@interface AKOperationGeneratorAudioUnit : AKAudioUnit
@property (nonatomic) NSArray *parameters;
- (void)setSporth:(NSString *)sporth;
- (void)trigger:(int)trigger;
- (void)addCustomUgen:(AKCustomUgen *)ugen;
@end

