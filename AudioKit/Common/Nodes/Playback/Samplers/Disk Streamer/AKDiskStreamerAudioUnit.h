//
//  AKDiskStreamerAudioUnit.h
//  AudioKit
//
//  Created by Jeff Cooper, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once
#import "AKAudioUnit.h"

typedef void (^AKCCallback)(void);

@interface AKDiskStreamerAudioUnit : AKAudioUnit
@property (nonatomic) float startPoint;
@property (nonatomic) float endPoint;
@property (nonatomic) float tempStartPoint;
@property (nonatomic) float tempEndPoint;
//@property (nonatomic) float rate;
@property (nonatomic) float volume;
@property (nonatomic) BOOL loop;
@property (nonatomic) float loopStartPoint;
@property (nonatomic) float loopEndPoint;
@property (nonatomic) AKCCallback loadCompletionHandler;
@property (nonatomic) AKCCallback completionHandler;
@property (nonatomic) AKCCallback loopCallback;

- (void)loadFile:(const char*)filename;
- (int)size;
- (double)position;

@end


