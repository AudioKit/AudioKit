//
//  AKOfflineRenderAudioUnit.h
//  AudioKit For iOS
//
//  Created by Bang Means Do It on 27/03/2017.
//  Copyright © 2017 AudioKit. All rights reserved.
//

#pragma once
#import "AKAudioUnit.h"

@interface AKOfflineRenderAudioUnit : AKAudioUnit

- (void)setUpAudioOutput:(CFURLRef)url;
- (void)completeFileWrite;
- (void)enableOfflineRender:(BOOL)enable;

@end
