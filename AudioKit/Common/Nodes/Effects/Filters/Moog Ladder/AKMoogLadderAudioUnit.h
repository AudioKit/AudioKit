//
//  AKMoogLadderAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKMoogLadderAudioUnit_h
#define AKMoogLadderAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>

@interface AKMoogLadderAudioUnit : AUAudioUnit
@property (nonatomic) float cutoffFrequency;
@property (nonatomic) float resonance;
- (void)start;
- (void)stop;
- (BOOL)isPlaying;
- (void)setUpParameterRamp;
- (BOOL)isSetUp;

@property double rampTime;

@end

#endif /* AKMoogLadderAudioUnit_h */
