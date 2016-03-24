//
//  AKHighPassButterworthFilterAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKHighPassButterworthFilterAudioUnit_h
#define AKHighPassButterworthFilterAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>

@interface AKHighPassButterworthFilterAudioUnit : AUAudioUnit
- (void)start;
- (void)stop;
- (BOOL)isPlaying;
- (void)setUpParameterRamp;

@property double inertia;

@end

#endif /* AKHighPassButterworthFilterAudioUnit_h */
