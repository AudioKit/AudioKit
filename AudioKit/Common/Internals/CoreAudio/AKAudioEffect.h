//
//  AKAudioEffect.h
//  AudioKit
//
//  Created by Andrew Voelkel, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import <AVFoundation/AVFoundation.h>
#import "AKAudioUnit.h"


@interface AKAudioEffect : AKAudioUnit

- (void)standardSetup;

@end

