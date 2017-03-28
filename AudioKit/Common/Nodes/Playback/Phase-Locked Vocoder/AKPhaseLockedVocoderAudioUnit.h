//
//  AKPhaseLockedVocoderAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

#pragma once
#import "AKAudioUnit.h"

@interface AKPhaseLockedVocoderAudioUnit : AKAudioUnit
@property (nonatomic) float position;
@property (nonatomic) float amplitude;
@property (nonatomic) float pitchRatio;

- (void)setupAudioFileTable:(float *)data size:(UInt32)size;

@end


