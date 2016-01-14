//
//  AKTesterAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, last edited January 13, 2016.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#ifndef AKTesterAudioUnit_h
#define AKTesterAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>

@interface AKTesterAudioUnit : AUAudioUnit
- (void)setSamples:(int)samples;
- (NSString *)getMD5;
- (int)getSamples;
- (void)start;
- (void)stop;
@end

#endif /* AKTesterAudioUnit_h */
