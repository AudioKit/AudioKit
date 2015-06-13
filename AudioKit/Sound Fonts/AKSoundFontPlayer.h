//
//  AKSoundFontPlayer.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 6/12/15.
//  Copyright (c) 2015 AudioKit. All rights reserved.
//

#import "AKStereoAudio.h"
#import "AKManager.h"
#import "AKSoundFont.h"
#import "AKParameter+Operation.h"

@interface AKSoundFontPlayer : AKStereoAudio

- (instancetype)initWithSoundFont:(AKSoundFont *)soundFont;

@end
