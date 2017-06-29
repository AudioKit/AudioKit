//
//  AKBufferedFilePlauyerAudioUnit.h
//  AudioKit For iOS
//
//  Created by Bang Means Do It on 28/03/2017.
//  Copyright © 2017 AudioKit. All rights reserved.
//

#pragma once
#import "AKAudioUnit.h"

@interface AKFilePlayerAudioUnit : AKAudioUnit

- (void)setUpAudioInput:(CFURLRef)url;
- (void)setSampleTimeStartOffset:(int32_t)offset;
- (void)prepareToPlay;
- (float)fileLengthInSeconds;
- (void)prepareForOfflineRender;

@end
