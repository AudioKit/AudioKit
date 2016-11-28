//
//  AKClipperAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKClipperAudioUnit_h
#define AKClipperAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>
#import "AKAudioUnitType.h"

@interface AKClipperAudioUnit : AUAudioUnit<AKAudioUnitType>

@property (nonatomic) float limit;

@property double rampTime;

@end

#endif /* AKClipperAudioUnit_h */
