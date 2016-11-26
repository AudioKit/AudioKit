//
//  AKFormantFilterAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKFormantFilterAudioUnit_h
#define AKFormantFilterAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>

@interface AKFormantFilterAudioUnit : AUAudioUnit
@property (nonatomic) float x;
@property (nonatomic) float y;

- (void)start;
- (void)stop;
- (BOOL)isPlaying;
- (void)setUpParameterRamp;
- (BOOL)isSetUp;

@property double rampTime;

@end

#endif /* AKFormantFilterAudioUnit_h */
