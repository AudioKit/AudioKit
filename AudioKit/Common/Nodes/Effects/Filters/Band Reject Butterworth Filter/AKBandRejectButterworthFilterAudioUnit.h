//
//  AKBandRejectButterworthFilterAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKBandRejectButterworthFilterAudioUnit_h
#define AKBandRejectButterworthFilterAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>

@interface AKBandRejectButterworthFilterAudioUnit : AUAudioUnit
- (void)start;
- (void)stop;
- (BOOL)isPlaying;
- (void)setUpParameterRamp;

@property double rampTime;

@end

#endif /* AKBandRejectButterworthFilterAudioUnit_h */
