// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

NS_ASSUME_NONNULL_BEGIN

/** No Swift or ObjC functions and property access. No ARC managed references/assignments. */
typedef void (^ProcessEventsBlock)(AudioBufferList *_Nullable     inBuffer,
                                   AudioBufferList *_Nonnull      outBuffer,
                                   const AudioTimeStamp *_Nonnull timestamp,
                                   AVAudioFrameCount              frameCount,
                                   const AURenderEvent *_Nullable eventsListHead);

@interface BufferedAudioUnit : AUAudioUnit

//- (instancetype)initWithComponentDescription:(AudioComponentDescription)componentDescription
//                                     options:(AudioComponentInstantiationOptions)options
//                                      format:(AVAudioFormat *_Nonnull)format
//                                       error:(NSError **)outError;

/** Subclasses should overide this to return a block to do processing in. */
- (ProcessEventsBlock)processEventsBlock:(AVAudioFormat *)format;

/** If true, an input bus will be allocated, intended for subclasses to override, defaults to true. */
- (BOOL)shouldAllocateInputBus;

/** If true, the output buffer samples will be set to zero pre-render, Intended for subclasses to override, defaults to false */
- (BOOL)shouldClearOutputBuffer;

@end

NS_ASSUME_NONNULL_END
