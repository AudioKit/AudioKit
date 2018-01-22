//
//  AKChorusAudioUnit.h
//  AudioKit
//
//  Created by Shane Dunne
//  Copyright © 2018 Shane Dunne. All rights reserved.
//

#pragma once
#import "AKAudioUnit.h"

@interface AKChorusAudioUnit : AKAudioUnit
@property (nonatomic) float modFreq;
@property (nonatomic) float modDepth;
@property (nonatomic) float wetFraction;
@property (nonatomic) float feedback;
@end


