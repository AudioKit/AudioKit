//
//  AKPinkNoiseAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, last edited January 13, 2016.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKPinkNoiseAudioUnit_h
#define AKPinkNoiseAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>

@interface AKPinkNoiseAudioUnit : AUAudioUnit
@property (nonatomic) float amplitude;
- (void)start;
- (void)stop;
- (BOOL)isPlaying;
@end

#endif /* AKPinkNoiseAudioUnit_h */
