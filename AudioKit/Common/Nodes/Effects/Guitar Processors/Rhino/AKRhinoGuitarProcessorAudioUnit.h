//
//  AKRhinoGuitarProcessorAudioUnit.h
//  AudioKit
//
//  Created by Mike Gazzaruso, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once
#import "AKAudioUnit.h"

@interface AKRhinoGuitarProcessorAudioUnit : AKAudioUnit
@property (nonatomic) float preGain;
@property (nonatomic) float postGain;
@property (nonatomic) float lowGain;
@property (nonatomic) float midGain;
@property (nonatomic) float highGain;
@property (nonatomic) float distType;
@property (nonatomic) float distortion;
@end
