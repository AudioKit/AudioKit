//
//  BufferedAudioUnit.h
//  AudioKit
//
//  Created by Dave O'Neill, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^ProcessEventsBlock)(AudioBufferList        * _Nullable inBuffer,
                                  AudioBufferList        * _Nonnull  outBuffer,
                                  const AudioTimeStamp   * _Nonnull  timestamp,
                                  AVAudioFrameCount                  frameCount,
                                  const AURenderEvent    * _Nullable eventsListHead);


@interface BufferedAudioUnit : AUAudioUnit

// Override and do processing in this block.
-(ProcessEventsBlock)processEventsBlock:(AVAudioFormat *)format;

// Generators should return false;
-(BOOL)shouldAllocateInputBus;
@end


NS_ASSUME_NONNULL_END
