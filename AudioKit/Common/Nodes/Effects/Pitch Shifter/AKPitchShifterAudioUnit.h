//
//  AKPitchShifterAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

#pragma once
#import "AKAudioUnit.h"

@interface AKPitchShifterAudioUnit : AKAudioUnit
@property (nonatomic) float shift;
@property (nonatomic) float windowSize;
@property (nonatomic) float crossfade;
@end

