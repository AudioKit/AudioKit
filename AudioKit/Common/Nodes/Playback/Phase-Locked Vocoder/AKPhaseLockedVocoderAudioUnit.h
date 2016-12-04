//
//  AKPhaseLockedVocoderAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKPhaseLockedVocoderAudioUnit_h
#define AKPhaseLockedVocoderAudioUnit_h

#import "AKAudioUnit.h"

@interface AKPhaseLockedVocoderAudioUnit : AKAudioUnit
@property (nonatomic) float position;
@property (nonatomic) float amplitude;
@property (nonatomic) float pitchRatio;

- (void)setupAudioFileTable:(float *)data size:(UInt32)size;

@end

#endif /* AKPhaseLockedVocoderAudioUnit_h */
