// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once
#import "AKAudioUnit.h"

@interface AKRhinoGuitarProcessorAudioUnit : AKAudioUnit
@property (nonatomic) float preGain;
@property (nonatomic) float postGain;
@property (nonatomic) float lowGain;
@property (nonatomic) float midGain;
@property (nonatomic) float highGain;
@property (nonatomic) float distortion;
@end
