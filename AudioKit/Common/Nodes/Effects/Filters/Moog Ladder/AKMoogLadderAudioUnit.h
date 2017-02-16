//
//  AKMoogLadderAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

#pragma once
#import "AKAudioUnit.h"

@interface AKMoogLadderAudioUnit : AKAudioUnit
@property (nonatomic) float cutoffFrequency;
@property (nonatomic) float resonance;
@end
