//
//  AKTesterAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once
#import "AKAudioUnit.h"

@interface AKTesterAudioUnit : AKAudioUnit

@property (readonly) NSString *md5;
@property int samples;

@end

