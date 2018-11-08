//
//  AKRhodesPianoAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once
#import "AKAudioUnit.h"

@interface AKRhodesPianoAudioUnit : AKAudioUnit
@property (nonatomic) float frequency;
@property (nonatomic) float amplitude;

- (void)triggerFrequency:(float)frequency amplitude:(float)amplitude;

@end

