//
//  AKZitaReverbAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

#pragma once
#import "AKAudioUnit.h"

@interface AKZitaReverbAudioUnit : AKAudioUnit
@property (nonatomic) float predelay;
@property (nonatomic) float crossoverFrequency;
@property (nonatomic) float lowReleaseTime;
@property (nonatomic) float midReleaseTime;
@property (nonatomic) float dampingFrequency;
@property (nonatomic) float equalizerFrequency1;
@property (nonatomic) float equalizerLevel1;
@property (nonatomic) float equalizerFrequency2;
@property (nonatomic) float equalizerLevel2;
@property (nonatomic) float dryWetMix;
@end
