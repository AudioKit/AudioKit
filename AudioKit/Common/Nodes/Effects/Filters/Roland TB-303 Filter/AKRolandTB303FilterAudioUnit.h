//
//  AKRolandTB303FilterAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKRolandTB303FilterAudioUnit_h
#define AKRolandTB303FilterAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>

@interface AKRolandTB303FilterAudioUnit : AUAudioUnit
@property (nonatomic) float cutoffFrequency;
@property (nonatomic) float resonance;
@property (nonatomic) float distortion;
@property (nonatomic) float resonanceAsymmetry;

- (void)start;
- (void)stop;
- (BOOL)isPlaying;
- (void)setUpParameterRamp;
- (BOOL)isSetUp;

@property double rampTime;

@end

#endif /* AKRolandTB303FilterAudioUnit_h */
