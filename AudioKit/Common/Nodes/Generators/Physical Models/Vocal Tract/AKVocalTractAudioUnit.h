//
//  AKVocalTractAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

#pragma once
#import "AKAudioUnit.h"

@interface AKVocalTractAudioUnit : AKAudioUnit
@property (nonatomic) float frequency;
@property (nonatomic) float tonguePosition;
@property (nonatomic) float tongueDiameter;
@property (nonatomic) float tenseness;
@property (nonatomic) float nasality;
@end
