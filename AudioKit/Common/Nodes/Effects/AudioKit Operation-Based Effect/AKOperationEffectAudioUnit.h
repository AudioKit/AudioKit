//
//  AKOperationEffectAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, last edited January 13, 2016.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#ifndef AKOperationEffectAudioUnit_h
#define AKOperationEffectAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>

@interface AKOperationEffectAudioUnit : AUAudioUnit
- (void)setSporth:(NSString *)sporth;

- (void)setParameters:(NSArray *)parameters;
- (void)start;
- (void)stop;
- (BOOL)isPlaying;
@end

#endif /* AKOperationEffectAudioUnit_h */
