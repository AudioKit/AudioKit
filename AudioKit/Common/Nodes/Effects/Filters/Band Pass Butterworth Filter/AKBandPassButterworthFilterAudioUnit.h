//
//  AKBandPassButterworthFilterAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKBandPassButterworthFilterAudioUnit_h
#define AKBandPassButterworthFilterAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>

@interface AKBandPassButterworthFilterAudioUnit : AUAudioUnit
@property (nonatomic) float centerFrequency;
@property (nonatomic) float bandwidth;

- (void)start;
- (void)stop;
- (BOOL)isPlaying;
- (void)setUpParameterRamp;
- (BOOL)isSetUp;

@property double rampTime;

@end

#endif /* AKBandPassButterworthFilterAudioUnit_h */
