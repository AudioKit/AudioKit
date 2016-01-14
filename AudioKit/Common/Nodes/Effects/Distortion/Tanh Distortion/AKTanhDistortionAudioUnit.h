//
//  AKTanhDistortionAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, last edited January 13, 2016.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKTanhDistortionAudioUnit_h
#define AKTanhDistortionAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>

@interface AKTanhDistortionAudioUnit : AUAudioUnit
- (void)start;
- (void)stop;
- (BOOL)isPlaying;
@end

#endif /* AKTanhDistortionAudioUnit_h */
