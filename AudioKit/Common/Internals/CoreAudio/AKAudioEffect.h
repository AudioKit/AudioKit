//
//  AKAudioEffect.h
//  AudioKit
//
//  Created by Andrew Voelkel on 8/28/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

#pragma once

#import <AVFoundation/AVFoundation.h>
#import "AKAudioUnit.h"


@interface AKAudioEffect : AKAudioUnit

- (void)standardSetup;

@end

