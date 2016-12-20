//
//  AKPitchShifterAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#pragma once
#import "AKAudioUnit.h"

@interface AKPitchShifterAudioUnit : AKAudioUnit
@property (nonatomic) float shift;
@property (nonatomic) float windowSize;
@property (nonatomic) float crossfade;
@end

