//
//  AKFormantFilterAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, last edited January 13, 2016.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKFormantFilterAudioUnit_h
#define AKFormantFilterAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>

@interface AKFormantFilterAudioUnit : AUAudioUnit
- (void)start;
- (void)stop;
- (BOOL)isPlaying;
@end

#endif /* AKFormantFilterAudioUnit_h */
