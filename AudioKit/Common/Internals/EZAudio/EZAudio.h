//
//  EZAudio.h
//  EZAudio
//
//  Created by Syed Haris Ali on 11/21/13.
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

//! Project version number for teat.
FOUNDATION_EXPORT double EZAudioVersionNumber;

//! Project version string for teat.
FOUNDATION_EXPORT const unsigned char EZAudioVersionString[];

//------------------------------------------------------------------------------
#pragma mark - Core Components
//------------------------------------------------------------------------------

#import "EZAudioDevice.h"
#import "EZAudioFile.h"
#import "EZMicrophone.h"
#import "EZOutput.h"
#import "EZRecorder.h"
#import "EZAudioPlayer.h"
#import "EZAudioFileMarker.h"



//------------------------------------------------------------------------------
#pragma mark - Utility Components
//------------------------------------------------------------------------------

#import "EZAudioFFT.h"
#import "EZAudioFloatConverter.h"
#import "EZAudioFloatData.h"
#import "EZAudioUtilities.h"

//------------------------------------------------------------------------------

/**
 EZAudio is a simple, intuitive framework for iOS and OSX. The goal of EZAudio was to provide a modular, cross-platform framework to simplify performing everyday audio operations like getting microphone input, creating audio waveforms, recording/playing audio files, etc. The visualization tools like the EZAudioPlot and EZAudioPlotGL were created to plug right into the framework's various components and provide highly optimized drawing routines that work in harmony with audio callback loops. All components retain the same namespace whether you're on an iOS device or a Mac computer so an EZAudioPlot understands it will subclass an UIView on an iOS device or an NSView on a Mac.
 
 Class methods for EZAudio are provided as utility methods used throughout the other modules within the framework. For instance, these methods help make sense of error codes (checkResult:operation:), map values betwen coordinate systems (MAP:leftMin:leftMax:rightMin:rightMax:), calculate root mean squared values for buffers (RMS:length:), etc.
 
 @warning As of 1.0 these methods have been moved over to `EZAudioUtilities` to allow using specific modules without requiring the whole library.
 */
@interface EZAudio : NSObject

//------------------------------------------------------------------------------
#pragma mark - Debugging
//------------------------------------------------------------------------------

///-----------------------------------------------------------
/// @name Debugging EZAudio
///-----------------------------------------------------------

/**
 Globally sets whether or not the program should exit if a `checkResult:operation:` operation fails. Currently the behavior on EZAudio is to quit if a `checkResult:operation:` fails, but this is not desirable in any production environment. Internally there are a lot of `checkResult:operation:` operations used on all the core classes. This should only ever be set to NO in production environments since a `checkResult:operation:` failing means something breaking has likely happened.
 @param shouldExitOnCheckResultFail A BOOL indicating whether or not the running program should exist due to a `checkResult:operation:` fail.
 @deprecated This method is deprecated starting in version 0.1.0.
 @note Please use same method in EZAudioUtilities class instead.
 */
+ (void)setShouldExitOnCheckResultFail:(BOOL)shouldExitOnCheckResultFail __attribute__((deprecated));

//------------------------------------------------------------------------------

/**
 Provides a flag indicating whether or not the program will exit if a `checkResult:operation:` fails.
 @deprecated This method is deprecated starting in version 0.1.0.
 @note Please use same method in EZAudioUtilities class instead.
 @return A BOOL indicating whether or not the program will exit if a `checkResult:operation:` fails.
 */
+ (BOOL)shouldExitOnCheckResultFail __attribute__((deprecated));

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
 @deprecated This method is deprecated starting in version 0.1.0.
 @note Please use same method in EZAudioUtilities class instead.
 @return An AudioBufferList struct that has been allocated in memory
 */
+ (AudioBufferList *)audioBufferListWithNumberOfFrames:(UInt32)frames
                                      numberOfChannels:(UInt32)channels
                                           interleaved:(BOOL)interleaved __attribute__((deprecated));

//------------------------------------------------------------------------------

/**
 Allocates an array of float arrays given the number of frames needed to store in each float array.
 @param frames   A UInt32 representing the number of frames to store in each float buffer
 @param channels A UInt32 representing the number of channels (i.e. the number of float arrays to allocate)
 @deprecated This method is deprecated starting in version 0.1.0.
 @note Please use same method in EZAudioUtilities class instead.
 @return An array of float arrays, each the length of the number of frames specified
 */
+ (float **)floatBuffersWithNumberOfFrames:(UInt32)frames
                          numberOfChannels:(UInt32)channels __attribute__((deprecated));

//------------------------------------------------------------------------------

/**
 Deallocates an AudioBufferList structure from memory.
 @param bufferList A pointer to the buffer list you would like to free
 @deprecated This method is deprecated starting in version 0.1.0.
 @note Please use same method in EZAudioUtilities class instead.
 */
+ (void)freeBufferList:(AudioBufferList *)bufferList __attribute__((deprecated));

//------------------------------------------------------------------------------

/**
 Deallocates an array of float buffers
 @param buffers  An array of float arrays
 @param channels A UInt32 representing the number of channels (i.e. the number of float arrays to deallocate)
 @deprecated This method is deprecated starting in version 0.1.0.
 @note Please use same method in EZAudioUtilities class instead.
 */
+ (void)freeFloatBuffers:(float **)buffers numberOfChannels:(UInt32)channels __attribute__((deprecated));

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
 @deprecated This method is deprecated starting in version 0.1.0.
 @note Please use same method in EZAudioUtilities class instead.
 @return A new AudioStreamBasicDescription with the specified format.
 */
+ (AudioStreamBasicDescription)AIFFFormatWithNumberOfChannels:(UInt32)channels
                                                   sampleRate:(float)sampleRate __attribute__((deprecated));

//------------------------------------------------------------------------------

/**
 Creates an AudioStreamBasicDescription for the iLBC narrow band speech codec.
 @param sampleRate A float representing the sample rate.
 @deprecated This method is deprecated starting in version 0.1.0.
 @note Please use same method in EZAudioUtilities class instead.
 @return A new AudioStreamBasicDescription with the specified format.
 */
+ (AudioStreamBasicDescription)iLBCFormatWithSampleRate:(float)sampleRate __attribute__((deprecated));

//------------------------------------------------------------------------------

/**
 Creates a float-based, non-interleaved AudioStreamBasicDescription for the number of channels specified.
 @param channels   A UInt32 representing the number of channels.
 @param sampleRate A float representing the sample rate.
 @deprecated This method is deprecated starting in version 0.1.0.
 @note Please use same method in EZAudioUtilities class instead.
 @return A float-based AudioStreamBasicDescription with the number of channels specified.
 */
+ (AudioStreamBasicDescription)floatFormatWithNumberOfChannels:(UInt32)channels
                                                    sampleRate:(float)sampleRate __attribute__((deprecated));

//------------------------------------------------------------------------------

/**
 Creates an AudioStreamBasicDescription for an M4A AAC format.
 @param channels   The desired number of channels
 @param sampleRate A float representing the sample rate.
 @deprecated This method is deprecated starting in version 0.1.0.
 @note Please use same method in EZAudioUtilities class instead.
 @return A new AudioStreamBasicDescription with the specified format.
 */
+ (AudioStreamBasicDescription)M4AFormatWithNumberOfChannels:(UInt32)channels
                                                  sampleRate:(float)sampleRate __attribute__((deprecated));

//------------------------------------------------------------------------------

/**
 Creates a single-channel, float-based AudioStreamBasicDescription.
 @param sampleRate A float representing the sample rate.
 @deprecated This method is deprecated starting in version 0.1.0.
 @note Please use same method in EZAudioUtilities class instead.
 @return A new AudioStreamBasicDescription with the specified format.
 */
+ (AudioStreamBasicDescription)monoFloatFormatWithSampleRate:(float)sampleRate __attribute__((deprecated));

//------------------------------------------------------------------------------

/**
 Creates a single-channel, float-based AudioStreamBasicDescription (as of 0.0.6 this is the same as `monoFloatFormatWithSampleRate:`).
 @param sampleRate A float representing the sample rate.
 @return A new AudioStreamBasicDescription with the specified format.
 @deprecated This method is deprecated starting in version 0.1.0.
 @note Please use same method in EZAudioUtilities class instead.
 */
+ (AudioStreamBasicDescription)monoCanonicalFormatWithSampleRate:(float)sampleRate __attribute__((deprecated));

//------------------------------------------------------------------------------

/**
 Creates a two-channel, non-interleaved, float-based AudioStreamBasicDescription (as of 0.0.6 this is the same as `stereoFloatNonInterleavedFormatWithSampleRate:`).
 @param sampleRate A float representing the sample rate.
 @deprecated This method is deprecated starting in version 0.1.0.
 @note Please use same method in EZAudioUtilities class instead.
 @return A new AudioStreamBasicDescription with the specified format.
 */
+ (AudioStreamBasicDescription)stereoCanonicalNonInterleavedFormatWithSampleRate:(float)sampleRate __attribute__((deprecated));

//------------------------------------------------------------------------------

/**
 Creates a two-channel, interleaved, float-based AudioStreamBasicDescription.
 @param sampleRate A float representing the sample rate.
 @deprecated This method is deprecated starting in version 0.1.0.
 @note Please use same method in EZAudioUtilities class instead.
 @return A new AudioStreamBasicDescription with the specified format.
 */
+ (AudioStreamBasicDescription)stereoFloatInterleavedFormatWithSampleRate:(float)sampleRate __attribute__((deprecated));

//------------------------------------------------------------------------------

/**
 Creates a two-channel, non-interleaved, float-based AudioStreamBasicDescription.
 @param sampleRate A float representing the sample rate.
 @deprecated This method is deprecated starting in version 0.1.0.
 @note Please use same method in EZAudioUtilities class instead.
 @return A new AudioStreamBasicDescription with the specified format.
 */
+ (AudioStreamBasicDescription)stereoFloatNonInterleavedFormatWithSampleRate:(float)sampleRate __attribute__((deprecated));

//------------------------------------------------------------------------------
// @name AudioStreamBasicDescription Helper Functions
//------------------------------------------------------------------------------

/**
 Checks an AudioStreamBasicDescription to see if it is a float-based format (as opposed to a signed integer based format).
 @param asbd A valid AudioStreamBasicDescription
 @deprecated This method is deprecated starting in version 0.1.0.
 @note Please use same method in EZAudioUtilities class instead.
 @return A BOOL indicating whether or not the AudioStreamBasicDescription is a float format.
 */
+ (BOOL)isFloatFormat:(AudioStreamBasicDescription)asbd __attribute__((deprecated));

//------------------------------------------------------------------------------

/**
 Checks an AudioStreamBasicDescription to check for an interleaved flag (samples are
 stored in one buffer one after another instead of two (or n channels) parallel buffers
 @param asbd A valid AudioStreamBasicDescription
 @deprecated This method is deprecated starting in version 0.1.0.
 @note Please use same method in EZAudioUtilities class instead.
 @return A BOOL indicating whether or not the AudioStreamBasicDescription is interleaved
 */
+ (BOOL)isInterleaved:(AudioStreamBasicDescription)asbd __attribute__((deprecated));

//------------------------------------------------------------------------------

/**
 Checks an AudioStreamBasicDescription to see if it is a linear PCM format (uncompressed,
 1 frame per packet)
 @param asbd A valid AudioStreamBasicDescription
 @deprecated This method is deprecated starting in version 0.1.0.
 @note Please use same method in EZAudioUtilities class instead.
 @return A BOOL indicating whether or not the AudioStreamBasicDescription is linear PCM.
 */
+ (BOOL)isLinearPCM:(AudioStreamBasicDescription)asbd __attribute__((deprecated));

///-----------------------------------------------------------
/// @name AudioStreamBasicDescription Utilities
///-----------------------------------------------------------

/**
 Nicely logs out the contents of an AudioStreamBasicDescription struct
 @param asbd The AudioStreamBasicDescription struct with content to print out
 @deprecated This method is deprecated starting in version 0.1.0.
 @note Please use same method in EZAudioUtilities class instead.
 */
+ (void)printASBD:(AudioStreamBasicDescription)asbd __attribute__((deprecated));

//------------------------------------------------------------------------------

/**
 Converts seconds into a string formatted as MM:SS
 @param seconds An NSTimeInterval representing the number of seconds
 @deprecated This method is deprecated starting in version 0.1.0.
 @note Please use same method in EZAudioUtilities class instead.
 @return An NSString instance formatted as MM:SS from the seconds provided.
 */
+ (NSString *)displayTimeStringFromSeconds:(NSTimeInterval)seconds __attribute__((deprecated));

//------------------------------------------------------------------------------

/**
 Creates a string to use when logging out the contents of an AudioStreamBasicDescription
 @param asbd A valid AudioStreamBasicDescription struct.
 @deprecated This method is deprecated starting in version 0.1.0.
 @note Please use same method in EZAudioUtilities class instead.
 @return An NSString representing the contents of the AudioStreamBasicDescription.
 */
+ (NSString *)stringForAudioStreamBasicDescription:(AudioStreamBasicDescription)asbd __attribute__((deprecated));

//------------------------------------------------------------------------------

/**
 Just a wrapper around the setCanonical function provided in the Core Audio Utility C++ class.
 @param asbd        The AudioStreamBasicDescription structure to modify
 @param nChannels   The number of expected channels on the description
 @param interleaved A flag indicating whether the stereo samples should be interleaved in the buffer
 @deprecated This method is deprecated starting in version 0.1.0.
 @note Please use same method in EZAudioUtilities class instead.
 */
+ (void)setCanonicalAudioStreamBasicDescription:(AudioStreamBasicDescription*)asbd
                               numberOfChannels:(UInt32)nChannels
                                    interleaved:(BOOL)interleaved __attribute__((deprecated));

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
 @deprecated This method is deprecated starting in version 0.1.0.
 @note Please use same method in EZAudioUtilities class instead.
 */
+ (void)appendBufferAndShift:(float*)buffer
              withBufferSize:(int)bufferLength
             toScrollHistory:(float*)scrollHistory
       withScrollHistorySize:(int)scrollHistoryLength __attribute__((deprecated));

//------------------------------------------------------------------------------

/**
 Appends a value to a history buffer and performs an internal shift to add the value to the tail and remove the 0th value.
 @param value               The float value to append to the history array
 @param scrollHistory       The target history buffer in which to append the values
 @param scrollHistoryLength The length of the target history buffer
 @deprecated This method is deprecated starting in version 0.1.0.
 @note Please use same method in EZAudioUtilities class instead.
 */
+(void)    appendValue:(float)value
       toScrollHistory:(float*)scrollHistory
 withScrollHistorySize:(int)scrollHistoryLength __attribute__((deprecated));

//------------------------------------------------------------------------------

/**
 Maps a value from one coordinate system into another one. Takes in the current value to map, the minimum and maximum values of the first coordinate system, and the minimum and maximum values of the second coordinate system and calculates the mapped value in the second coordinate system's constraints.
 @param 	value 	The value expressed in the first coordinate system
 @param 	leftMin 	The minimum of the first coordinate system
 @param 	leftMax 	The maximum of the first coordinate system
 @param 	rightMin 	The minimum of the second coordindate system
 @param 	rightMax 	The maximum of the second coordinate system
 @deprecated This method is deprecated starting in version 0.1.0.
 @note Please use same method in EZAudioUtilities class instead.
 @return	The mapped value in terms of the second coordinate system
 */
+ (float)MAP:(float)value
     leftMin:(float)leftMin
     leftMax:(float)leftMax
    rightMin:(float)rightMin
    rightMax:(float)rightMax __attribute__((deprecated));

//------------------------------------------------------------------------------

/**
 Calculates the root mean squared for a buffer.
 @param 	buffer 	A float buffer array of values whose root mean squared to calculate
 @param 	bufferSize 	The size of the float buffer
 @deprecated This method is deprecated starting in version 0.1.0.
 @note Please use same method in EZAudioUtilities class instead.
 @return	The root mean squared of the buffer
 */
+ (float)RMS:(float*)buffer length:(int)bufferSize __attribute__((deprecated));

//------------------------------------------------------------------------------

/**
 Calculate the sign function sgn(x) =
 {  -1 , x < 0,
 {   0 , x = 0,
 {   1 , x > 0
 @param value The float value for which to use as x
 @deprecated This method is deprecated starting in version 0.1.0.
 @note Please use same method in EZAudioUtilities class instead.
 @return The float sign value
 */
+ (float)SGN:(float)value __attribute__((deprecated));

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
 @deprecated This method is deprecated starting in version 0.1.0.
 @note Please use same method in EZAudioUtilities class instead.
 */
+ (void)checkResult:(OSStatus)result operation:(const char *)operation __attribute__((deprecated));

//------------------------------------------------------------------------------

/**
 Provides a string representation of the often cryptic Core Audio error codes
 @param code A UInt32 representing an error code
 @deprecated This method is deprecated starting in version 0.1.0.
 @note Please use same method in EZAudioUtilities class instead.
 @return An NSString with a human readable version of the error code.
 */
+ (NSString *)stringFromUInt32Code:(UInt32)code __attribute__((deprecated));

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
 @deprecated This method is deprecated starting in version 0.1.0.
 @note Please use same method in EZAudioUtilities class instead.
 */
+ (void)updateScrollHistory:(float **)scrollHistory
                 withLength:(int)scrollHistoryLength
                    atIndex:(int *)index
                 withBuffer:(float *)buffer
             withBufferSize:(int)bufferSize
       isResolutionChanging:(BOOL *)isChanging __attribute__((deprecated));

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
 @deprecated This method is deprecated starting in version 0.1.0.
 @note Please use same method in EZAudioUtilities class instead.
 */
+ (void)appendDataToCircularBuffer:(TPCircularBuffer*)circularBuffer
               fromAudioBufferList:(AudioBufferList*)audioBufferList __attribute__((deprecated));

//------------------------------------------------------------------------------

/**
 Initializes the circular buffer (just a wrapper around the C method)
 @param circularBuffer Pointer to an instance of the TPCircularBuffer
 @param size           The length of the TPCircularBuffer (usually 1024)
 @deprecated This method is deprecated starting in version 0.1.0.
 @note Please use same method in EZAudioUtilities class instead.
 */
+ (void)circularBuffer:(TPCircularBuffer*)circularBuffer
              withSize:(int)size __attribute__((deprecated));

//------------------------------------------------------------------------------

/**
 Frees a circular buffer
 @param circularBuffer Pointer to the circular buffer to clear
 @deprecated This method is deprecated starting in version 0.1.0.
 @note Please use same method in EZAudioUtilities class instead.
 */
+ (void)freeCircularBuffer:(TPCircularBuffer*)circularBuffer __attribute__((deprecated));

//------------------------------------------------------------------------------

@end
