//
//  AKPannerAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, last edited January 13, 2016.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKPannerAudioUnit_h
#define AKPannerAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>

@interface AKPannerAudioUnit : AUAudioUnit
- (void)start;
- (void)stop;
- (BOOL)isPlaying;
@end

#endif /* AKPannerAudioUnit_h */
