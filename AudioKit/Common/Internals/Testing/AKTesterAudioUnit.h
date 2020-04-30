// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once
#import "AKAudioUnit.h"

@interface AKTesterAudioUnit : AKAudioUnit

@property (readonly) NSString *md5;
@property int samples;

@end

