//
//  AKTesterAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2017 Aurelius Prochazka. All rights reserved.
//

#pragma once
#import "AKAudioUnit.h"

@interface AKTesterAudioUnit : AKAudioUnit

@property (readonly) NSString* md5;
@property int samples;

@end

