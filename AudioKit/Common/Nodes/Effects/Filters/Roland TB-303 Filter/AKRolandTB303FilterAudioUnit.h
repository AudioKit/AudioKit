//
//  AKRolandTB303FilterAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKRolandTB303FilterAudioUnit_h
#define AKRolandTB303FilterAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>

@interface AKRolandTB303FilterAudioUnit : AUAudioUnit
- (void)start;
- (void)stop;
- (BOOL)isPlaying;
@end

#endif /* AKRolandTB303FilterAudioUnit_h */
