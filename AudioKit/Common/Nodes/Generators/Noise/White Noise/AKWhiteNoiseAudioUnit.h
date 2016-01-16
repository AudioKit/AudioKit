//
//  AKWhiteNoiseAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKWhiteNoiseAudioUnit_h
#define AKWhiteNoiseAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>

@interface AKWhiteNoiseAudioUnit : AUAudioUnit
@property (nonatomic) float amplitude;
- (void)start;
- (void)stop;
- (BOOL)isPlaying;
@end

#endif /* AKWhiteNoiseAudioUnit_h */
