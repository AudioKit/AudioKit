//
//  EZOutput.h
//  EZAudio
//
//  Created by Syed Haris Ali on 12/2/13.
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
#if TARGET_OS_IPHONE
#elif TARGET_OS_MAC
#import <AudioUnit/AudioUnit.h>
#endif

@class EZAudioDevice;
@class EZOutput;

//------------------------------------------------------------------------------
#pragma mark - Constants
//------------------------------------------------------------------------------

FOUNDATION_EXPORT UInt32  const EZOutputMaximumFramesPerSlice;
FOUNDATION_EXPORT Float64 const EZOutputDefaultSampleRate;

//------------------------------------------------------------------------------
#pragma mark - EZOutputDataSource
//------------------------------------------------------------------------------

/**
 The EZOutputDataSource specifies a receiver to provide audio data when the EZOutput is started. Since the 0.4.0 release this has been simplified to only one data source method.
 */
@protocol EZOutputDataSource <NSObject>

@optional
///-----------------------------------------------------------
/// @name Providing Audio Data
///-----------------------------------------------------------

@required

/**
 Provides a way to provide output with data anytime the EZOutput needs audio data to play. This function provides an already allocated AudioBufferList to use for providing audio data into the output buffer. The expected format of the audio data provided here is specified by the EZOutput `inputFormat` property. This audio data will be converted into the client format specified by the EZOutput `clientFormat` property.
 @param output The instance of the EZOutput that asked for the data.
 @param audioBufferList The AudioBufferList structure pointer that needs to be filled with audio data
 @param frames The amount of frames as a UInt32 that output will need to properly fill its output buffer.
 @param timestamp A AudioTimeStamp pointer to use if you need the current host time.
 @return An OSStatus code. If there was no error then use the noErr status code.
 */
- (OSStatus)        output:(EZOutput *)output
 shouldFillAudioBufferList:(AudioBufferList *)audioBufferList
        withNumberOfFrames:(UInt32)frames
                 timestamp:(const AudioTimeStamp *)timestamp;

@end

//------------------------------------------------------------------------------
#pragma mark - EZOutputDelegate
//------------------------------------------------------------------------------

/**
 The EZOutputDelegate for the EZOutput component provides a receiver to handle play state, device, and audio data change events. This is very similar to the EZMicrophoneDelegate for the EZMicrophone and the EZAudioFileDelegate for the EZAudioFile.
 */
@protocol EZOutputDelegate <NSObject>

@optional

/**
 Called anytime the EZOutput starts or stops.
 @param output The instance of the EZOutput that triggered the event.
 @param isPlaying A BOOL indicating whether the EZOutput instance is playing or not.
 */
- (void)output:(EZOutput *)output changedPlayingState:(BOOL)isPlaying;

//------------------------------------------------------------------------------

/**
 Called anytime the `device` changes on an EZOutput instance.
 @param output The instance of the EZOutput that triggered the event.
 @param device The instance of the new EZAudioDevice the output is using to play audio data.
 */
- (void)output:(EZOutput *)output changedDevice:(EZAudioDevice *)device;

//------------------------------------------------------------------------------

/**
 Like the EZMicrophoneDelegate, for the EZOutput this method provides an array of float arrays of the audio received, each float array representing a channel of audio data. This occurs on the background thread so any drawing code must explicity perform its functions on the main thread.
 @param output The instance of the EZOutput that triggered the event.
 @param buffer           The audio data as an array of float arrays. In a stereo signal buffer[0] represents the left channel while buffer[1] would represent the right channel.
 @param bufferSize       A UInt32 representing the size of each of the buffers (the length of each float array).
 @param numberOfChannels A UInt32 representing the number of channels (you can use this to know how many float arrays are in the `buffer` parameter.
 @warning This function executes on a background thread to avoid blocking any audio operations. If operations should be performed on any other thread (like the main thread) it should be performed within a dispatch block like so: dispatch_async(dispatch_get_main_queue(), ^{ ...Your Code... })
 */
- (void)       output:(EZOutput *)output
          playedAudio:(float **)buffer
       withBufferSize:(UInt32)bufferSize
 withNumberOfChannels:(UInt32)numberOfChannels;

//------------------------------------------------------------------------------

@end

/**
 The EZOutput component provides a generic output to glue all the other EZAudio components together and push whatever sound you've created to the default output device (think opposite of the microphone). The EZOutputDataSource provides the required AudioBufferList needed to populate the output buffer while the EZOutputDelegate provides the same kind of mechanism as the EZMicrophoneDelegate or EZAudioFileDelegate in that you will receive a callback that provides non-interleaved, float data for visualizing the output (done using an internal float converter). As of 0.4.0 the EZOutput has been simplified to a single EZOutputDataSource method and now uses an AUGraph to provide format conversion from the `inputFormat` to the playback graph's `clientFormat` linear PCM formats, mixer controls for setting volume and pan settings, hooks to add in any number of effect audio units (see the `connectOutputOfSourceNode:sourceNodeOutputBus:toDestinationNode:destinationNodeInputBus:inGraph:` subclass method), and hardware device toggling (via EZAudioDevice).
 */
@interface EZOutput : NSObject

//------------------------------------------------------------------------------
#pragma mark - Initializers
//------------------------------------------------------------------------------

///-----------------------------------------------------------
/// @name Initializers
///-----------------------------------------------------------

/**
 Creates a new instance of the EZOutput and allows the caller to specify an EZOutputDataSource.
 @param dataSource The EZOutputDataSource that will be used to pull the audio data for the output callback.
 @return A newly created instance of the EZOutput class.
 */
- (instancetype)initWithDataSource:(id<EZOutputDataSource>)dataSource;

/**
 Creates a new instance of the EZOutput and allows the caller to specify an EZOutputDataSource.
 @param dataSource The EZOutputDataSource that will be used to pull the audio data for the output callback.
 @param inputFormat The AudioStreamBasicDescription of the EZOutput.
 @warning AudioStreamBasicDescription input formats must be linear PCM!
 @return A newly created instance of the EZOutput class.
 */
- (instancetype)initWithDataSource:(id<EZOutputDataSource>)dataSource
                       inputFormat:(AudioStreamBasicDescription)inputFormat;

//------------------------------------------------------------------------------
#pragma mark - Class Initializers
//------------------------------------------------------------------------------

///-----------------------------------------------------------
/// @name Class Initializers
///-----------------------------------------------------------

/**
 Class method to create a new instance of the EZOutput
 @return A newly created instance of the EZOutput class.
 */
+ (instancetype)output;

/**
 Class method to create a new instance of the EZOutput and allows the caller to specify an EZOutputDataSource.
 @param dataSource The EZOutputDataSource that will be used to pull the audio data for the output callback.
 @return A newly created instance of the EZOutput class.
 */
+ (instancetype)outputWithDataSource:(id<EZOutputDataSource>)dataSource;

/**
 Class method to create a new instance of the EZOutput and allows the caller to specify an EZOutputDataSource.
 @param dataSource The EZOutputDataSource that will be used to pull the audio data for the output callback.
 @param audioStreamBasicDescription The AudioStreamBasicDescription of the EZOutput.
 @warning AudioStreamBasicDescriptions that are invalid will cause the EZOutput to fail to initialize
 @return A newly created instance of the EZOutput class.
 */
+ (instancetype)outputWithDataSource:(id<EZOutputDataSource>)dataSource
                         inputFormat:(AudioStreamBasicDescription)inputFormat;

//------------------------------------------------------------------------------
#pragma mark - Singleton
//------------------------------------------------------------------------------

///-----------------------------------------------------------
/// @name Shared Instance
///-----------------------------------------------------------

/**
 Creates a shared instance of the EZOutput (one app will usually only need one output and share the role of the EZOutputDataSource).
 @return The shared instance of the EZOutput class.
 */
+ (instancetype)sharedOutput;

//------------------------------------------------------------------------------
#pragma mark - Properties
//------------------------------------------------------------------------------

///-----------------------------------------------------------
/// @name Setting/Getting The Stream Formats
///-----------------------------------------------------------

/**
 Provides the AudioStreamBasicDescription structure used at the beginning of the playback graph which is then converted into the `clientFormat` using the AUConverter audio unit.
  @warning The AudioStreamBasicDescription set here must be linear PCM. Compressed formats are not supported...the EZAudioFile's clientFormat performs the audio conversion on the fly from compressed to linear PCM so there is no additional work to be done there.
 @return An AudioStreamBasicDescription structure describing
 */
@property (nonatomic, readwrite) AudioStreamBasicDescription inputFormat;

//------------------------------------------------------------------------------

/**
 Provides the AudioStreamBasicDescription structure that serves as the common format used throughout the playback graph (similar to how the EZAudioFile as a clientFormat that is linear PCM to be shared amongst other components). The `inputFormat` is converted into this format at the beginning of the playback graph using an AUConverter audio unit. Defaults to the whatever the `defaultClientFormat` method returns is if a custom one isn't explicitly set.
 @warning The AudioStreamBasicDescription set here must be linear PCM. Compressed formats are not supported by Audio Units.
 @return An AudioStreamBasicDescription structure describing the common client format for the playback graph.
 */
@property (nonatomic, readwrite) AudioStreamBasicDescription clientFormat;

//------------------------------------------------------------------------------

///-----------------------------------------------------------
/// @name Setting/Getting The Data Source and Delegate
///-----------------------------------------------------------

/**
 The EZOutputDataSource that provides the audio data in the `inputFormat` for the EZOutput to play. If an EZOutputDataSource is not specified then the EZOutput will just output silence.
 */
@property (nonatomic, weak) id<EZOutputDataSource> dataSource;

//------------------------------------------------------------------------------

/**
 The EZOutputDelegate for which to handle the output callbacks
 */
@property (nonatomic, weak) id<EZOutputDelegate> delegate;

//------------------------------------------------------------------------------

/**
 Provides a flag indicating whether the EZOutput is pulling audio data from the EZOutputDataSource for playback.
 @return YES if the EZOutput is running, NO if it is stopped
 */
@property (readonly) BOOL isPlaying;

//------------------------------------------------------------------------------

/**
 Provides the current pan from the audio player's mixer audio unit in the playback graph. Setting the pan adjusts the direction of the audio signal from left (0) to right (1). Default is 0.5 (middle).
 */
@property (nonatomic, assign) float pan;

//------------------------------------------------------------------------------

/**
 Provides the current volume from the audio player's mixer audio unit in the playback graph. Setting the volume adjusts the gain of the output between 0 and 1. Default is 1.
 */
@property (nonatomic, assign) float volume;

//------------------------------------------------------------------------------
#pragma mark - Core Audio Properties
//------------------------------------------------------------------------------

///-----------------------------------------------------------
/// @name Core Audio Properties
///-----------------------------------------------------------

/**
 The AUGraph used to chain together the converter, mixer, and output audio units.
 */
@property (readonly) AUGraph graph;

//------------------------------------------------------------------------------

/**
 The AudioUnit that is being used to convert the audio data coming into the output's playback graph.
 */
@property (readonly) AudioUnit converterAudioUnit;

//------------------------------------------------------------------------------

/**
 The AudioUnit that is being used as the mixer to adjust the volume on the output's playback graph.
 */
@property (readonly) AudioUnit mixerAudioUnit;

//------------------------------------------------------------------------------

/**
 The AudioUnit that is being used as the hardware output for the output's playback graph.
 */
@property (readonly) AudioUnit outputAudioUnit;

//------------------------------------------------------------------------------
#pragma mark - Setters
//------------------------------------------------------------------------------

///-----------------------------------------------------------
/// @name Getting/Setting The Output's Hardware Device
///-----------------------------------------------------------

/**
 An EZAudioDevice instance that is used to route the audio data out to the speaker. To find a list of available output devices see the EZAudioDevice `outputDevices` method.
 */
@property (nonatomic, strong, readwrite) EZAudioDevice *device;

//------------------------------------------------------------------------------
#pragma mark - Actions
//------------------------------------------------------------------------------

///-----------------------------------------------------------
/// @name Starting/Stopping The Output
///-----------------------------------------------------------

/**
 Starts pulling audio data from the EZOutputDataSource to the default device output.
 */
- (void)startPlayback;

///-----------------------------------------------------------

/**
 Stops pulling audio data from the EZOutputDataSource to the default device output.
 */
- (void)stopPlayback;

//------------------------------------------------------------------------------
#pragma mark - Subclass
//------------------------------------------------------------------------------

///-----------------------------------------------------------
/// @name Subclass
///-----------------------------------------------------------

/**
 This method handles connecting the converter node to the mixer node within the AUGraph that is being used as the playback graph. Subclasses can override this method and insert their custom nodes to perform effects processing on the audio data being rendered. 
 
 This was inspired by Daniel Kennett's blog post on how to add a custom equalizer to a CocoaLibSpotify SPCoreAudioController's AUGraph. For more information see Daniel's post and example code here: http://ikennd.ac/blog/2012/04/augraph-basics-in-cocoalibspotify/.
 @param sourceNode              An AUNode representing the node the audio data is coming from.
 @param sourceNodeOutputBus     A UInt32 representing the output bus from the source node that should be connected into the next node's input bus.
 @param destinationNode         An AUNode representing the node the audio data should be connected to.
 @param destinationNodeInputBus A UInt32 representing the input bus the source node's output bus should be connecting to.
 @param graph                   The AUGraph that is being used to hold the playback graph. Same as from the `graph` property.
 @return An OSStatus code. For no error return back `noErr`.
 */
- (OSStatus)connectOutputOfSourceNode:(AUNode)sourceNode
                  sourceNodeOutputBus:(UInt32)sourceNodeOutputBus
                    toDestinationNode:(AUNode)destinationNode
              destinationNodeInputBus:(UInt32)destinationNodeInputBus
                              inGraph:(AUGraph)graph;

//------------------------------------------------------------------------------

/**
 The default AudioStreamBasicDescription set as the client format of the output if no custom `clientFormat` is set. Defaults to a 44.1 kHz stereo, non-interleaved, float format.
 @return An AudioStreamBasicDescription that will be used as the default stream format.
 */
- (AudioStreamBasicDescription)defaultClientFormat;

//------------------------------------------------------------------------------

/**
 The default AudioStreamBasicDescription set as the `inputFormat` of the output if no custom `inputFormat` is set. Defaults to a 44.1 kHz stereo, non-interleaved, float format.
 @return An AudioStreamBasicDescription that will be used as the default stream format.
 */
- (AudioStreamBasicDescription)defaultInputFormat;

//------------------------------------------------------------------------------

/**
 The default value used as the AudioUnit subtype when creating the hardware output component. By default this is kAudioUnitSubType_RemoteIO for iOS and kAudioUnitSubType_HALOutput for OSX. 
 @warning If you change this to anything other than kAudioUnitSubType_HALOutput for OSX you will get a failed assertion because devices can only be set when using the HAL audio unit.
 @return An OSType that represents the AudioUnit subtype for the hardware output component.
 */
- (OSType)outputAudioUnitSubType;

@end