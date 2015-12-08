//
//  EZAudio.m
//  EZAudioCoreGraphicsWaveformExample
//
//  Created by Syed Haris Ali on 5/13/15.
//  Copyright (c) 2015 Syed Haris Ali. All rights reserved.
//

#import "EZAudio.h"

@implementation EZAudio

//------------------------------------------------------------------------------
#pragma mark - Debugging
//------------------------------------------------------------------------------

+ (void)setShouldExitOnCheckResultFail:(BOOL)shouldExitOnCheckResultFail
{
    [EZAudioUtilities setShouldExitOnCheckResultFail:shouldExitOnCheckResultFail];
}

//------------------------------------------------------------------------------

+ (BOOL)shouldExitOnCheckResultFail
{
    return [EZAudioUtilities shouldExitOnCheckResultFail];
}

//------------------------------------------------------------------------------
#pragma mark - AudioBufferList Utility
//------------------------------------------------------------------------------

+ (AudioBufferList *)audioBufferListWithNumberOfFrames:(UInt32)frames
                                      numberOfChannels:(UInt32)channels
                                           interleaved:(BOOL)interleaved
{
    return [EZAudioUtilities audioBufferListWithNumberOfFrames:frames
                                              numberOfChannels:channels
                                                   interleaved:interleaved];
}

//------------------------------------------------------------------------------

+ (float **)floatBuffersWithNumberOfFrames:(UInt32)frames
                          numberOfChannels:(UInt32)channels
{
    return [EZAudioUtilities floatBuffersWithNumberOfFrames:frames
                                           numberOfChannels:channels];
}

//------------------------------------------------------------------------------

+ (void)freeBufferList:(AudioBufferList *)bufferList
{
    [EZAudioUtilities freeBufferList:bufferList];
}

//------------------------------------------------------------------------------

+ (void)freeFloatBuffers:(float **)buffers numberOfChannels:(UInt32)channels
{
    [EZAudioUtilities freeFloatBuffers:buffers numberOfChannels:channels];
}

//------------------------------------------------------------------------------
#pragma mark - AudioStreamBasicDescription Utility
//------------------------------------------------------------------------------

+ (AudioStreamBasicDescription)AIFFFormatWithNumberOfChannels:(UInt32)channels
                                                   sampleRate:(float)sampleRate
{
    return [EZAudioUtilities AIFFFormatWithNumberOfChannels:channels
                                                 sampleRate:sampleRate];
}

//------------------------------------------------------------------------------

+ (AudioStreamBasicDescription)iLBCFormatWithSampleRate:(float)sampleRate
{
    return [EZAudioUtilities iLBCFormatWithSampleRate:sampleRate];
}

//------------------------------------------------------------------------------

+ (AudioStreamBasicDescription)floatFormatWithNumberOfChannels:(UInt32)channels
                                                    sampleRate:(float)sampleRate
{
    return [EZAudioUtilities floatFormatWithNumberOfChannels:channels
                                                  sampleRate:sampleRate];
}

//------------------------------------------------------------------------------

+ (AudioStreamBasicDescription)M4AFormatWithNumberOfChannels:(UInt32)channels
                                                  sampleRate:(float)sampleRate
{
    return [EZAudioUtilities M4AFormatWithNumberOfChannels:channels
                                                sampleRate:sampleRate];
}

//------------------------------------------------------------------------------

+ (AudioStreamBasicDescription)monoFloatFormatWithSampleRate:(float)sampleRate
{
    return [EZAudioUtilities monoFloatFormatWithSampleRate:sampleRate];
}

//------------------------------------------------------------------------------

+ (AudioStreamBasicDescription)monoCanonicalFormatWithSampleRate:(float)sampleRate
{
    return [EZAudioUtilities monoCanonicalFormatWithSampleRate:sampleRate];
}

//------------------------------------------------------------------------------

+ (AudioStreamBasicDescription)stereoCanonicalNonInterleavedFormatWithSampleRate:(float)sampleRate
{
    return [EZAudioUtilities stereoCanonicalNonInterleavedFormatWithSampleRate:sampleRate];
}

//------------------------------------------------------------------------------

+ (AudioStreamBasicDescription)stereoFloatInterleavedFormatWithSampleRate:(float)sampleRate
{
    return [EZAudioUtilities stereoFloatInterleavedFormatWithSampleRate:sampleRate];
}

//------------------------------------------------------------------------------

+ (AudioStreamBasicDescription)stereoFloatNonInterleavedFormatWithSampleRate:(float)sampleRate
{
    return [EZAudioUtilities stereoFloatNonInterleavedFormatWithSampleRate:sampleRate];
}

//------------------------------------------------------------------------------

+ (BOOL)isFloatFormat:(AudioStreamBasicDescription)asbd
{
    return [EZAudioUtilities isFloatFormat:asbd];
}

//------------------------------------------------------------------------------

+ (BOOL)isInterleaved:(AudioStreamBasicDescription)asbd
{
    return [EZAudioUtilities isInterleaved:asbd];
}

//------------------------------------------------------------------------------

+ (BOOL)isLinearPCM:(AudioStreamBasicDescription)asbd
{
    return [EZAudioUtilities isLinearPCM:asbd];
}

//------------------------------------------------------------------------------

+ (void)printASBD:(AudioStreamBasicDescription)asbd
{
    [EZAudioUtilities printASBD:asbd];
}

//------------------------------------------------------------------------------

+ (NSString *)displayTimeStringFromSeconds:(NSTimeInterval)seconds
{
    return [EZAudioUtilities displayTimeStringFromSeconds:seconds];
}

//------------------------------------------------------------------------------

+ (NSString *)stringForAudioStreamBasicDescription:(AudioStreamBasicDescription)asbd
{
    return [EZAudioUtilities stringForAudioStreamBasicDescription:asbd];
}

//------------------------------------------------------------------------------

+ (void)setCanonicalAudioStreamBasicDescription:(AudioStreamBasicDescription*)asbd
                               numberOfChannels:(UInt32)nChannels
                                    interleaved:(BOOL)interleaved
{
    [EZAudioUtilities setCanonicalAudioStreamBasicDescription:asbd
                                             numberOfChannels:nChannels
                                                  interleaved:interleaved];
}

//------------------------------------------------------------------------------
#pragma mark - Math Utilities
//------------------------------------------------------------------------------

+ (void)appendBufferAndShift:(float*)buffer
              withBufferSize:(int)bufferLength
             toScrollHistory:(float*)scrollHistory
       withScrollHistorySize:(int)scrollHistoryLength
{
    [EZAudioUtilities appendBufferAndShift:buffer
                            withBufferSize:bufferLength
                           toScrollHistory:scrollHistory
                     withScrollHistorySize:scrollHistoryLength];
}

//------------------------------------------------------------------------------

+ (void)   appendValue:(float)value
       toScrollHistory:(float*)scrollHistory
 withScrollHistorySize:(int)scrollHistoryLength
{
    [EZAudioUtilities appendValue:value
                  toScrollHistory:scrollHistory
            withScrollHistorySize:scrollHistoryLength];
}

//------------------------------------------------------------------------------

+ (float)MAP:(float)value
     leftMin:(float)leftMin
     leftMax:(float)leftMax
    rightMin:(float)rightMin
    rightMax:(float)rightMax
{
    return [EZAudioUtilities MAP:value
                         leftMin:leftMin
                         leftMax:leftMax
                        rightMin:rightMin
                        rightMax:rightMax];
}

//------------------------------------------------------------------------------

+ (float)RMS:(float *)buffer length:(int)bufferSize
{
    return [EZAudioUtilities RMS:buffer length:bufferSize];
}

//------------------------------------------------------------------------------

+ (float)SGN:(float)value
{
    return [EZAudioUtilities SGN:value];
}

//------------------------------------------------------------------------------
#pragma mark - OSStatus Utility
//------------------------------------------------------------------------------

+ (void)checkResult:(OSStatus)result operation:(const char *)operation
{
    [EZAudioUtilities checkResult:result
                        operation:operation];
}

//------------------------------------------------------------------------------

+ (NSString *)stringFromUInt32Code:(UInt32)code
{
    return [EZAudioUtilities stringFromUInt32Code:code];
}

//------------------------------------------------------------------------------
#pragma mark - Plot Utility
//------------------------------------------------------------------------------

+ (void)updateScrollHistory:(float **)scrollHistory
                 withLength:(int)scrollHistoryLength
                    atIndex:(int *)index
                 withBuffer:(float *)buffer
             withBufferSize:(int)bufferSize
       isResolutionChanging:(BOOL *)isChanging
{
    [EZAudioUtilities updateScrollHistory:scrollHistory
                               withLength:scrollHistoryLength
                                  atIndex:index
                               withBuffer:buffer
                           withBufferSize:bufferSize
                     isResolutionChanging:isChanging];
}

//------------------------------------------------------------------------------
#pragma mark - TPCircularBuffer Utility
//------------------------------------------------------------------------------

+ (void)appendDataToCircularBuffer:(TPCircularBuffer *)circularBuffer
               fromAudioBufferList:(AudioBufferList *)audioBufferList
{
    [EZAudioUtilities appendDataToCircularBuffer:circularBuffer
                             fromAudioBufferList:audioBufferList];
}

//------------------------------------------------------------------------------

+ (void)circularBuffer:(TPCircularBuffer *)circularBuffer withSize:(int)size
{
    [EZAudioUtilities circularBuffer:circularBuffer withSize:size];
}

//------------------------------------------------------------------------------

+ (void)freeCircularBuffer:(TPCircularBuffer *)circularBuffer
{
    [EZAudioUtilities freeCircularBuffer:circularBuffer];
}

//------------------------------------------------------------------------------

@end