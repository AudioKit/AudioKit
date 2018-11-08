//
//  AKShakerAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once
#import "AKAudioUnit.h"

@interface AKShakerAudioUnit : AKAudioUnit

@property (nonatomic) UInt8 type;
@property (nonatomic) float amplitude;

- (void)triggerType:(UInt8)type Amplitude:(float)amplitude;

@end
