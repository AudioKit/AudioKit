//
//  EZAudioFile.m
//  EZAudio
//
//  Created by Syed Haris Ali, revision history on Githbub.
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

#import "EZAudioFile.h"

//------------------------------------------------------------------------------

#import "EZAudio.h"
#import "EZAudioFloatConverter.h"
#import "EZAudioFloatData.h"
//#import "EZAudioFileMarker.h"

#include <pthread.h>

// constants
static UInt32 EZAudioFileWaveformDefaultResolution = 1024;
static NSString *EZAudioFileWaveformDataQueueIdentifier = @"com.ezaudio.waveformQueue";

//------------------------------------------------------------------------------

typedef struct
{
    AudioFileID                 audioFileID;
    AudioStreamBasicDescription clientFormat;
    NSTimeInterval              duration;
    ExtAudioFileRef             extAudioFileRef;
    AudioStreamBasicDescription fileFormat;
    SInt64                      frames;
    CFURLRef                    sourceURL;
} EZAudioFileInfo;

//------------------------------------------------------------------------------
#pragma mark - EZAudioFile
//------------------------------------------------------------------------------

@interface EZAudioFile ()
@property (nonatomic, strong) EZAudioFloatConverter  *floatConverter;
@property (nonatomic)         float                 **floatData;
@property (nonatomic)         EZAudioFileInfo        *info;
@property (nonatomic)         pthread_mutex_t         lock;
@property (nonatomic)         dispatch_queue_t        waveformQueue;
@end

//------------------------------------------------------------------------------

@implementation EZAudioFile

//------------------------------------------------------------------------------
#pragma mark - Dealloc
//------------------------------------------------------------------------------

- (void)dealloc
{
    self.floatConverter = nil;
    pthread_mutex_destroy(&_lock);
    [EZAudioUtilities freeFloatBuffers:self.floatData numberOfChannels:self.clientFormat.mChannelsPerFrame];
    [EZAudioUtilities checkResult:ExtAudioFileDispose(self.info->extAudioFileRef) operation:"Failed to dispose of ext audio file"];
    free(self.info);
}

//------------------------------------------------------------------------------
#pragma mark - Initialization
//------------------------------------------------------------------------------

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.info = (EZAudioFileInfo *)malloc(sizeof(EZAudioFileInfo));
        _floatData = NULL;
        pthread_mutex_init(&_lock, NULL);
        _waveformQueue = dispatch_queue_create(EZAudioFileWaveformDataQueueIdentifier.UTF8String, DISPATCH_QUEUE_PRIORITY_DEFAULT);
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
                   delegate:(id<EZAudioFileDelegate>)delegate
{
    return [self initWithURL:url
                    delegate:delegate
                clientFormat:[self.class defaultClientFormat]];
}

//------------------------------------------------------------------------------

- (instancetype)initWithURL:(NSURL *)url
                   delegate:(id<EZAudioFileDelegate>)delegate
               clientFormat:(AudioStreamBasicDescription)clientFormat
{
    self = [self init];
    if (self)
    {
        self.info->sourceURL = (__bridge CFURLRef)(url);
        self.info->clientFormat = clientFormat;
        self.delegate = delegate;
        if (![self setup])
        {
            return nil;
        }
    }
    return self;
}

//------------------------------------------------------------------------------
#pragma mark - Class Initializers
//------------------------------------------------------------------------------

+ (instancetype)audioFileWithURL:(NSURL *)url
{
    return [[self alloc] initWithURL:url];
}

//------------------------------------------------------------------------------

+ (instancetype)audioFileWithURL:(NSURL *)url
                        delegate:(id<EZAudioFileDelegate>)delegate
{
    return [[self alloc] initWithURL:url delegate:delegate];
}

//------------------------------------------------------------------------------

+ (instancetype)audioFileWithURL:(NSURL *)url
                        delegate:(id<EZAudioFileDelegate>)delegate
                    clientFormat:(AudioStreamBasicDescription)clientFormat
{
    return [[self alloc] initWithURL:url
                            delegate:delegate
                        clientFormat:clientFormat];
}

//------------------------------------------------------------------------------
#pragma mark - NSCopying
//------------------------------------------------------------------------------

- (id)copyWithZone:(NSZone *)zone
{
    return [EZAudioFile audioFileWithURL:self.url];
}

//------------------------------------------------------------------------------
#pragma mark - Class Methods
//------------------------------------------------------------------------------

+ (AudioStreamBasicDescription)defaultClientFormat
{
    return [EZAudioUtilities stereoFloatNonInterleavedFormatWithSampleRate:[self defaultClientFormatSampleRate]];
}

//------------------------------------------------------------------------------

+ (Float64)defaultClientFormatSampleRate
{
    return 44100.0f;
}

//------------------------------------------------------------------------------

+ (NSArray *)supportedAudioFileTypes
{
    return @
    [
        @"aac",
        @"caf",
        @"aif",
        @"aiff",
        @"aifc",
        @"mp3",
        @"mp4",
        @"m4a",
        @"snd",
        @"au",
        @"sd2",
        @"wav"
    ];
}

//------------------------------------------------------------------------------
#pragma mark - Setup
//------------------------------------------------------------------------------

- (BOOL)setup
{
    //
    // Try to open the file, bail if the file could not be opened
    //
    BOOL success = [self openAudioFile];
    if (!success)
    {
        return success;
    }

    //
    // Set the client format
    //
    self.clientFormat = self.info->clientFormat;

    return YES;
}

//------------------------------------------------------------------------------
#pragma mark - Creating/Opening Audio File
//------------------------------------------------------------------------------

- (BOOL)openAudioFile
{
    //
    // Need a source url
    //
    NSAssert(self.info->sourceURL, @"EZAudioFile cannot be created without a source url!");

    //
    // Determine if the file actually exists
    //
    CFURLRef url = self.info->sourceURL;
    NSURL *fileURL = (__bridge NSURL *)(url);
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:fileURL.path];

    //
    // Create an ExtAudioFileRef for the file handle
    //
    if (fileExists)
    {
        [EZAudioUtilities checkResult:ExtAudioFileOpenURL(url, &self.info->extAudioFileRef)
                            operation:"Failed to create ExtAudioFileRef"];
    }
    else
    {
        return NO;
    }

    //
    // Get the underlying AudioFileID
    //
    UInt32 propSize = sizeof(self.info->audioFileID);
    [EZAudioUtilities checkResult:ExtAudioFileGetProperty(self.info->extAudioFileRef,
                                                          kExtAudioFileProperty_AudioFile,
                                                          &propSize,
                                                          &self.info->audioFileID)
                        operation:"Failed to get underlying AudioFileID"];

    //
    // Store the file format
    //
    propSize = sizeof(self.info->fileFormat);
    [EZAudioUtilities checkResult:ExtAudioFileGetProperty(self.info->extAudioFileRef,
                                                          kExtAudioFileProperty_FileDataFormat,
                                                          &propSize,
                                                          &self.info->fileFormat)
                        operation:"Failed to get file audio format on existing audio file"];

    //
    // Get the total frames and duration
    //
    propSize = sizeof(SInt64);
    [EZAudioUtilities checkResult:ExtAudioFileGetProperty(self.info->extAudioFileRef,
                                                          kExtAudioFileProperty_FileLengthFrames,
                                                          &propSize,
                                                          &self.info->frames)
                        operation:"Failed to get total frames"];
    self.info->duration = (NSTimeInterval) self.info->frames / self.info->fileFormat.mSampleRate;

    return YES;
}

//------------------------------------------------------------------------------
#pragma mark - Events
//------------------------------------------------------------------------------

- (void)readFrames:(UInt32)frames
    audioBufferList:(AudioBufferList *)audioBufferList
         bufferSize:(UInt32 *)bufferSize
               eof:(BOOL *)eof
{
    if (pthread_mutex_trylock(&_lock) == 0)
    {
        // perform read
        [EZAudioUtilities checkResult:ExtAudioFileRead(self.info->extAudioFileRef,
                                                       &frames,
                                                       audioBufferList)
                            operation:"Failed to read audio data from file"];
        *bufferSize = frames;
        *eof = frames == 0;

        //
        // Notify delegate
        //
        if ([self.delegate respondsToSelector:@selector(audioFileUpdatedPosition:)])
        {
            [self.delegate audioFileUpdatedPosition:self];
        }

        //
        // Deprecated, but supported until 1.0
        //
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
        if ([self.delegate respondsToSelector:@selector(audioFile:updatedPosition:)])
        {
            [self.delegate audioFile:self updatedPosition:[self frameIndex]];
        }
#pragma GCC diagnostic pop

        if ([self.delegate respondsToSelector:@selector(audioFile:readAudio:withBufferSize:withNumberOfChannels:)])
        {
            // convert into float data
            [self.floatConverter convertDataFromAudioBufferList:audioBufferList
                                             withNumberOfFrames:*bufferSize
                                                 toFloatBuffers:self.floatData];

            // notify delegate
            UInt32 channels = self.clientFormat.mChannelsPerFrame;
            [self.delegate audioFile:self
                           readAudio:self.floatData
                      withBufferSize:*bufferSize
                withNumberOfChannels:channels];
        }

        pthread_mutex_unlock(&_lock);

    }
}

//------------------------------------------------------------------------------

- (void)seekToFrame:(SInt64)frame
{
    if (pthread_mutex_trylock(&_lock) == 0)
    {
        [EZAudioUtilities checkResult:ExtAudioFileSeek(self.info->extAudioFileRef,
                                                       frame)
                   operation:"Failed to seek frame position within audio file"];

        pthread_mutex_unlock(&_lock);

        //
        // Notify delegate
        //
        if ([self.delegate respondsToSelector:@selector(audioFileUpdatedPosition:)])
        {
            [self.delegate audioFileUpdatedPosition:self];
        }

        //
        // Deprecated, but supported until 1.0
        //
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
        if ([self.delegate respondsToSelector:@selector(audioFile:updatedPosition:)])
        {
            [self.delegate audioFile:self updatedPosition:[self frameIndex]];
        }
#pragma GCC diagnostic pop
    }
}

//------------------------------------------------------------------------------
#pragma mark - Getters
//------------------------------------------------------------------------------

- (AudioStreamBasicDescription)floatFormat
{
    return [EZAudioUtilities stereoFloatNonInterleavedFormatWithSampleRate:44100.0f];
}

//------------------------------------------------------------------------------

- (EZAudioFloatData *)getWaveformData
{
    return [self getWaveformDataWithNumberOfPoints:EZAudioFileWaveformDefaultResolution];
}

//------------------------------------------------------------------------------

- (EZAudioFloatData *)getWaveformDataWithNumberOfPoints:(UInt32)numberOfPoints
{
    EZAudioFloatData *waveformData;
    if (pthread_mutex_trylock(&_lock) == 0)
    {
        // store current frame
        SInt64 currentFrame = self.frameIndex;
        BOOL interleaved = [EZAudioUtilities isInterleaved:self.clientFormat];
        UInt32 channels = self.clientFormat.mChannelsPerFrame;
        if (channels == 0)
        {
            // prevent division by zero
            pthread_mutex_unlock(&_lock);
            return nil;
        }
        float **data = (float **)malloc( sizeof(float*) * channels );
        for (int i = 0; i < channels; i++)
        {
            data[i] = (float *)malloc( sizeof(float) * numberOfPoints );
        }

        // seek to 0
        [EZAudioUtilities checkResult:ExtAudioFileSeek(self.info->extAudioFileRef,
                                                       0)
                            operation:"Failed to seek frame position within audio file"];

        // calculate the required number of frames per buffer
        SInt64 framesPerBuffer = ((SInt64) self.totalClientFrames / numberOfPoints);
        SInt64 framesPerChannel = framesPerBuffer / channels;

        // allocate an audio buffer list
        AudioBufferList *audioBufferList = [EZAudioUtilities audioBufferListWithNumberOfFrames:(UInt32)framesPerBuffer
                                                                              numberOfChannels:self.info->clientFormat.mChannelsPerFrame
                                                                                   interleaved:interleaved];

        // read through file and calculate rms at each point
        for (SInt64 i = 0; i < numberOfPoints; i++)
        {
            UInt32 bufferSize = (UInt32) framesPerBuffer;
            [EZAudioUtilities checkResult:ExtAudioFileRead(self.info->extAudioFileRef,
                                                           &bufferSize,
                                                           audioBufferList)
                                operation:"Failed to read audio data from file waveform"];
            if (interleaved)
            {
                float *buffer = (float *)audioBufferList->mBuffers[0].mData;
                for (int channel = 0; channel < channels; channel++)
                {
                    float channelData[framesPerChannel];
                    for (int frame = 0; frame < framesPerChannel; frame++)
                    {
                        channelData[frame] = buffer[frame * channels + channel];
                    }
                    float rms = [EZAudioUtilities RMS:channelData length:(UInt32)framesPerChannel];
                    data[channel][i] = rms;
                }
            }
            else
            {
                for (int channel = 0; channel < channels; channel++)
                {
                    float *channelData = audioBufferList->mBuffers[channel].mData;
                    float rms = [EZAudioUtilities RMS:channelData length:bufferSize];
                    data[channel][i] = rms;
                }
            }
        }

        // clean up
        [EZAudioUtilities freeBufferList:audioBufferList];

        // seek back to previous position
        [EZAudioUtilities checkResult:ExtAudioFileSeek(self.info->extAudioFileRef,
                                                       currentFrame)
                            operation:"Failed to seek frame position within audio file"];

        pthread_mutex_unlock(&_lock);

        waveformData = [EZAudioFloatData dataWithNumberOfChannels:channels
                                                          buffers:(float **)data
                                                       bufferSize:numberOfPoints];

        // cleanup
        for (int i = 0; i < channels; i++)
        {
            free(data[i]);
        }
        free(data);
    }
    return waveformData;
}

//------------------------------------------------------------------------------

- (void)getWaveformDataWithCompletionBlock:(EZAudioWaveformDataCompletionBlock)waveformDataCompletionBlock
{
    [self getWaveformDataWithNumberOfPoints:EZAudioFileWaveformDefaultResolution
                                 completion:waveformDataCompletionBlock];
}

//------------------------------------------------------------------------------

- (void)getWaveformDataWithNumberOfPoints:(UInt32)numberOfPoints
                               completion:(EZAudioWaveformDataCompletionBlock)completion
{
    if (!completion)
    {
        return;
    }

    // async get waveform data
    __weak EZAudioFile *weakSelf = self;
    dispatch_async(self.waveformQueue, ^{
        EZAudioFloatData *waveformData = [weakSelf getWaveformDataWithNumberOfPoints:numberOfPoints];
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(waveformData.buffers, waveformData.bufferSize);
        });
    });
}

//------------------------------------------------------------------------------

- (AudioStreamBasicDescription)clientFormat
{
    return self.info->clientFormat;
}

//------------------------------------------------------------------------------

- (NSTimeInterval)currentTime
{
    return [EZAudioUtilities MAP:(float)[self frameIndex]
                         leftMin:0.0f
                         leftMax:(float)[self totalFrames]
                        rightMin:0.0f
                        rightMax:[self duration]];
}

//------------------------------------------------------------------------------

- (NSTimeInterval)duration
{
    return self.info->duration;
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
    [EZAudioUtilities checkResult:ExtAudioFileTell(self.info->extAudioFileRef, &frameIndex)
                        operation:"Failed to get frame index"];
    return frameIndex;
}

//------------------------------------------------------------------------------

- (NSDictionary *)metadata
{
    // get size of metadata property (dictionary)
    UInt32          propSize = sizeof(self.info->audioFileID);
    CFDictionaryRef metadata;
    UInt32          writable;
    [EZAudioUtilities checkResult:AudioFileGetPropertyInfo(self.info->audioFileID,
                                                           kAudioFilePropertyInfoDictionary,
                                                           &propSize,
                                                           &writable)
                        operation:"Failed to get the size of the metadata dictionary"];

    // pull metadata
    [EZAudioUtilities checkResult:AudioFileGetProperty(self.info->audioFileID,
                                                       kAudioFilePropertyInfoDictionary,
                                                       &propSize,
                                                       &metadata)
                        operation:"Failed to get metadata dictionary"];

    // cast to NSDictionary
    return (__bridge NSDictionary*)metadata;
}

//------------------------------------------------------------------------------

/// return the markers in this file. This will be a NSArray of EZAudioFileMarkers
- (NSArray *)markers
{
    // get size of markers property (dictionary)
    UInt32          propSize;
    UInt32          writable;

    [EZAudioUtilities checkResult:AudioFileGetPropertyInfo( self.audioFileID,
                                                           kAudioFilePropertyMarkerList,
                                                           &propSize,
                                                           &writable)
                        operation:"Failed to get the size of the marker list"];

    size_t length = NumBytesToNumAudioFileMarkers( propSize );

    // allocate enough space for the markers.
    AudioFileMarkerList markerList[ length ];

    if (length > 0) {
        // pull marker list
        [EZAudioUtilities checkResult:AudioFileGetProperty( self.audioFileID,
                                                           kAudioFilePropertyMarkerList,
                                                           &propSize,
                                                           &markerList)
                            operation:"Failed to get the markers list"];

    } else {
        return NULL;
    }
    //NSLog(@"# of markers: %d\n", markers->mNumberMarkers );

    // the native C structs aren't so friendly with Swift, so we'll load up an array instead
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:markerList->mNumberMarkers];

    int i;
    for (i=0; i < markerList->mNumberMarkers; i++) {
        EZAudioFileMarker *afm = [[EZAudioFileMarker alloc] init];

        afm.framePosition = [[NSNumber alloc] initWithDouble:(markerList->mMarkers[i].mFramePosition)];
        afm.markerID = [[NSNumber alloc] initWithInt:(markerList->mMarkers[i].mMarkerID)];
        afm.type = [[NSNumber alloc] initWithInt:(markerList->mMarkers[i].mType)];

        // create a default value in the case of missing names
        afm.name = [NSString stringWithFormat:@"Marker %d", i+1];
        
        if (markerList->mMarkers[i].mName != NULL) {
            afm.name = (__bridge NSString *)(markerList->mMarkers[i].mName);
        }
        //NSLog(@"%@\n", afm.name );
        [array addObject:afm];
    }
    // cast to an immutable one
    NSArray *nmArray = [array copy];
    return nmArray;
}

//------------------------------------------------------------------------------

- (NSTimeInterval)totalDuration
{
    return self.info->duration;
}

//------------------------------------------------------------------------------

- (SInt64)totalClientFrames
{
    SInt64 totalFrames = [self totalFrames];
    AudioStreamBasicDescription clientFormat = self.info->clientFormat;
    AudioStreamBasicDescription fileFormat = self.info->fileFormat;
    BOOL sameSampleRate = clientFormat.mSampleRate == fileFormat.mSampleRate;
    if (!sameSampleRate)
    {
        totalFrames = self.info->duration * clientFormat.mSampleRate;
    }
    return totalFrames;
}

//------------------------------------------------------------------------------

- (SInt64)totalFrames
{
    return self.info->frames;
}

//------------------------------------------------------------------------------

- (NSURL *)url
{
  return (__bridge NSURL*)self.info->sourceURL;
}

//------------------------------------------------------------------------------

- (AudioFileID)audioFileID
{
    return self.info->audioFileID;
}

//------------------------------------------------------------------------------
#pragma mark - Setters
//------------------------------------------------------------------------------

- (void)setClientFormat:(AudioStreamBasicDescription)clientFormat
{
    //
    // Clear any float data currently cached
    //
    if (self.floatData)
    {
        self.floatData = nil;
    }

    //
    // Client format can only be linear PCM!
    //
    NSAssert([EZAudioUtilities isLinearPCM:clientFormat], @"Client format must be linear PCM");

    //
    // Store the client format
    //
    self.info->clientFormat = clientFormat;

    //
    // Set the client format on the ExtAudioFileRef
    //
    [EZAudioUtilities checkResult:ExtAudioFileSetProperty(self.info->extAudioFileRef,
                                                          kExtAudioFileProperty_ClientDataFormat,
                                                          sizeof(clientFormat),
                                                          &clientFormat)
                        operation:"Couldn't set client data format on file"];

    //
    // Create a new float converter using the client format as the input format
    //
    self.floatConverter = [EZAudioFloatConverter converterWithInputFormat:clientFormat];

    //
    // Determine how big our float buffers need to be to hold a buffer of float
    // data for the audio received callback.
    //
    UInt32 maxPacketSize;
    UInt32 propSize = sizeof(maxPacketSize);
    [EZAudioUtilities checkResult:ExtAudioFileGetProperty(self.info->extAudioFileRef,
                                                          kExtAudioFileProperty_ClientMaxPacketSize,
                                                          &propSize,
                                                          &maxPacketSize)
                        operation:"Failed to get max packet size"];

    self.floatData = [EZAudioUtilities floatBuffersWithNumberOfFrames:1024
                                                     numberOfChannels:self.clientFormat.mChannelsPerFrame];
}

//------------------------------------------------------------------------------

- (void)setCurrentTime:(NSTimeInterval)currentTime
{
    NSAssert(currentTime < [self duration], @"Invalid seek operation, expected current time to be less than duration");
    SInt64 frame = [EZAudioUtilities MAP:currentTime
                                 leftMin:0.0f
                                 leftMax:[self duration]
                                rightMin:0.0f
                                rightMax:[self totalFrames]];
    [self seekToFrame:frame];
}

//------------------------------------------------------------------------------

/// add an Array of EZAudioFileMarkers into this file
- (void) setMarkers:(NSArray *)markerArray {

    AudioFileMarkerList editedMarkerList[markerArray.count];

    editedMarkerList->mNumberMarkers = (UInt32)markerArray.count;

    for (int i=0; i < markerArray.count; i++) {
        EZAudioFileMarker *ezafm = (EZAudioFileMarker *) [markerArray objectAtIndex:(i)];

        AudioFileMarker afm;
        afm.mName = (__bridge CFStringRef _Nullable)(ezafm.name);
        afm.mFramePosition = [ezafm.framePosition doubleValue];
        afm.mMarkerID = [ezafm.markerID intValue];
        afm.mType = [ezafm.type intValue];

        editedMarkerList->mMarkers[i] = afm;

        NSLog(@"Adding marker: %@\n", ezafm.name );
    }

    UInt32 propSize = (UInt32)NumAudioFileMarkersToNumBytes(markerArray.count);

    OSStatus err = noErr;
    AudioFileID fileID  = nil;

    err = AudioFileOpenURL( (__bridge CFURLRef _Nonnull)(self.url), kAudioFileReadWritePermission, 0, &fileID );

    if ( err != noErr ) {
        NSLog( @"AudioFileOpenURL failed" );
        return;
    }

    err = AudioFileSetProperty( fileID,
                               kAudioFilePropertyMarkerList,
                               propSize,
                               &editedMarkerList);

    if ( err != noErr ) {
        NSLog(@"AudioFileSetProperty failed err: %d\n", (int)err );
    }

}

//------------------------------------------------------------------------------
#pragma mark - Description
//------------------------------------------------------------------------------

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ {\n"
                                       "    url: %@,\n"
                                       "    duration: %f,\n"
                                       "    totalFrames: %lld,\n"
                                       "    metadata: %@,\n"
                                       "    fileFormat: { %@ },\n"
                                       "    clientFormat: { %@ } \n"
                                       "}",
            [super description],
            [self url],
            [self duration],
            [self totalFrames],
            [self metadata],
            [EZAudioUtilities stringForAudioStreamBasicDescription:[self fileFormat]],
            [EZAudioUtilities stringForAudioStreamBasicDescription:[self clientFormat]]];
}

//------------------------------------------------------------------------------

@end
