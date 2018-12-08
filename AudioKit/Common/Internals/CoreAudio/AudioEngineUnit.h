//
//  AudioEngineUnit.h
//  AudioKit
//
//  Created by Dave O'Neill, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import "BufferedAudioUnit.h"

NS_ASSUME_NONNULL_BEGIN

API_AVAILABLE(macos(10.13), ios(11.0), tvos(11.0))
@interface AudioEngineUnit : BufferedAudioUnit
@property (readonly) AVAudioEngine *audioEngine;
- (BOOL)setIOFormat:(AVAudioFormat *)format error:(NSError **)outError;
@end

NS_ASSUME_NONNULL_END
