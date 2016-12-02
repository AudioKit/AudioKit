//
//  AKAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 11/28/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>

@interface AKAudioUnit : AUAudioUnit 
@property AUAudioUnitBus *outputBus;
@property AUAudioUnitBusArray *inputBusArray;
@property AVAudioFormat *defaultFormat;

- (void)start;
- (void)stop;
- (BOOL)isPlaying;
- (void)setUpParameterRamp;
- (BOOL)isSetUp;

@property double rampTime;

@end
