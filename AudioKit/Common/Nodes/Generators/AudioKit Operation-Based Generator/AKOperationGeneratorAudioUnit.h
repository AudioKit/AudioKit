//
//  AKOperationGeneratorAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#ifndef AKOperationGeneratorAudioUnit_h
#define AKOperationGeneratorAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>

@interface AKOperationGeneratorAudioUnit : AUAudioUnit
- (void)setSporth:(NSString *)sporth;
- (void)trigger:(int)trigger;
- (void)setParameters:(NSArray *)parameters;
- (void)start;
- (void)stop;
- (BOOL)isPlaying;
@end

#endif /* AKOperationGeneratorAudioUnit_h */
