//
//  AKLowPassButterworthFilterAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKLowPassButterworthFilterAudioUnit_h
#define AKLowPassButterworthFilterAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>

@interface AKLowPassButterworthFilterAudioUnit : AUAudioUnit
@property (nonatomic) float cutoffFrequency;

- (void)start;
- (void)stop;
- (BOOL)isPlaying;
- (void)setUpParameterRamp;
- (BOOL)isSetUp;

@property double rampTime;

@end

#endif /* AKLowPassButterworthFilterAudioUnit_h */
