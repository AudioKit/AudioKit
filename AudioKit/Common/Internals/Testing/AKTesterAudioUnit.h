//
//  AKTesterAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#ifndef AKTesterAudioUnit_h
#define AKTesterAudioUnit_h

#import "AKAudioUnit.h"

@interface AKTesterAudioUnit : AKAudioUnit
- (void)setSamples:(int)samples;
- (NSString *)getMD5;
- (int)getSamples;

@end

#endif /* AKTesterAudioUnit_h */
