//
//  EZAudioFile.h
//  EZAudio
//
//  Created by Syed Haris Ali on 12/1/13.
//  Copyright (c) 2013 Syed Haris Ali. All rights reserved.
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
#import "EZAudioFloatData.h"

//------------------------------------------------------------------------------

@class EZAudio;
@class EZAudioFile;

//------------------------------------------------------------------------------
#pragma mark - Blocks
//------------------------------------------------------------------------------
/**
 A block used when returning back the waveform data. The waveform data itself will be an array of float arrays, one for each channel, and the length indicates the total length of each float array.
 @param waveformData An array of float arrays, each representing a channel of audio data from the file
 @param length       An int representing the length of each channel of float audio data
 */
typedef void (^EZAudioWaveformDataCompletionBlock)(float **waveformData, int length);

//------------------------------------------------------------------------------
#pragma mark - EZAudioFileDelegate
//------------------------------------------------------------------------------
/**
 The EZAudioFileDelegate provides event callbacks for the EZAudioFile object. These type of events are triggered by reads and seeks on the file and gives feedback such as the audio data read as a float array for visualizations and the new seek position for UI updating.
 */
@protocol EZAudioFileDelegate <NSObject>

@optional
/**
 Triggered from the EZAudioFile function `readFrames:audioBufferList:bufferSize:eof:` to notify the delegate of the read audio data as a float array instead of a buffer list. Common use case of this would be to visualize the float data using an audio plot or audio data dependent OpenGL sketch.
 @param audioFile        The instance of the EZAudioFile that triggered the event.
 @param buffer           A float array of float arrays holding the audio data. buffer[0] would be the left channel's float array while buffer[1] would be the right channel's float array in a stereo file.
 @param bufferSize       The length of the buffers float arrays
 @param numberOfChannels The number of channels. 2 for stereo, 1 for mono.
 */
- (void)     audioFile:(EZAudioFile *)audioFile
             readAudio:(float **)buffer
        withBufferSize:(UInt32)bufferSize
  withNumberOfChannels:(UInt32)numberOfChannels;

//------------------------------------------------------------------------------

/**
 Occurs when the audio file's internal seek position has been updated by the EZAudioFile functions `readFrames:audioBufferList:bufferSize:eof:` or `audioFile:updatedPosition:`. As of 0.8.0 this is the preferred method of listening for position updates on the audio file since a user may want the pull the currentTime, formattedCurrentTime, or the frame index from the EZAudioFile instance provided.
 @param audioFile The instance of the EZAudio in which the change occurred.
 */
- (void)audioFileUpdatedPosition:(EZAudioFile *)audioFile;

//------------------------------------------------------------------------------

/**
 Occurs when the audio file's internal seek position has been updated by the EZAudioFile functions `readFrames:audioBufferList:bufferSize:eof:` or `audioFile:updatedPosition:`.
 @param audioFile     The instance of the EZAudio in which the change occurred
 @param framePosition The new frame index as a 64-bit signed integer
 @deprecated This property is deprecated starting in version 0.8.0.
 @note Please use `audioFileUpdatedPosition:` property instead.
 */
- (void)audioFile:(EZAudioFile *)audioFile
  updatedPosition:(SInt64)framePosition  __attribute__((deprecated));

@end

//------------------------------------------------------------------------------
#pragma mark - EZAudioFile
//------------------------------------------------------------------------------
/**
 The EZAudioFile provides a lightweight and intuitive way to asynchronously interact with audio files. These interactions included reading audio data, seeking within an audio file, getting information about the file, and pulling the waveform data for visualizing the contents of the audio file. The EZAudioFileDelegate provides event callbacks for when reads, seeks, and various updates happen within the audio file to allow the caller to interact with the action in meaningful ways. Common use cases here could be to read the audio file's data as AudioBufferList structures for output (see EZOutput) and visualizing the audio file's data as a float array using an audio plot (see EZAudioPlot).
 */
@interface EZAudioFile : NSObject <NSCopying>

//------------------------------------------------------------------------------
#pragma mark - Properties
//------------------------------------------------------------------------------

/**
 A EZAudioFileDelegate for the audio file that is used to return events such as new seek positions within the file and the read audio data as a float array.
 */
@property (nonatomic, weak) id<EZAudioFileDelegate> delegate;

//------------------------------------------------------------------------------
#pragma mark - Initialization
//------------------------------------------------------------------------------
/**
 @name Initialization
*/

/**
 Creates a new instance of the EZAudioFile using a file path URL.
 @param url The file path reference of the audio file as an NSURL.
 @return The newly created EZAudioFile instance. nil if the file path does not exist.
 */
- (instancetype)initWithURL:(NSURL *)url;

/**
 Creates a new instance of the EZAudioFile using a file path URL with a delegate conforming to the EZAudioFileDelegate protocol.
 @param delegate The audio file delegate that receives events specified by the EZAudioFileDelegate protocol
 @param url The file path reference of the audio file as an NSURL.
 @return The newly created EZAudioFile instance.
 */
- (instancetype)initWithURL:(NSURL *)url
                   delegate:(id<EZAudioFileDelegate>)delegate;

//------------------------------------------------------------------------------

/**
 Creates a new instance of the EZAudioFile using a file path URL with a delegate conforming to the EZAudioFileDelegate protocol and a client format.
 @param url      The file path reference of the audio file as an NSURL.
 @param delegate The audio file delegate that receives events specified by the EZAudioFileDelegate protocol
 @param clientFormat An AudioStreamBasicDescription that will be used as the client format on the audio file. For instance, the audio file might be in a 22.5 kHz sample rate format in its file format, but your app wants to read the samples at a sample rate of 44.1 kHz so it can iterate with other components (like a audio processing graph) without any weird playback effects. If this initializer is not used then a non-interleaved float format will be assumed.
 @return The newly created EZAudioFile instance.
 */
- (instancetype)initWithURL:(NSURL *)url
                   delegate:(id<EZAudioFileDelegate>)delegate
               clientFormat:(AudioStreamBasicDescription)clientFormat;

//------------------------------------------------------------------------------
#pragma mark - Class Initializers
//------------------------------------------------------------------------------
/**
 @name Class Initializers
 */

/**
 Class method that creates a new instance of the EZAudioFile using a file path URL.
 @param url The file path reference of the audio file as an NSURL.
 @return The newly created EZAudioFile instance.
 */
+ (instancetype)audioFileWithURL:(NSURL *)url;

//------------------------------------------------------------------------------

/**
 Class method that creates a new instance of the EZAudioFile using a file path URL with a delegate conforming to the EZAudioFileDelegate protocol.
 @param url The file path reference of the audio file as an NSURL.
 @param delegate The audio file delegate that receives events specified by the EZAudioFileDelegate protocol
 @return The newly created EZAudioFile instance.
 */
+ (instancetype)audioFileWithURL:(NSURL *)url
                        delegate:(id<EZAudioFileDelegate>)delegate;

//------------------------------------------------------------------------------

/**
 Class method that creates a new instance of the EZAudioFile using a file path URL with a delegate conforming to the EZAudioFileDelegate protocol and a client format.
 @param url The file path reference of the audio file as an NSURL.
 @param delegate The audio file delegate that receives events specified by the EZAudioFileDelegate protocol
 @param clientFormat An AudioStreamBasicDescription that will be used as the client format on the audio file. For instance, the audio file might be in a 22.5 kHz sample rate, interleaved MP3 file format, but your app wants to read linear PCM samples at a sample rate of 44.1 kHz so it can be read in the context of other components sharing a common stream format (like a audio processing graph). If this initializer is not used then the `defaultClientFormat` will be used as the default value for the client format.
 @return The newly created EZAudioFile instance.
 */
+ (instancetype)audioFileWithURL:(NSURL *)url
                        delegate:(id<EZAudioFileDelegate>)delegate
                    clientFormat:(AudioStreamBasicDescription)clientFormat;

//------------------------------------------------------------------------------
#pragma mark - Class Methods
//------------------------------------------------------------------------------
/**
 @name Class Methods
 */

/**
 A class method that subclasses can override to specify the default client format that will be used to read audio data from this file. A client format is different from the file format in that it is the format of the other components interacting with this file. For instance, the file on disk could be a 22.5 kHz, float format, but we might have an audio processing graph that has a 44.1 kHz, signed integer format that we'd like to interact with. The client format lets us set that 44.1 kHz format on the audio file to properly read samples from it with any interpolation or format conversion that must take place done automatically within the EZAudioFile `readFrames:audioBufferList:bufferSize:eof:` method. Default is stereo, non-interleaved, 44.1 kHz.
 @return An AudioStreamBasicDescription that serves as the audio file's client format.
 */
+ (AudioStreamBasicDescription)defaultClientFormat;

//------------------------------------------------------------------------------

/**
 A class method that subclasses can override to specify the default sample rate that will be used in the `defaultClientFormat` method. Default is 44100.0 (44.1 kHz).
 @return A Float64 representing the sample rate that should be used in the default client format.
 */
+ (Float64)defaultClientFormatSampleRate;

//------------------------------------------------------------------------------

/**
 Provides an array of the supported audio files types. Each audio file type is provided as a string, i.e. @"caf". Useful for filtering lists of files in an open panel to only the types allowed.
 @return An array of NSString objects representing the represented file types.
 */
+ (NSArray *)supportedAudioFileTypes;

//------------------------------------------------------------------------------
#pragma mark - Events
//------------------------------------------------------------------------------
/**
 @name Reading From The Audio File
 */

/**
 Reads a specified number of frames from the audio file. In addition, this will notify the EZAudioFileDelegate (if specified) of the read data as a float array with the audioFile:readAudio:withBufferSize:withNumberOfChannels: event and the new seek position within the file with the audioFile:updatedPosition: event.
 @param frames          The number of frames to read from the file.
 @param audioBufferList An allocated AudioBufferList structure in which to store the read audio data
 @param bufferSize      A pointer to a UInt32 in which to store the read buffersize
 @param eof             A pointer to a BOOL in which to store whether the read operation reached the end of the audio file.
 */
- (void)readFrames:(UInt32)frames
   audioBufferList:(AudioBufferList *)audioBufferList
        bufferSize:(UInt32 *)bufferSize
               eof:(BOOL *)eof;

//------------------------------------------------------------------------------

/**
 @name Seeking Through The Audio File
 */

/**
 Seeks through an audio file to a specified frame. This will notify the EZAudioFileDelegate (if specified) with the audioFile:updatedPosition: function.
 @param frame The new frame position to seek to as a SInt64.
 */
- (void)seekToFrame:(SInt64)frame;

//------------------------------------------------------------------------------
#pragma mark - Getters
//------------------------------------------------------------------------------
/**
 @name Getting Information About The Audio File
 */

/**
 Provides the common AudioStreamBasicDescription that will be used for in-app interaction. The file's format will be converted to this format and then sent back as either a float array or a `AudioBufferList` pointer. For instance, the file on disk could be a 22.5 kHz, float format, but we might have an audio processing graph that has a 44.1 kHz, signed integer format that we'd like to interact with. The client format lets us set that 44.1 kHz format on the audio file to properly read samples from it with any interpolation or format conversion that must take place done automatically within the EZAudioFile `readFrames:audioBufferList:bufferSize:eof:` method. Default is stereo, non-interleaved, 44.1 kHz.
 @warning This must be a linear PCM format!
 @return An AudioStreamBasicDescription structure describing the format of the audio file.
 */
@property (readwrite) AudioStreamBasicDescription clientFormat;

//------------------------------------------------------------------------------

/**
 Provides the current offset in the audio file as an NSTimeInterval (i.e. in seconds).  When setting this it will determine the correct frame offset and perform a `seekToFrame` to the new time offset.
 @warning Make sure the new current time offset is less than the `duration` or you will receive an invalid seek assertion.
 */
@property (nonatomic, readwrite) NSTimeInterval currentTime;

//------------------------------------------------------------------------------

/**
 Provides the duration of the audio file in seconds.
 */
@property (readonly) NSTimeInterval duration;

//------------------------------------------------------------------------------

/**
 Provides the AudioStreamBasicDescription structure containing the format of the file.
 @return An AudioStreamBasicDescription structure describing the format of the audio file.
 */
@property (readonly) AudioStreamBasicDescription fileFormat;

//------------------------------------------------------------------------------

/**
 Provides the current time as an NSString with the time format MM:SS.
 */
@property (readonly) NSString *formattedCurrentTime;

//------------------------------------------------------------------------------

/**
 Provides the duration as an NSString with the time format MM:SS.
 */
@property (readonly) NSString *formattedDuration;

//------------------------------------------------------------------------------

/**
 Provides the frame index (a.k.a the seek position) within the audio file as SInt64. This can be helpful when seeking through the audio file.
 @return The current frame index within the audio file as a SInt64.
 */
@property (readonly) SInt64 frameIndex;

//------------------------------------------------------------------------------

/**
 Provides a dictionary containing the metadata (ID3) tags that are included in the header for the audio file. Typically this contains stuff like artist, title, release year, etc.
 @return An NSDictionary containing the metadata for the audio file.
 */
@property (readonly) NSDictionary *metadata;

//------------------------------------------------------------------------------

/**
 A list of markers associated with the audio file. These are typically embedded within WAVE or AIFF files only.
 @return A NSArray containing the markers in the file. Will be NULL if no markers.
 */
@property (readwrite) NSArray *markers;

//------------------------------------------------------------------------------

/**
 Provides the total duration of the audio file in seconds.
 @deprecated This property is deprecated starting in version 0.3.0.
 @note Please use `duration` property instead.
 @return The total duration of the audio file as a Float32.
 */
@property (readonly) NSTimeInterval totalDuration __attribute__((deprecated));

//------------------------------------------------------------------------------

/**
 Provides the total frame count of the audio file in the client format.
 @return The total number of frames in the audio file in the AudioStreamBasicDescription representing the client format as a SInt64.
 */
@property (readonly) SInt64 totalClientFrames;

//------------------------------------------------------------------------------

/**
 Provides the total frame count of the audio file in the file format.
 @return The total number of frames in the audio file in the AudioStreamBasicDescription representing the file format as a SInt64.
 */
@property (readonly) SInt64 totalFrames;

//------------------------------------------------------------------------------

/**
 Provides the NSURL for the audio file.
 @return An NSURL representing the path of the EZAudioFile instance.
 */
@property (nonatomic, copy, readonly) NSURL *url;

/**
 The AudioFileID for this file
 @return An AudioFileID that subclasses can use to derive more information about this audio file.
 */
@property (readonly) AudioFileID audioFileID;

//------------------------------------------------------------------------------
#pragma mark - Helpers
//------------------------------------------------------------------------------

/**
 Synchronously pulls the waveform amplitude data into a float array for the receiver. This returns a waveform with a default resolution of 1024, meaning there are 1024 data points to plot the waveform.
 @return A EZAudioFloatData instance containing the audio data for all channels of the audio.
 */
- (EZAudioFloatData *)getWaveformData;

//------------------------------------------------------------------------------

/**
 Synchronously pulls the waveform amplitude data into a float array for the receiver.
  @param numberOfPoints A UInt32 representing the number of data points you need. The higher the number of points the more detailed the waveform will be.
 @return A EZAudioFloatData instance containing the audio data for all channels of the audio.
 */
- (EZAudioFloatData *)getWaveformDataWithNumberOfPoints:(UInt32)numberOfPoints;

//------------------------------------------------------------------------------

/**
 Asynchronously pulls the waveform amplitude data into a float array for the receiver. This returns a waveform with a default resolution of 1024, meaning there are 1024 data points to plot the waveform.
 @param completion A EZAudioWaveformDataCompletionBlock that executes when the waveform data has been extracted. Provides a `EZAudioFloatData` instance containing the waveform data for all audio channels.
 */
- (void)getWaveformDataWithCompletionBlock:(EZAudioWaveformDataCompletionBlock)completion;

//------------------------------------------------------------------------------

/**
 Asynchronously pulls the waveform amplitude data into a float array for the receiver.
 @param numberOfPoints A UInt32 representing the number of data points you need. The higher the number of points the more detailed the waveform will be.
 @param completion A EZAudioWaveformDataCompletionBlock that executes when the waveform data has been extracted. Provides a `EZAudioFloatData` instance containing the waveform data for all audio channels.
 */
- (void)getWaveformDataWithNumberOfPoints:(UInt32)numberOfPoints
                               completion:(EZAudioWaveformDataCompletionBlock)completion;

//------------------------------------------------------------------------------

@end
