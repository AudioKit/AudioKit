//
//  AKOperationEffectAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#ifndef AKOperationEffectAudioUnit_h
#define AKOperationEffectAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>

@interface AKOperationEffectAudioUnit : AUAudioUnit
@property (nonatomic) NSArray *parameters;
- (void)setSporth:(NSString *)sporth;
- (void)start;
- (void)stop;
- (BOOL)isPlaying;
@end

#endif /* AKOperationEffectAudioUnit_h */
