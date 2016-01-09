//
//  EZAudioPlayer.m
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

#import "EZAudioPlayer.h"
#import "EZAudioUtilities.h"

//------------------------------------------------------------------------------
#pragma mark - Notifications
//------------------------------------------------------------------------------

NSString * const EZAudioPlayerDidChangeAudioFileNotification = @"EZAudioPlayerDidChangeAudioFileNotification";
NSString * const EZAudioPlayerDidChangeOutputDeviceNotification = @"EZAudioPlayerDidChangeOutputDeviceNotification";
NSString * const EZAudioPlayerDidChangePanNotification = @"EZAudioPlayerDidChangePanNotification";
NSString * const EZAudioPlayerDidChangePlayStateNotification = @"EZAudioPlayerDidChangePlayStateNotification";
NSString * const EZAudioPlayerDidChangeVolumeNotification = @"EZAudioPlayerDidChangeVolumeNotification";
NSString * const EZAudioPlayerDidReachEndOfFileNotification = @"EZAudioPlayerDidReachEndOfFileNotification";
NSString * const EZAudioPlayerDidSeekNotification = @"EZAudioPlayerDidSeekNotification";

//------------------------------------------------------------------------------
#pragma mark - EZAudioPlayer (Implementation)
//------------------------------------------------------------------------------

@implementation EZAudioPlayer

//------------------------------------------------------------------------------
#pragma mark - Class Methods
//------------------------------------------------------------------------------

+ (instancetype)audioPlayer
{
    return [[self alloc] init];
}

//------------------------------------------------------------------------------

+ (instancetype)audioPlayerWithDelegate:(id<EZAudioPlayerDelegate>)delegate
{
    return [[self alloc] initWithDelegate:delegate];
}

//------------------------------------------------------------------------------

+ (instancetype)audioPlayerWithAudioFile:(EZAudioFile *)audioFile
{
    return [[self alloc] initWithAudioFile:audioFile];
}

//------------------------------------------------------------------------------

+ (instancetype)audioPlayerWithAudioFile:(EZAudioFile *)audioFile
                                   delegate:(id<EZAudioPlayerDelegate>)delegate
{
    return [[self alloc] initWithAudioFile:audioFile
                                  delegate:delegate];
}

//------------------------------------------------------------------------------

+ (instancetype)audioPlayerWithURL:(NSURL *)url
{
    return [[self alloc] initWithURL:url];
}

//------------------------------------------------------------------------------

+ (instancetype)audioPlayerWithURL:(NSURL *)url
                             delegate:(id<EZAudioPlayerDelegate>)delegate
{
    return [[self alloc] initWithURL:url delegate:delegate];
}

//------------------------------------------------------------------------------
#pragma mark - Initialization
//------------------------------------------------------------------------------

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self setup];
    }
    return self;
}

//------------------------------------------------------------------------------

- (instancetype)initWithDelegate:(id<EZAudioPlayerDelegate>)delegate
{
    self = [self init];
    if (self)
    {
        self.delegate = delegate;
    }
    return self;
}

//------------------------------------------------------------------------------

- (instancetype)initWithAudioFile:(EZAudioFile *)audioFile
{
    return [self initWithAudioFile:audioFile delegate:nil];
}

//------------------------------------------------------------------------------

- (instancetype)initWithAudioFile:(EZAudioFile *)audioFile
                            delegate:(id<EZAudioPlayerDelegate>)delegate
{
    self = [self initWithDelegate:delegate];
    if (self)
    {
        self.audioFile = audioFile;
    }
    return self;
}

//------------------------------------------------------------------------------

- (instancetype)initWithURL:(NSURL *)url
{
    return [self initWithURL:url delegate:nil];
}

//------------------------------------------------------------------------------

- (instancetype)initWithURL:(NSURL *)url
                      delegate:(id<EZAudioPlayerDelegate>)delegate
{
    self = [self initWithDelegate:delegate];
    if (self)
    {
        self.audioFile = [EZAudioFile audioFileWithURL:url delegate:self];
    }
    return self;
}

//------------------------------------------------------------------------------
#pragma mark - Singleton
//------------------------------------------------------------------------------

+ (instancetype)sharedAudioPlayer
{
    static EZAudioPlayer *player;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        player = [[self alloc] init];
    });
    return player;
}

//------------------------------------------------------------------------------
#pragma mark - Setup
//------------------------------------------------------------------------------

- (void)setup
{
    self.output = [EZOutput output];
}

//------------------------------------------------------------------------------
#pragma mark - Getters
//------------------------------------------------------------------------------

- (NSTimeInterval)currentTime
{
    return [self.audioFile currentTime];
}

//------------------------------------------------------------------------------

- (EZAudioDevice *)device
{
    return [self.output device];
}

//------------------------------------------------------------------------------

- (NSTimeInterval)duration
{
    return [self.audioFile duration];
}

//------------------------------------------------------------------------------

- (NSString *)formattedCurrentTime
{
    return [self.audioFile formattedCurrentTime];
}

//------------------------------------------------------------------------------

- (NSString *)formattedDuration
{
    return [self.audioFile formattedDuration];
}

//------------------------------------------------------------------------------

- (SInt64)frameIndex
{
    return [self.audioFile frameIndex];
}

//------------------------------------------------------------------------------

- (BOOL)isPlaying
{
    return [self.output isPlaying];
}

//------------------------------------------------------------------------------

- (float)pan
{
    return [self.output pan];
}

//------------------------------------------------------------------------------

- (SInt64)totalFrames
{
    return [self.audioFile totalFrames];
}

//------------------------------------------------------------------------------

- (float)volume
{
    return [self.output volume];
}

//------------------------------------------------------------------------------
#pragma mark - Setters
//------------------------------------------------------------------------------

- (void)setAudioFile:(EZAudioFile *)audioFile
{
    _audioFile = [audioFile copy];
    _audioFile.delegate = self;
    AudioStreamBasicDescription inputFormat = _audioFile.clientFormat;
    [self.output setInputFormat:inputFormat];
    [[NSNotificationCenter defaultCenter] postNotificationName:EZAudioPlayerDidChangeAudioFileNotification
                                                        object:self];
}

//------------------------------------------------------------------------------

- (void)setCurrentTime:(NSTimeInterval)currentTime
{
    [self.audioFile setCurrentTime:currentTime];
    [[NSNotificationCenter defaultCenter] postNotificationName:EZAudioPlayerDidSeekNotification
                                                        object:self];
}

//------------------------------------------------------------------------------

- (void)setDevice:(EZAudioDevice *)device
{
    [self.output setDevice:device];
}

//------------------------------------------------------------------------------

- (void)setOutput:(EZOutput *)output
{
    _output = output;
    _output.dataSource = self;
    _output.delegate = self;
}

//------------------------------------------------------------------------------

- (void)setPan:(float)pan
{
    [self.output setPan:pan];
    [[NSNotificationCenter defaultCenter] postNotificationName:EZAudioPlayerDidChangePanNotification
                                                        object:self];
}

//------------------------------------------------------------------------------

- (void)setVolume:(float)volume
{
    [self.output setVolume:volume];
    [[NSNotificationCenter defaultCenter] postNotificationName:EZAudioPlayerDidChangeVolumeNotification
                                                        object:self];
}

//------------------------------------------------------------------------------
#pragma mark - Actions
//------------------------------------------------------------------------------

- (void)play
{
    [self.output startPlayback];
}

//------------------------------------------------------------------------------

- (void)playAudioFile:(EZAudioFile *)audioFile
{
    //
    // stop playing anything that might currently be playing
    //
    [self pause];
    
    //
    // set new stream
    //
    self.audioFile = audioFile;
    
    //
    // begin playback
    //
    [self play];
}

//------------------------------------------------------------------------------

- (void)pause
{
    [self.output stopPlayback];
}

//------------------------------------------------------------------------------

- (void)seekToFrame:(SInt64)frame
{
    [self.audioFile seekToFrame:frame];
    [[NSNotificationCenter defaultCenter] postNotificationName:EZAudioPlayerDidSeekNotification
                                                        object:self];
}

//------------------------------------------------------------------------------
#pragma mark - EZOutputDataSource
//------------------------------------------------------------------------------

- (OSStatus)        output:(EZOutput *)output
 shouldFillAudioBufferList:(AudioBufferList *)audioBufferList
        withNumberOfFrames:(UInt32)frames
                 timestamp:(const AudioTimeStamp *)timestamp
{
    if (self.audioFile)
    {
        UInt32 bufferSize;
        BOOL eof;
        [self.audioFile readFrames:frames
                   audioBufferList:audioBufferList
                        bufferSize:&bufferSize
                               eof:&eof];
        if (eof && [self.delegate respondsToSelector:@selector(audioPlayer:reachedEndOfAudioFile:)]) 
        {
            [self.delegate audioPlayer:self reachedEndOfAudioFile:self.audioFile];
        }
        if (eof && self.shouldLoop)
        {
            [self seekToFrame:0];
        }
        else if (eof)
        {
            [self pause];
            [self seekToFrame:0];
            [[NSNotificationCenter defaultCenter] postNotificationName:EZAudioPlayerDidReachEndOfFileNotification
                                                                object:self];
        }
    }
    return noErr;
}

//------------------------------------------------------------------------------
#pragma mark - EZAudioFileDelegate
//------------------------------------------------------------------------------

- (void)audioFileUpdatedPosition:(EZAudioFile *)audioFile
{
    if ([self.delegate respondsToSelector:@selector(audioPlayer:updatedPosition:inAudioFile:)])
    {
        [self.delegate audioPlayer:self
                   updatedPosition:[audioFile frameIndex]
                       inAudioFile:audioFile];
    }
}

//------------------------------------------------------------------------------
#pragma mark - EZOutputDelegate
//------------------------------------------------------------------------------

- (void)output:(EZOutput *)output changedDevice:(EZAudioDevice *)device
{
    [[NSNotificationCenter defaultCenter] postNotificationName:EZAudioPlayerDidChangeOutputDeviceNotification
                                                        object:self];
}

//------------------------------------------------------------------------------

- (void)output:(EZOutput *)output changedPlayingState:(BOOL)isPlaying
{
    [[NSNotificationCenter defaultCenter] postNotificationName:EZAudioPlayerDidChangePlayStateNotification
                                                        object:self];
}

//------------------------------------------------------------------------------

- (void)       output:(EZOutput *)output
          playedAudio:(float **)buffer
       withBufferSize:(UInt32)bufferSize
 withNumberOfChannels:(UInt32)numberOfChannels
{
    if ([self.delegate respondsToSelector:@selector(audioPlayer:playedAudio:withBufferSize:withNumberOfChannels:inAudioFile:)])
    {
        [self.delegate audioPlayer:self
                       playedAudio:buffer
                    withBufferSize:bufferSize
              withNumberOfChannels:numberOfChannels
                       inAudioFile:self.audioFile];
    }
}

//------------------------------------------------------------------------------

@end
