//
//  AKPannerAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKPannerAudioUnit_h
#define AKPannerAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>
#import "AKAudioUnitType.h"

@interface AKPannerAudioUnit : AUAudioUnit<AKAudioUnitType>
@property (nonatomic) float pan;

@property double rampTime;

@end

#endif /* AKPannerAudioUnit_h */
