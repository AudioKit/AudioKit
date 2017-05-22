//
//  AKSamplePlayerAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

#pragma once
#import "AKAudioUnit.h"

@interface AKSamplePlayerAudioUnit : AKAudioUnit
@property (nonatomic) float startPoint;
@property (nonatomic) float endPoint;
@property (nonatomic) float rate;
@property (nonatomic) BOOL loop;

- (void)setupAudioFileTable:(float *)data size:(UInt32)size;

- (int)size;

@end


