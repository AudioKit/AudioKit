//
//  AKPhaserAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

#pragma once
#import "AKAudioUnit.h"

@interface AKPhaserAudioUnit : AKAudioUnit
@property (nonatomic) float notchMinimumFrequency;
@property (nonatomic) float notchMaximumFrequency;
@property (nonatomic) float notchWidth;
@property (nonatomic) float notchFrequency;
@property (nonatomic) float vibratoMode;
@property (nonatomic) float depth;
@property (nonatomic) float feedback;
@property (nonatomic) float inverted;
@property (nonatomic) float lfoBPM;
@end
