//
//  EZAudioUtilities.h
//  EZAudio
//
//  Created by Syed Haris Ali on 6/23/15.
//  Copyright (c) 2015 Syed Haris Ali. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <TargetConditionals.h>
#import "TPCircularBuffer.h"
#if TARGET_OS_IPHONE || TARGET_OS_TV
#import <AVFoundation/AVFoundation.h>
#elif TARGET_OS_MAC
#endif

//------------------------------------------------------------------------------
#pragma mark - Data Structures
//------------------------------------------------------------------------------

/**
 A data structure that holds information about audio data over time. It contains a circular buffer to incrementally write the audio data to and a scratch buffer to hold a window of audio data relative to the whole circular buffer. In use, this will provide a way to continuously append data while having an adjustable viewable window described by the bufferSize.
 */
typedef struct
{
    float            *buffer;
    int               bufferSize;
    TPCircularBuffer  circularBuffer;
} EZPlotHistoryInfo;

//------------------------------------------------------------------------------

/**
 A data structure that holds information about a node in the context of an AUGraph.
 */
typedef struct
{
    AudioUnit audioUnit;
    AUNode    node;
} EZAudioNodeInfo;

//------------------------------------------------------------------------------
#pragma mark - Types
//------------------------------------------------------------------------------

#if TARGET_OS_IPHONE
typedef CGRect EZRect;
#elif TARGET_OS_MAC
typedef NSRect EZRect;
#endif

//------------------------------------------------------------------------------
#pragma mark - EZAudioUtilities
//------------------------------------------------------------------------------

/**
 The EZAudioUtilities class provides a set of class-level utility methods used throughout EZAudio to handle common operations such as allocating audio buffers and structures, creating various types of AudioStreamBasicDescription structures, string helpers for formatting and debugging, various math utilities, a very handy check result function (used everywhere!), and helpers for dealing with circular buffers. These were previously on the EZAudio class, but as of the 0.1.0 release have been moved here so the whole EZAudio is not needed when using only certain modules.
 */
@interface EZAudioUtilities : NSObject

//------------------------------------------------------------------------------
#pragma mark - Debugging
//------------------------------------------------------------------------------

///-----------------------------------------------------------
/// @name Debugging EZAudio
///-----------------------------------------------------------

/**
 Globally sets whether or not the program should exit if a `checkResult:operation:` operation fails. Currently the behavior on EZAudio is to quit if a `checkResult:operation:` fails, but this is not desirable in any production environment. Internally there are a lot of `checkResult:operation:` operations used on all the core classes. This should only ever be set to NO in production environments since a `checkResult:operation:` failing means something breaking has likely happened.
 @param shouldExitOnCheckResultFail A BOOL indicating whether or not the running program should exist due to a `checkResult:operation:` fail.
 */
+ (void)setShouldExitOnCheckResultFail:(BOOL)shouldExitOnCheckResultFail;

//------------------------------------------------------------------------------

/**
 Provides a flag indicating whether or not the program will exit if a `checkResult:operation:` fails.
 @return A BOOL indicating whether or not the program will exit if a `checkResult:operation:` fails.
 */
+ (BOOL)shouldExitOnCheckResultFail;

//------------------------------------------------------------------------------
#pragma mark - AudioBufferList Utility
//------------------------------------------------------------------------------

///-----------------------------------------------------------
/// @name AudioBufferList Utility
///-----------------------------------------------------------

/**
 Allocates an AudioBufferList structure. Make sure to call freeBufferList when done using AudioBufferList or it will leak.
 @param frames The number of frames that will be stored within each audio buffer
 @param channels The number of channels (e.g. 2 for stereo, 1 for mono, etc.)
 @param interleaved Whether the samples will be interleaved (if not it will be assumed to be non-interleaved and each channel will have an AudioBuffer allocated)
 @return An AudioBufferList struct that has been allocated in memory
 */
+ (AudioBufferList *)audioBufferListWithNumberOfFrames:(UInt32)frames
                                      numberOfChannels:(UInt32)channels
                                           interleaved:(BOOL)interleaved;

//------------------------------------------------------------------------------

/**
 Allocates an array of float arrays given the number of frames needed to store in each float array.
 @param frames   A UInt32 representing the number of frames to store in each float buffer
 @param channels A UInt32 representing the number of channels (i.e. the number of float arrays to allocate)
 @return An array of float arrays, each the length of the number of frames specified
 */
+ (float **)floatBuffersWithNumberOfFrames:(UInt32)frames
                          numberOfChannels:(UInt32)channels;

//------------------------------------------------------------------------------

/**
 Deallocates an AudioBufferList structure from memory.
 @param bufferList A pointer to the buffer list you would like to free
 */
+ (void)freeBufferList:(AudioBufferList *)bufferList;

//------------------------------------------------------------------------------

/**
 Deallocates an array of float buffers
 @param buffers  An array of float arrays
 @param channels A UInt32 representing the number of channels (i.e. the number of float arrays to deallocate)
 */
+ (void)freeFloatBuffers:(float **)buffers numberOfChannels:(UInt32)channels;

//------------------------------------------------------------------------------
#pragma mark - AudioStreamBasicDescription Utilties
//------------------------------------------------------------------------------

///-----------------------------------------------------------
/// @name Creating An AudioStreamBasicDescription
///-----------------------------------------------------------

/**
 Creates a signed-integer, interleaved AudioStreamBasicDescription for the number of channels specified for an AIFF format.
 @param channels   The desired number of channels
 @param sampleRate A float representing the sample rate.
 @return A new AudioStreamBasicDescription with the specified format.
 */
+ (AudioStreamBasicDescription)AIFFFormatWithNumberOfChannels:(UInt32)channels
                                                   sampleRate:(float)sampleRate;

//------------------------------------------------------------------------------

/**
 Creates an AudioStreamBasicDescription for the iLBC narrow band speech codec.
 @param sampleRate A float representing the sample rate.
 @return A new AudioStreamBasicDescription with the specified format.
 */
+ (AudioStreamBasicDescription)iLBCFormatWithSampleRate:(float)sampleRate;

//------------------------------------------------------------------------------

/**
 Creates a float-based, non-interleaved AudioStreamBasicDescription for the number of channels specified.
 @param channels   A UInt32 representing the number of channels.
 @param sampleRate A float representing the sample rate.
 @return A float-based AudioStreamBasicDescription with the number of channels specified.
 */
+ (AudioStreamBasicDescription)floatFormatWithNumberOfChannels:(UInt32)channels
                                                    sampleRate:(float)sampleRate;

//------------------------------------------------------------------------------

/**
 Creates an AudioStreamBasicDescription for an M4A AAC format.
 @param channels   The desired number of channels
 @param sampleRate A float representing the sample rate.
 @return A new AudioStreamBasicDescription with the specified format.
 */
+ (AudioStreamBasicDescription)M4AFormatWithNumberOfChannels:(UInt32)channels
                                                  sampleRate:(float)sampleRate;

//------------------------------------------------------------------------------

/**
 Creates a single-channel, float-based AudioStreamBasicDescription.
 @param sampleRate A float representing the sample rate.
 @return A new AudioStreamBasicDescription with the specified format.
 */
+ (AudioStreamBasicDescription)monoFloatFormatWithSampleRate:(float)sampleRate;

//------------------------------------------------------------------------------

/**
 Creates a single-channel, float-based AudioStreamBasicDescription (as of 0.0.6 this is the same as `monoFloatFormatWithSampleRate:`).
 @param sampleRate A float representing the sample rate.
 @return A new AudioStreamBasicDescription with the specified format.
 */
+ (AudioStreamBasicDescription)monoCanonicalFormatWithSampleRate:(float)sampleRate;

//------------------------------------------------------------------------------

/**
 Creates a two-channel, non-interleaved, float-based AudioStreamBasicDescription (as of 0.0.6 this is the same as `stereoFloatNonInterleavedFormatWithSampleRate:`).
 @param sampleRate A float representing the sample rate.
 @return A new AudioStreamBasicDescription with the specified format.
 */
+ (AudioStreamBasicDescription)stereoCanonicalNonInterleavedFormatWithSampleRate:(float)sampleRate;

//------------------------------------------------------------------------------

/**
 Creates a two-channel, interleaved, float-based AudioStreamBasicDescription.
 @param sampleRate A float representing the sample rate.
 @return A new AudioStreamBasicDescription with the specified format.
 */
+ (AudioStreamBasicDescription)stereoFloatInterleavedFormatWithSampleRate:(float)sampleRate;

//------------------------------------------------------------------------------

/**
 Creates a two-channel, non-interleaved, float-based AudioStreamBasicDescription.
 @param sampleRate A float representing the sample rate.
 @return A new AudioStreamBasicDescription with the specified format.
 */
+ (AudioStreamBasicDescription)stereoFloatNonInterleavedFormatWithSampleRate:(float)sampleRate;

//------------------------------------------------------------------------------
// @name AudioStreamBasicDescription Helper Functions
//------------------------------------------------------------------------------

/**
 Checks an AudioStreamBasicDescription to see if it is a float-based format (as opposed to a signed integer based format).
 @param asbd A valid AudioStreamBasicDescription
 @return A BOOL indicating whether or not the AudioStreamBasicDescription is a float format.
 */
+ (BOOL)isFloatFormat:(AudioStreamBasicDescription)asbd;

//------------------------------------------------------------------------------

/**
 Checks an AudioStreamBasicDescription to check for an interleaved flag (samples are
 stored in one buffer one after another instead of two (or n channels) parallel buffers
 @param asbd A valid AudioStreamBasicDescription
 @return A BOOL indicating whether or not the AudioStreamBasicDescription is interleaved
 */
+ (BOOL)isInterleaved:(AudioStreamBasicDescription)asbd;

//------------------------------------------------------------------------------

/**
 Checks an AudioStreamBasicDescription to see if it is a linear PCM format (uncompressed,
 1 frame per packet)
 @param asbd A valid AudioStreamBasicDescription
 @return A BOOL indicating whether or not the AudioStreamBasicDescription is linear PCM.
 */
+ (BOOL)isLinearPCM:(AudioStreamBasicDescription)asbd;

///-----------------------------------------------------------
/// @name AudioStreamBasicDescription Utilities
///-----------------------------------------------------------

/**
 Nicely logs out the contents of an AudioStreamBasicDescription struct
 @param asbd The AudioStreamBasicDescription struct with content to print out
 */
+ (void)printASBD:(AudioStreamBasicDescription)asbd;

//------------------------------------------------------------------------------

/**
 Converts seconds into a string formatted as MM:SS
 @param seconds An NSTimeInterval representing the number of seconds
 @return An NSString instance formatted as MM:SS from the seconds provided.
 */
+ (NSString *)displayTimeStringFromSeconds:(NSTimeInterval)seconds;

//------------------------------------------------------------------------------

/**
 Creates a string to use when logging out the contents of an AudioStreamBasicDescription
 @param asbd A valid AudioStreamBasicDescription struct.
 @return An NSString representing the contents of the AudioStreamBasicDescription.
 */
+ (NSString *)stringForAudioStreamBasicDescription:(AudioStreamBasicDescription)asbd;

//------------------------------------------------------------------------------

/**
 Just a wrapper around the setCanonical function provided in the Core Audio Utility C++ class.
 @param asbd        The AudioStreamBasicDescription structure to modify
 @param nChannels   The number of expected channels on the description
 @param interleaved A flag indicating whether the stereo samples should be interleaved in the buffer
 */
+ (void)setCanonicalAudioStreamBasicDescription:(AudioStreamBasicDescription*)asbd
                               numberOfChannels:(UInt32)nChannels
                                    interleaved:(BOOL)interleaved;

//------------------------------------------------------------------------------
#pragma mark - Math Utilities
//------------------------------------------------------------------------------

///-----------------------------------------------------------
/// @name Math Utilities
///-----------------------------------------------------------

/**
 Appends an array of values to a history buffer and performs an internal shift to add the values to the tail and removes the same number of values from the head.
 @param buffer              A float array of values to append to the tail of the history buffer
 @param bufferLength        The length of the float array being appended to the history buffer
 @param scrollHistory       The target history buffer in which to append the values
 @param scrollHistoryLength The length of the target history buffer
 */
+ (void)appendBufferAndShift:(float*)buffer
              withBufferSize:(int)bufferLength
             toScrollHistory:(float*)scrollHistory
       withScrollHistorySize:(int)scrollHistoryLength;

//------------------------------------------------------------------------------

/**
 Appends a value to a history buffer and performs an internal shift to add the value to the tail and remove the 0th value.
 @param value               The float value to append to the history array
 @param scrollHistory       The target history buffer in which to append the values
 @param scrollHistoryLength The length of the target history buffer
 */
+(void)    appendValue:(float)value
       toScrollHistory:(float*)scrollHistory
 withScrollHistorySize:(int)scrollHistoryLength;

//------------------------------------------------------------------------------

/**
 Maps a value from one coordinate system into another one. Takes in the current value to map, the minimum and maximum values of the first coordinate system, and the minimum and maximum values of the second coordinate system and calculates the mapped value in the second coordinate system's constraints.
 @param 	value 	The value expressed in the first coordinate system
 @param 	leftMin 	The minimum of the first coordinate system
 @param 	leftMax 	The maximum of the first coordinate system
 @param 	rightMin 	The minimum of the second coordindate system
 @param 	rightMax 	The maximum of the second coordinate system
 @return	The mapped value in terms of the second coordinate system
 */
+ (float)MAP:(float)value
     leftMin:(float)leftMin
     leftMax:(float)leftMax
    rightMin:(float)rightMin
    rightMax:(float)rightMax;

//------------------------------------------------------------------------------

/**
 Calculates the root mean squared for a buffer.
 @param 	buffer 	A float buffer array of values whose root mean squared to calculate
 @param 	bufferSize 	The size of the float buffer
 @return	The root mean squared of the buffer
 */
+ (float)RMS:(float*)buffer length:(int)bufferSize;

//------------------------------------------------------------------------------

/**
 Calculate the sign function sgn(x) =
 {  -1 , x < 0,
 {   0 , x = 0,
 {   1 , x > 0
 @param value The float value for which to use as x
 @return The float sign value
 */
+ (float)SGN:(float)value;

//------------------------------------------------------------------------------
#pragma mark - Music Utilities
//------------------------------------------------------------------------------

+ (NSString *)noteNameStringForFrequency:(float)frequency
                           includeOctave:(BOOL)includeOctave;

//------------------------------------------------------------------------------
#pragma mark - OSStatus Utility
//------------------------------------------------------------------------------

///-----------------------------------------------------------
/// @name OSStatus Utility
///-----------------------------------------------------------

/**
 Basic check result function useful for checking each step of the audio setup process
 @param result    The OSStatus representing the result of an operation
 @param operation A string (const char, not NSString) describing the operation taking place (will print if fails)
 */
+ (void)checkResult:(OSStatus)result operation:(const char *)operation;

//------------------------------------------------------------------------------

/**
 Provides a string representation of the often cryptic Core Audio error codes
 @param code A UInt32 representing an error code
 @return An NSString with a human readable version of the error code.
 */
+ (NSString *)stringFromUInt32Code:(UInt32)code;

//------------------------------------------------------------------------------
#pragma mark - Color Utility
//------------------------------------------------------------------------------

///-----------------------------------------------------------
/// @name Color Utility
///-----------------------------------------------------------

/**
 Helper function to get the color components from a CGColorRef in the RGBA colorspace.
 @param color A CGColorRef that represents a color.
 @param red   A pointer to a CGFloat to hold the value of the red component. This value will be between 0 and 1.
 @param green A pointer to a CGFloat to hold the value of the green component. This value will be between 0 and 1.
 @param blue  A pointer to a CGFloat to hold the value of the blue component. This value will be between 0 and 1.
 @param alpha A pointer to a CGFloat to hold the value of the alpha component. This value will be between 0 and 1.
 */
+ (void)getColorComponentsFromCGColor:(CGColorRef)color
                                  red:(CGFloat *)red
                                green:(CGFloat *)green
                                 blue:(CGFloat *)blue
                                alpha:(CGFloat *)alpha;

//------------------------------------------------------------------------------
#pragma mark - Plot Utility
//------------------------------------------------------------------------------

///-----------------------------------------------------------
/// @name Plot Utility
///-----------------------------------------------------------

/**
 Given a buffer representing a window of float history data this append the RMS of a buffer of incoming float data...This will likely be deprecated in a future version of EZAudio for a circular buffer based approach.
 @param scrollHistory       An array of float arrays being used to hold the history values for each channel.
 @param scrollHistoryLength An int representing the length of the history window.
 @param index               An int pointer to the index of the current read index of the history buffer.
 @param buffer              A float array representing the incoming audio data.
 @param bufferSize          An int representing the length of the incoming audio data.
 @param isChanging          A BOOL pointer representing whether the resolution (length of the history window) is currently changing.
 */
+ (void)updateScrollHistory:(float **)scrollHistory
                 withLength:(int)scrollHistoryLength
                    atIndex:(int *)index
                 withBuffer:(float *)buffer
             withBufferSize:(int)bufferSize
       isResolutionChanging:(BOOL *)isChanging;

//------------------------------------------------------------------------------
#pragma mark - TPCircularBuffer Utility
//------------------------------------------------------------------------------

///-----------------------------------------------------------
/// @name TPCircularBuffer Utility
///-----------------------------------------------------------

/**
 Appends the data from the audio buffer list to the circular buffer
 @param circularBuffer  Pointer to the instance of the TPCircularBuffer to add the audio data to
 @param audioBufferList Pointer to the instance of the AudioBufferList with the audio data
 */
+ (void)appendDataToCircularBuffer:(TPCircularBuffer*)circularBuffer
               fromAudioBufferList:(AudioBufferList*)audioBufferList;

//------------------------------------------------------------------------------

/**
 Initializes the circular buffer (just a wrapper around the C method)
 @param circularBuffer Pointer to an instance of the TPCircularBuffer
 @param size           The length of the TPCircularBuffer (usually 1024)
 */
+ (void)circularBuffer:(TPCircularBuffer*)circularBuffer
              withSize:(int)size;

//------------------------------------------------------------------------------

/**
 Frees a circular buffer
 @param circularBuffer Pointer to the circular buffer to clear
 */
+ (void)freeCircularBuffer:(TPCircularBuffer*)circularBuffer;

//------------------------------------------------------------------------------
#pragma mark - EZPlotHistoryInfo Utility
//------------------------------------------------------------------------------

/**
 Calculates the RMS of a float array containing audio data and appends it to the tail of a EZPlotHistoryInfo data structure. Thread-safe.
 @param buffer      A float array containing the incoming audio buffer to append to the history buffer
 @param bufferSize  A UInt32 representing the length of the incoming audio buffer
 @param historyInfo A pointer to a EZPlotHistoryInfo structure to use for managing the history buffers
 */
+ (void)appendBufferRMS:(float *)buffer
         withBufferSize:(UInt32)bufferSize
          toHistoryInfo:(EZPlotHistoryInfo *)historyInfo;

//------------------------------------------------------------------------------

/**
 Appends a buffer of audio data to the tail of a EZPlotHistoryInfo data structure. Thread-safe.
 @param buffer      A float array containing the incoming audio buffer to append to the history buffer
 @param bufferSize  A UInt32 representing the length of the incoming audio buffer
 @param historyInfo A pointer to a EZPlotHistoryInfo structure to use for managing the history buffers
 */
+ (void)appendBuffer:(float *)buffer
      withBufferSize:(UInt32)bufferSize
       toHistoryInfo:(EZPlotHistoryInfo *)historyInfo;

//------------------------------------------------------------------------------

/**
 Zeroes out a EZPlotHistoryInfo data structure without freeing the resources.
 @param historyInfo A pointer to a EZPlotHistoryInfo data structure
 */
+ (void)clearHistoryInfo:(EZPlotHistoryInfo *)historyInfo;

//------------------------------------------------------------------------------

/**
 Frees a EZPlotHistoryInfo data structure
 @param historyInfo A pointer to a EZPlotHistoryInfo data structure
 */
+ (void)freeHistoryInfo:(EZPlotHistoryInfo *)historyInfo;

//------------------------------------------------------------------------------

/**
 Creates an EZPlotHistoryInfo data structure with a default length for the window buffer and a maximum length capacity for the internal circular buffer that holds all the audio data.
 @param defaultLength An int representing the default length (i.e. the number of points that will be displayed on screen) of the history window.
 @param maximumLength An int representing the default maximum length that is the absolute maximum amount of values that can be held in the history's circular buffer.
 @return A pointer to the EZPlotHistoryInfo created. The caller is responsible for freeing this structure using the `freeHistoryInfo` method above.
 */
+ (EZPlotHistoryInfo *)historyInfoWithDefaultLength:(int)defaultLength
                                      maximumLength:(int)maximumLength;

//------------------------------------------------------------------------------

@end
