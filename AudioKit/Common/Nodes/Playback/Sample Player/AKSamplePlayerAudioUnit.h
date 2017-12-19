//
//  AKSamplePlayerAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

#pragma once
#import "AKAudioUnit.h"

typedef void (^AKCCallback)(void);

@interface AKSamplePlayerAudioUnit : AKAudioUnit
@property (nonatomic) float startPoint;
@property (nonatomic) float endPoint;
@property (nonatomic) float tempStartPoint;
@property (nonatomic) float tempEndPoint;
@property (nonatomic) float rate;
@property (nonatomic) float volume;
@property (nonatomic) BOOL loop;
@property (nonatomic) float loopStartPoint;
@property (nonatomic) float loopEndPoint;
@property (nonatomic) AKCCallback completionHandler;

- (void)setupAudioFileTable:(UInt32)size;
- (void)loadAudioData:(float *)data size:(UInt32)size sampleRate:(float)sampleRate;
- (int)size;
- (double)position;

@end


