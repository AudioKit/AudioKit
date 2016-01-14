//
//  AKMoogLadderAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, last edited January 13, 2016.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKMoogLadderAudioUnit_h
#define AKMoogLadderAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>

@interface AKMoogLadderAudioUnit : AUAudioUnit
- (void)start;
- (void)stop;
- (BOOL)isPlaying;
@end

#endif /* AKMoogLadderAudioUnit_h */
