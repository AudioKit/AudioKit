//
//  EZRecorder.m
//  EZAudio
//
//  Created by Syed Haris Ali on 12/1/13.
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

#import "EZRecorder.h"
#import "EZAudioUtilities.h"

//------------------------------------------------------------------------------
#pragma mark - Data Structures
//------------------------------------------------------------------------------

typedef struct
{
    AudioFileTypeID             audioFileTypeID;
    ExtAudioFileRef             extAudioFileRef;
    AudioStreamBasicDescription clientFormat;
    BOOL                        closed;
    CFURLRef                    fileURL;
    AudioStreamBasicDescription fileFormat;
} EZRecorderInfo;

//------------------------------------------------------------------------------
#pragma mark - EZRecorder (Interface Extension)
//------------------------------------------------------------------------------

@interface EZRecorder ()
@property (nonatomic, assign) EZRecorderInfo *info;
@end

//------------------------------------------------------------------------------
#pragma mark - EZRecorder (Implementation)
//------------------------------------------------------------------------------

@implementation EZRecorder

//------------------------------------------------------------------------------
#pragma mark - Dealloc
//------------------------------------------------------------------------------

- (void)dealloc
{
    if (!self.info->closed)
    {
        [self closeAudioFile];
    }
    free(self.info);
}

//------------------------------------------------------------------------------
#pragma mark - Initializers
//------------------------------------------------------------------------------

- (instancetype)initWithURL:(NSURL *)url
               clientFormat:(AudioStreamBasicDescription)clientFormat
                   fileType:(EZRecorderFileType)fileType
{
    return [self initWithURL:url
                clientFormat:clientFormat
                    fileType:fileType
                    delegate:nil];
}

//------------------------------------------------------------------------------

- (instancetype)initWithURL:(NSURL *)url
               clientFormat:(AudioStreamBasicDescription)clientFormat
                   fileType:(EZRecorderFileType)fileType
                   delegate:(id<EZRecorderDelegate>)delegate
{
    AudioStreamBasicDescription fileFormat = [EZRecorder formatForFileType:fileType
                                                          withSourceFormat:clientFormat];
    AudioFileTypeID audioFileTypeID = [EZRecorder fileTypeIdForFileType:fileType
                                                       withSourceFormat:clientFormat];
    return [self initWithURL:url
                clientFormat:clientFormat
                  fileFormat:fileFormat
             audioFileTypeID:audioFileTypeID
                    delegate:delegate];
}

//------------------------------------------------------------------------------

- (instancetype)initWithURL:(NSURL *)url
               clientFormat:(AudioStreamBasicDescription)clientFormat
                 fileFormat:(AudioStreamBasicDescription)fileFormat
            audioFileTypeID:(AudioFileTypeID)audioFileTypeID
{
    return [self initWithURL:url
                clientFormat:clientFormat
                  fileFormat:fileFormat
             audioFileTypeID:audioFileTypeID
                    delegate:nil];
}

//------------------------------------------------------------------------------

- (instancetype)initWithURL:(NSURL *)url
               clientFormat:(AudioStreamBasicDescription)clientFormat
                 fileFormat:(AudioStreamBasicDescription)fileFormat
            audioFileTypeID:(AudioFileTypeID)audioFileTypeID
                   delegate:(id<EZRecorderDelegate>)delegate
{
    
    self = [super init];
    if (self)
    {
        // Set defaults
        self.info = (EZRecorderInfo *)calloc(1, sizeof(EZRecorderInfo));
        self.info->audioFileTypeID  = audioFileTypeID;
        self.info->fileURL = (__bridge CFURLRef)url;
        self.info->clientFormat = clientFormat;
        self.info->fileFormat = fileFormat;
        self.delegate = delegate;
        [self setup];
    }
    return self;
}

//------------------------------------------------------------------------------

- (instancetype)initWithDestinationURL:(NSURL*)url
                        sourceFormat:(AudioStreamBasicDescription)sourceFormat
                 destinationFileType:(EZRecorderFileType)destinationFileType
{
    return [self initWithURL:url
                clientFormat:sourceFormat
                    fileType:destinationFileType];
}

//------------------------------------------------------------------------------
#pragma mark - Class Initializers
//------------------------------------------------------------------------------

+ (instancetype)recorderWithURL:(NSURL *)url
                   clientFormat:(AudioStreamBasicDescription)clientFormat
                       fileType:(EZRecorderFileType)fileType
{
    return [[self alloc] initWithURL:url
                        clientFormat:clientFormat
                            fileType:fileType];
}

//------------------------------------------------------------------------------

+ (instancetype)recorderWithURL:(NSURL *)url
                   clientFormat:(AudioStreamBasicDescription)clientFormat
                       fileType:(EZRecorderFileType)fileType
                       delegate:(id<EZRecorderDelegate>)delegate
{
    return [[self alloc] initWithURL:url
                        clientFormat:clientFormat
                            fileType:fileType
                            delegate:delegate];
}

//------------------------------------------------------------------------------

+ (instancetype)recorderWithURL:(NSURL *)url
                   clientFormat:(AudioStreamBasicDescription)clientFormat
                     fileFormat:(AudioStreamBasicDescription)fileFormat
                audioFileTypeID:(AudioFileTypeID)audioFileTypeID
{
    return [[self alloc] initWithURL:url
                        clientFormat:clientFormat
                          fileFormat:fileFormat
                     audioFileTypeID:audioFileTypeID];
}

//------------------------------------------------------------------------------

+ (instancetype)recorderWithURL:(NSURL *)url
                   clientFormat:(AudioStreamBasicDescription)clientFormat
                     fileFormat:(AudioStreamBasicDescription)fileFormat
                audioFileTypeID:(AudioFileTypeID)audioFileTypeID
                       delegate:(id<EZRecorderDelegate>)delegate
{
    return [[self alloc] initWithURL:url
                        clientFormat:clientFormat
                          fileFormat:fileFormat
                     audioFileTypeID:audioFileTypeID
                            delegate:delegate];
}

//------------------------------------------------------------------------------

+ (instancetype)recorderWithDestinationURL:(NSURL*)url
                             sourceFormat:(AudioStreamBasicDescription)sourceFormat
                      destinationFileType:(EZRecorderFileType)destinationFileType
{
    return [[EZRecorder alloc] initWithDestinationURL:url
                                         sourceFormat:sourceFormat
                                  destinationFileType:destinationFileType];
}

//------------------------------------------------------------------------------
#pragma mark - Class Methods
//------------------------------------------------------------------------------

+ (AudioStreamBasicDescription)formatForFileType:(EZRecorderFileType)fileType
                                withSourceFormat:(AudioStreamBasicDescription)sourceFormat
{
    AudioStreamBasicDescription asbd;
    switch (fileType)
    {
        case EZRecorderFileTypeAIFF:
            asbd = [EZAudioUtilities AIFFFormatWithNumberOfChannels:sourceFormat.mChannelsPerFrame
                                                         sampleRate:sourceFormat.mSampleRate];
            break;
        case EZRecorderFileTypeM4A:
            asbd = [EZAudioUtilities M4AFormatWithNumberOfChannels:sourceFormat.mChannelsPerFrame
                                                        sampleRate:sourceFormat.mSampleRate];
            break;
            
        case EZRecorderFileTypeWAV:
            asbd = [EZAudioUtilities stereoFloatInterleavedFormatWithSampleRate:sourceFormat.mSampleRate];
            break;
            
        default:
            asbd = [EZAudioUtilities stereoCanonicalNonInterleavedFormatWithSampleRate:sourceFormat.mSampleRate];
            break;
    }
    return asbd;
}

//------------------------------------------------------------------------------

+ (AudioFileTypeID)fileTypeIdForFileType:(EZRecorderFileType)fileType
                        withSourceFormat:(AudioStreamBasicDescription)sourceFormat
{
    AudioFileTypeID audioFileTypeID;
    switch (fileType)
    {
        case EZRecorderFileTypeAIFF:
            audioFileTypeID = kAudioFileAIFFType;
            break;
            
        case EZRecorderFileTypeM4A:
            audioFileTypeID = kAudioFileM4AType;
            break;
            
        case EZRecorderFileTypeWAV:
            audioFileTypeID = kAudioFileWAVEType;
            break;
            
        default:
            audioFileTypeID = kAudioFileWAVEType;
            break;
    }
    return audioFileTypeID;
}

//------------------------------------------------------------------------------

- (void)setup
{
    // Finish filling out the destination format description
    UInt32 propSize = sizeof(self.info->fileFormat);
    [EZAudioUtilities checkResult:AudioFormatGetProperty(kAudioFormatProperty_FormatInfo,
                                                         0,
                                                         NULL,
                                                         &propSize,
                                                         &self.info->fileFormat)
                        operation:"Failed to fill out rest of destination format"];
    
    //
    // Create the audio file
    //
    [EZAudioUtilities checkResult:ExtAudioFileCreateWithURL(self.info->fileURL,
                                                            self.info->audioFileTypeID,
                                                            &self.info->fileFormat,
                                                            NULL,
                                                            kAudioFileFlags_EraseFile,
                                                            &self.info->extAudioFileRef)
                        operation:"Failed to create audio file"];
    
    //
    // Set the client format
    //
    [self setClientFormat:self.info->clientFormat];
}

//------------------------------------------------------------------------------
#pragma mark - Events
//------------------------------------------------------------------------------

- (void)appendDataFromBufferList:(AudioBufferList *)bufferList
                  withBufferSize:(UInt32)bufferSize
{
    //
    // Make sure the audio file is not closed
    //
    NSAssert(!self.info->closed, @"Cannot append data when EZRecorder has been closed. You must create a new instance.;");
    
    //
    // Perform the write
    //
    [EZAudioUtilities checkResult:ExtAudioFileWrite(self.info->extAudioFileRef,
                                                         bufferSize,
                                                         bufferList)
               operation:"Failed to write audio data to recorded audio file"];
    
    //
    // Notify delegate
    //
    if ([self.delegate respondsToSelector:@selector(recorderUpdatedCurrentTime:)])
    {
        [self.delegate recorderUpdatedCurrentTime:self];
    }
}

//------------------------------------------------------------------------------

- (void)closeAudioFile
{
    if (!self.info->closed)
    {
        //
        // Close, audio file can no longer be written to
        //
        [EZAudioUtilities checkResult:ExtAudioFileDispose(self.info->extAudioFileRef)
                            operation:"Failed to close audio file"];
        self.info->closed = YES;
        
        //
        // Notify delegate
        //
        if ([self.delegate respondsToSelector:@selector(recorderDidClose:)])
        {
            [self.delegate recorderDidClose:self];
        }
    }
}

//------------------------------------------------------------------------------
#pragma mark - Getters
//------------------------------------------------------------------------------

- (AudioStreamBasicDescription)clientFormat
{
    return self.info->clientFormat;
}

//-----------------------------------------------------------------------------

- (NSTimeInterval)currentTime
{
    NSTimeInterval currentTime = 0.0;
    NSTimeInterval duration = [self duration];
    if (duration != 0.0)
    {
        currentTime = (NSTimeInterval)[EZAudioUtilities MAP:(float)[self frameIndex]
                                                    leftMin:0.0f
                                                    leftMax:(float)[self totalFrames]
                                                   rightMin:0.0f
                                                   rightMax:duration];
    }
    return currentTime;
}

//------------------------------------------------------------------------------

- (NSTimeInterval)duration
{
    NSTimeInterval frames = (NSTimeInterval)[self totalFrames];
    return (NSTimeInterval) frames / self.info->fileFormat.mSampleRate;
}

//------------------------------------------------------------------------------

- (AudioStreamBasicDescription)fileFormat
{
    return self.info->fileFormat;
}

//------------------------------------------------------------------------------

- (NSString *)formattedCurrentTime
{
    return [EZAudioUtilities displayTimeStringFromSeconds:[self currentTime]];
}

//------------------------------------------------------------------------------

- (NSString *)formattedDuration
{
    return [EZAudioUtilities displayTimeStringFromSeconds:[self duration]];
}

//------------------------------------------------------------------------------

- (SInt64)frameIndex
{
    SInt64 frameIndex;
    [EZAudioUtilities checkResult:ExtAudioFileTell(self.info->extAudioFileRef,
                                                   &frameIndex)
                        operation:"Failed to get frame index"];
    return frameIndex;
}

//------------------------------------------------------------------------------

- (SInt64)totalFrames
{
    SInt64 totalFrames;
    UInt32 propSize = sizeof(SInt64);
    [EZAudioUtilities checkResult:ExtAudioFileGetProperty(self.info->extAudioFileRef,
                                                          kExtAudioFileProperty_FileLengthFrames,
                                                          &propSize,
                                                          &totalFrames)
                        operation:"Recorder failed to get total frames."];
    return totalFrames;
}

//------------------------------------------------------------------------------

- (NSURL *)url
{
    return (__bridge NSURL*)self.info->fileURL;
}

//------------------------------------------------------------------------------
#pragma mark - Setters
//------------------------------------------------------------------------------

- (void)setClientFormat:(AudioStreamBasicDescription)clientFormat
{
    [EZAudioUtilities checkResult:ExtAudioFileSetProperty(self.info->extAudioFileRef,
                                                          kExtAudioFileProperty_ClientDataFormat,
                                                          sizeof(clientFormat),
                                                          &clientFormat)
                        operation:"Failed to set client format on recorded audio file"];
    self.info->clientFormat = clientFormat;
}

@end