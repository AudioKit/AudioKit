//
//  AKResonantFilterAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#pragma once
#import "AKAudioUnit.h"

@interface AKResonantFilterAudioUnit : AKAudioUnit
@property (nonatomic) float frequency;
@property (nonatomic) float bandwidth;
@end
