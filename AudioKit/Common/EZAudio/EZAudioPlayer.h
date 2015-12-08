//
//  EZAudioPlayer.h
//  EZAudio
//
//  Created by Syed Haris Ali on 1/16/14.
//  Copyright (c) 2014 Syed Haris Ali. All rights reserved.
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
#import "TargetConditionals.h"
#import "EZAudioFile.h"
#import "EZOutput.h"

@class EZAudioPlayer;

//------------------------------------------------------------------------------
#pragma mark - Notifications
//------------------------------------------------------------------------------

/**
 Notification that occurs whenever the EZAudioPlayer changes its `audioFile` property. Check the new value using the EZAudioPlayer's `audioFile` property.
 */
FOUNDATION_EXPORT NSString * const EZAudioPlayerDidChangeAudioFileNotification;

/**
 Notification that occurs whenever the EZAudioPlayer changes its `device` property. Check the new value using the EZAudioPlayer's `device` property.
 */
FOUNDATION_EXPORT NSString * const EZAudioPlayerDidChangeOutputDeviceNotification;

/**
 Notification that occurs whenever the EZAudioPlayer changes its `output` component's `pan` property. Check the new value using the EZAudioPlayer's `pan` property.
 */
FOUNDATION_EXPORT NSString * const EZAudioPlayerDidChangePanNotification;

/**
 Notification that occurs whenever the EZAudioPlayer changes its `output` component's play state. Check the new value using the EZAudioPlayer's `isPlaying` property.
 */
FOUNDATION_EXPORT NSString * const EZAudioPlayerDidChangePlayStateNotification;

/**
 Notification that occurs whenever the EZAudioPlayer changes its `output` component's `volume` property. Check the new value using the EZAudioPlayer's `volume` property.
 */
FOUNDATION_EXPORT NSString * const EZAudioPlayerDidChangeVolumeNotification;

/**
 Notification that occurs whenever the EZAudioPlayer has reached the end of a file and its `shouldLoop` property has been set to NO.
 */
FOUNDATION_EXPORT NSString * const EZAudioPlayerDidReachEndOfFileNotification;

/**
 Notification that occurs whenever the EZAudioPlayer performs a seek via the `seekToFrame` method or `setCurrentTime:` property setter. Check the new `currentTime` or `frameIndex` value using the EZAudioPlayer's `currentTime` or `frameIndex` property, respectively.
 */
FOUNDATION_EXPORT NSString * const EZAudioPlayerDidSeekNotification;

//------------------------------------------------------------------------------
#pragma mark - EZAudioPlayerDelegate
//------------------------------------------------------------------------------

/**
 The EZAudioPlayerDelegate provides event callbacks for the EZAudioPlayer. Since 0.5.0 the EZAudioPlayerDelegate provides a smaller set of delegate methods in favor of notifications to allow multiple receivers of the EZAudioPlayer event callbacks since only one player is typically used in an application. Specifically, these methods are provided for high frequency callbacks that wrap the EZAudioPlayer's internal EZAudioFile and EZOutput instances.
 @warning These callbacks don't necessarily occur on the main thread so make sure you wrap any UI code in a GCD block like: dispatch_async(dispatch_get_main_queue(), ^{ // Update UI });
 */
@protocol EZAudioPlayerDelegate <NSObject>

@optional

//------------------------------------------------------------------------------

/**
 Triggered by the EZAudioPlayer's internal EZAudioFile's EZAudioFileDelegate callback and notifies the delegate of the read audio data as a float array instead of a buffer list. Common use case of this would be to visualize the float data using an audio plot or audio data dependent OpenGL sketch.
 @param audioPlayer The instance of the EZAudioPlayer that triggered the event
 @param buffer           A float array of float arrays holding the audio data. buffer[0] would be the left channel's float array while buffer[1] would be the right channel's float array in a stereo file.
 @param bufferSize       The length of the buffers float arrays
 @param numberOfChannels The number of channels. 2 for stereo, 1 for mono.
 @param audioFile   The instance of the EZAudioFile that the event was triggered from
 */
- (void)  audioPlayer:(EZAudioPlayer *)audioPlayer
          playedAudio:(float **)buffer
       withBufferSize:(UInt32)bufferSize
 withNumberOfChannels:(UInt32)numberOfChannels
          inAudioFile:(EZAudioFile *)audioFile;;

//------------------------------------------------------------------------------

/**
 Triggered by EZAudioPlayer's internal EZAudioFile's EZAudioFileDelegate callback and notifies the delegate of the current playback position. The framePosition provides the current frame position and can be calculated against the EZAudioPlayer's total frames using the `totalFrames` function from the EZAudioPlayer.
 @param audioPlayer The instance of the EZAudioPlayer that triggered the event
 @param framePosition The new frame index as a 64-bit signed integer
 @param audioFile   The instance of the EZAudioFile that the event was triggered from
 */
- (void)audioPlayer:(EZAudioPlayer *)audioPlayer
    updatedPosition:(SInt64)framePosition
        inAudioFile:(EZAudioFile *)audioFile;


/**
 Triggered by EZAudioPlayer's internal EZAudioFile's EZAudioFileDelegate callback and notifies the delegate that the end of the file has been reached. 
 @param audioPlayer The instance of the EZAudioPlayer that triggered the event
 @param audioFile   The instance of the EZAudioFile that the event was triggered from
 */
- (void)audioPlayer:(EZAudioPlayer *)audioPlayer
reachedEndOfAudioFile:(EZAudioFile *)audioFile;

@end

//------------------------------------------------------------------------------
#pragma mark - EZAudioPlayer
//------------------------------------------------------------------------------

/**
 The EZAudioPlayer provides an interface that combines the EZAudioFile and EZOutput to play local audio files. This class acts as the master delegate (the EZAudioFileDelegate) over whatever EZAudioFile instance, the `audioFile` property, it is using for playback as well as the EZOutputDelegate and EZOutputDataSource over whatever EZOutput instance is set as the `output`. Classes that want to get the EZAudioFileDelegate callbacks should implement the EZAudioPlayer's EZAudioPlayerDelegate on the EZAudioPlayer instance. Since 0.5.0 the EZAudioPlayer offers notifications over the usual delegate methods to allow multiple receivers to get the EZAudioPlayer's state changes since one player will typically be used in one application. The EZAudioPlayerDelegate, the `delegate`, provides callbacks for high frequency methods that simply wrap the EZAudioFileDelegate and EZOutputDelegate callbacks for providing the audio buffer played as well as the position updating (you will typically have one scrub bar in an application).
 */
@interface EZAudioPlayer : NSObject <EZAudioFileDelegate,
                                     EZOutputDataSource,
                                     EZOutputDelegate>

//------------------------------------------------------------------------------
#pragma mark - Properties
//------------------------------------------------------------------------------

///-----------------------------------------------------------
/// @name Properties
///-----------------------------------------------------------

/**
 The EZAudioPlayerDelegate that will handle the audio player callbacks
 */
@property (nonatomic, weak) id<EZAudioPlayerDelegate> delegate;

//------------------------------------------------------------------------------

/**
 A BOOL indicating whether the player should loop the file
 */
@property (nonatomic, assign) BOOL shouldLoop;

//------------------------------------------------------------------------------
#pragma mark - Initializers
//------------------------------------------------------------------------------

///-----------------------------------------------------------
/// @name Initializers
///-----------------------------------------------------------

/**
 Initializes the EZAudioPlayer with an EZAudioFile instance. This does not use the EZAudioFile by reference, but instead creates a separate EZAudioFile instance with the same file at the given file path provided by the internal NSURL to use for internal seeking so it doesn't cause any locking between the caller's instance of the EZAudioFile.
 @param audioFile The instance of the EZAudioFile to use for initializing the EZAudioPlayer
 @return The newly created instance of the EZAudioPlayer
 */
- (instancetype)initWithAudioFile:(EZAudioFile *)audioFile;

//------------------------------------------------------------------------------

/**
 Initializes the EZAudioPlayer with an EZAudioFile instance and provides a way to assign the EZAudioPlayerDelegate on instantiation. This does not use the EZAudioFile by reference, but instead creates a separate EZAudioFile instance with the same file at the given file path provided by the internal NSURL to use for internal seeking so it doesn't cause any locking between the caller's instance of the EZAudioFile.
 @param audioFile The instance of the EZAudioFile to use for initializing the EZAudioPlayer
 @param delegate The receiver that will act as the EZAudioPlayerDelegate. Set to nil if it should have no delegate or use the initWithAudioFile: function instead.
 @return The newly created instance of the EZAudioPlayer
 */
- (instancetype)initWithAudioFile:(EZAudioFile *)audioFile
                         delegate:(id<EZAudioPlayerDelegate>)delegate;

//------------------------------------------------------------------------------

/**
 Initializes the EZAudioPlayer with an EZAudioPlayerDelegate.
 @param delegate The receiver that will act as the EZAudioPlayerDelegate. Set to nil if it should have no delegate or use the initWithAudioFile: function instead.
 @return The newly created instance of the EZAudioPlayer
 */
- (instancetype)initWithDelegate:(id<EZAudioPlayerDelegate>)delegate;

//------------------------------------------------------------------------------

/**
 Initializes the EZAudioPlayer with an NSURL instance representing the file path of the audio file.
 @param url The NSURL instance representing the file path of the audio file.
 @return The newly created instance of the EZAudioPlayer
 */
- (instancetype)initWithURL:(NSURL*)url;

//------------------------------------------------------------------------------

/**
 Initializes the EZAudioPlayer with an NSURL instance representing the file path of the audio file and a caller to assign as the EZAudioPlayerDelegate on instantiation.
 @param url The NSURL instance representing the file path of the audio file.
 @param delegate The receiver that will act as the EZAudioPlayerDelegate. Set to nil if it should have no delegate or use the initWithAudioFile: function instead.
 @return The newly created instance of the EZAudioPlayer
 */
- (instancetype)initWithURL:(NSURL*)url
                   delegate:(id<EZAudioPlayerDelegate>)delegate;

//------------------------------------------------------------------------------
#pragma mark - Class Initializers
//------------------------------------------------------------------------------

///-----------------------------------------------------------
/// @name Class Initializers
///-----------------------------------------------------------

/**
 Class initializer that creates a default EZAudioPlayer.
 @return The newly created instance of the EZAudioPlayer
 */
+ (instancetype)audioPlayer;

//------------------------------------------------------------------------------

/**
 Class initializer that creates the EZAudioPlayer with an EZAudioFile instance. This does not use the EZAudioFile by reference, but instead creates a separate EZAudioFile instance with the same file at the given file path provided by the internal NSURL to use for internal seeking so it doesn't cause any locking between the caller's instance of the EZAudioFile.
 @param audioFile The instance of the EZAudioFile to use for initializing the EZAudioPlayer
 @return The newly created instance of the EZAudioPlayer
 */
+ (instancetype)audioPlayerWithAudioFile:(EZAudioFile *)audioFile;

//------------------------------------------------------------------------------

/**
 Class initializer that creates the EZAudioPlayer with an EZAudioFile instance and provides a way to assign the EZAudioPlayerDelegate on instantiation. This does not use the EZAudioFile by reference, but instead creates a separate EZAudioFile instance with the same file at the given file path provided by the internal NSURL to use for internal seeking so it doesn't cause any locking between the caller's instance of the EZAudioFile.
 @param audioFile The instance of the EZAudioFile to use for initializing the EZAudioPlayer
 @param delegate The receiver that will act as the EZAudioPlayerDelegate. Set to nil if it should have no delegate or use the audioPlayerWithAudioFile: function instead.
 @return The newly created instance of the EZAudioPlayer
 */
+ (instancetype)audioPlayerWithAudioFile:(EZAudioFile *)audioFile
                                delegate:(id<EZAudioPlayerDelegate>)delegate;

//------------------------------------------------------------------------------

/**
 Class initializer that creates a default EZAudioPlayer with an EZAudioPlayerDelegate..
 @return The newly created instance of the EZAudioPlayer
 */
+ (instancetype)audioPlayerWithDelegate:(id<EZAudioPlayerDelegate>)delegate;

//------------------------------------------------------------------------------

/**
 Class initializer that creates the EZAudioPlayer with an NSURL instance representing the file path of the audio file.
 @param url The NSURL instance representing the file path of the audio file.
 @return The newly created instance of the EZAudioPlayer
 */
+ (instancetype)audioPlayerWithURL:(NSURL*)url;

//------------------------------------------------------------------------------

/**
 Class initializer that creates the EZAudioPlayer with an NSURL instance representing the file path of the audio file and a caller to assign as the EZAudioPlayerDelegate on instantiation.
 @param url The NSURL instance representing the file path of the audio file.
 @param delegate The receiver that will act as the EZAudioPlayerDelegate. Set to nil if it should have no delegate or use the audioPlayerWithURL: function instead.
 @return The newly created instance of the EZAudioPlayer
 */
+ (instancetype)audioPlayerWithURL:(NSURL*)url
                          delegate:(id<EZAudioPlayerDelegate>)delegate;

//------------------------------------------------------------------------------
#pragma mark - Singleton
//------------------------------------------------------------------------------

///-----------------------------------------------------------
/// @name Shared Instance
///-----------------------------------------------------------

/**
 The shared instance (singleton) of the audio player. Most applications will only have one instance of the EZAudioPlayer that can be reused with multiple different audio files.
 *  @return The shared instance of the EZAudioPlayer.
 */
+ (instancetype)sharedAudioPlayer;

//------------------------------------------------------------------------------
#pragma mark - Properties
//------------------------------------------------------------------------------

///-----------------------------------------------------------
/// @name Properties
///-----------------------------------------------------------

/**
 Provides the EZAudioFile instance that is being used as the datasource for playback. When set it creates a copy of the EZAudioFile provided for internal use. This does not use the EZAudioFile by reference, but instead creates a copy of the EZAudioFile instance provided.
 */
@property (nonatomic, readwrite, copy) EZAudioFile *audioFile;

//------------------------------------------------------------------------------

/**
 Provides the current offset in the audio file as an NSTimeInterval (i.e. in seconds).  When setting this it will determine the correct frame offset and perform a `seekToFrame` to the new time offset.
 @warning Make sure the new current time offset is less than the `duration` or you will receive an invalid seek assertion.
 */
@property (nonatomic, readwrite) NSTimeInterval currentTime;

//------------------------------------------------------------------------------

/**
 The EZAudioDevice instance that is being used by the `output`. Similarly, setting this just sets the `device` property of the `output`.
 */
@property (readwrite) EZAudioDevice *device;

//------------------------------------------------------------------------------

/**
 Provides the duration of the audio file in seconds.
 */
@property (readonly) NSTimeInterval duration;

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
 Provides the EZOutput that is being used to handle the actual playback of the audio data. This property is also settable, but note that the EZAudioPlayer will become the output's EZOutputDataSource and EZOutputDelegate. To listen for the EZOutput's delegate methods your view should implement the EZAudioPlayerDelegate and set itself as the EZAudioPlayer's `delegate`.
 */
@property (nonatomic, strong, readwrite) EZOutput *output;

//------------------------------------------------------------------------------

/**
 Provides the frame index (a.k.a the seek positon) within the audio file being used for playback. This can be helpful when seeking through the audio file.
 @return An SInt64 representing the current frame index within the audio file used for playback.
 */
@property (readonly) SInt64 frameIndex;

//------------------------------------------------------------------------------

/**
 Provides a flag indicating whether the EZAudioPlayer is currently playing back any audio.
 @return A BOOL indicating whether or not the EZAudioPlayer is performing playback,
 */
@property (readonly) BOOL isPlaying;

//------------------------------------------------------------------------------

/**
 Provides the current pan from the audio player's internal `output` component. Setting the pan adjusts the direction of the audio signal from left (0) to right (1). Default is 0.5 (middle).
 */
@property (nonatomic, assign) float pan;

//------------------------------------------------------------------------------

/**
 Provides the total amount of frames in the current audio file being used for playback.
 @return A SInt64 representing the total amount of frames in the current audio file being used for playback.
 */
@property (readonly) SInt64 totalFrames;

//------------------------------------------------------------------------------

/**
 Provides the file path that's currently being used by the player for playback.
 @return  The NSURL representing the file path of the audio file being used for playback.
 */
@property (nonatomic, copy, readonly) NSURL *url;

//------------------------------------------------------------------------------

/**
  Provides the current volume from the audio player's internal `output` component. Setting the volume adjusts the gain of the output between 0 and 1. Default is 1.
 */
@property (nonatomic, assign) float volume;

//------------------------------------------------------------------------------
#pragma mark - Actions
//------------------------------------------------------------------------------

///-----------------------------------------------------------
/// @name Controlling Playback
///-----------------------------------------------------------

/**
 Starts playback.
 */
- (void)play;

//------------------------------------------------------------------------------

/**
 Loads an EZAudioFile and immediately starts playing it.
 @param audioFile An EZAudioFile to use for immediate playback.
 */
- (void)playAudioFile:(EZAudioFile *)audioFile;

//------------------------------------------------------------------------------

/**
 Pauses playback.
 */
- (void)pause;

//------------------------------------------------------------------------------

/**
 Seeks playback to a specified frame within the internal EZAudioFile. This will notify the EZAudioFileDelegate (if specified) with the audioPlayer:updatedPosition:inAudioFile: function.
 @param frame The new frame position to seek to as a SInt64.
 */
- (void)seekToFrame:(SInt64)frame;

@end
