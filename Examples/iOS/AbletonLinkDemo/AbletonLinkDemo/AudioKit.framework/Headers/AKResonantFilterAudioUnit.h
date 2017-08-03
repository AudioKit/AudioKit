//
//  AKResonantFilterAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

#pragma once
#import "AKAudioUnit.h"

@interface AKResonantFilterAudioUnit : AKAudioUnit
@property (nonatomic) float frequency;
@property (nonatomic) float bandwidth;
@end
