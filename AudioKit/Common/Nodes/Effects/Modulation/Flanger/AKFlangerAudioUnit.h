//
//  AKFlangerAudioUnit.h
//  AudioKit
//
//  Created by Shane Dunne
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once
#import "AKAudioUnit.h"

@interface AKFlangerAudioUnit : AKAudioUnit
@property (nonatomic) float frequency;
@property (nonatomic) float depth;
@property (nonatomic) float dryWetMix;
@property (nonatomic) float feedback;
@end


