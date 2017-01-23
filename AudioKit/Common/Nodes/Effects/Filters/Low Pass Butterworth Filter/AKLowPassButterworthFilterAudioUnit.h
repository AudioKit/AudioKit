//
//  AKLowPassButterworthFilterAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2017 Aurelius Prochazka. All rights reserved.
//

#pragma once
#import "AKAudioUnit.h"

@interface AKLowPassButterworthFilterAudioUnit : AKAudioUnit
@property (nonatomic) float cutoffFrequency;
@end

