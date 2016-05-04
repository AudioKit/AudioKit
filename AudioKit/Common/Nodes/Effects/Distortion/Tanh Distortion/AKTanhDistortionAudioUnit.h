//
//  AKTanhDistortionAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKTanhDistortionAudioUnit_h
#define AKTanhDistortionAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>

@interface AKTanhDistortionAudioUnit : AUAudioUnit
@property (nonatomic) float pregain;
@property (nonatomic) float postgain;
@property (nonatomic) float postiveShapeParameter;
@property (nonatomic) float negativeShapeParameter;

- (void)start;
- (void)stop;
- (BOOL)isPlaying;
- (void)setUpParameterRamp;
- (BOOL)isSetUp;

@property double rampTime;

@end

#endif /* AKTanhDistortionAudioUnit_h */
