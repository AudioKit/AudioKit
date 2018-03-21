//
//  EZAudioFloatConverter.m
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

#import "EZAudioFloatConverter.h"
#import "EZAudioUtilities.h"

//------------------------------------------------------------------------------
#pragma mark - Constants
//------------------------------------------------------------------------------

static UInt32 EZAudioFloatConverterDefaultOutputBufferSize = 128 * 32;
UInt32 const EZAudioFloatConverterDefaultPacketSize = 2048;

//------------------------------------------------------------------------------
#pragma mark - Data Structures
//------------------------------------------------------------------------------

typedef struct
{
    AudioConverterRef             converterRef;
    AudioBufferList              *floatAudioBufferList;
    AudioStreamBasicDescription   inputFormat;
    AudioStreamBasicDescription   outputFormat;
    AudioStreamPacketDescription *packetDescriptions;
    UInt32 packetsPerBuffer;
} EZAudioFloatConverterInfo;

//------------------------------------------------------------------------------
#pragma mark - Callbacks
//------------------------------------------------------------------------------

OSStatus EZAudioFloatConverterCallback(AudioConverterRef             inAudioConverter,
                                       UInt32                       *ioNumberDataPackets,
                                       AudioBufferList              *ioData,
                                       AudioStreamPacketDescription **outDataPacketDescription,
                                       void                         *inUserData)
{
    AudioBufferList *sourceBuffer = (AudioBufferList *)inUserData;
    
    memcpy(ioData,
           sourceBuffer,
           sizeof(AudioBufferList) + (sourceBuffer->mNumberBuffers - 1) * sizeof(AudioBuffer));
    sourceBuffer = NULL;
    
    return noErr;
}

//------------------------------------------------------------------------------
#pragma mark - EZAudioFloatConverter (Interface Extension)
//------------------------------------------------------------------------------

@interface EZAudioFloatConverter ()
@property (nonatomic, assign) EZAudioFloatConverterInfo *info;
@end

//------------------------------------------------------------------------------
#pragma mark - EZAudioFloatConverter (Implementation)
//------------------------------------------------------------------------------

@implementation EZAudioFloatConverter

//------------------------------------------------------------------------------
#pragma mark - Class Methods
//------------------------------------------------------------------------------

+ (instancetype)converterWithInputFormat:(AudioStreamBasicDescription)inputFormat
{
    return [[self alloc] initWithInputFormat:inputFormat];
}

//------------------------------------------------------------------------------
#pragma mark - Dealloc
//------------------------------------------------------------------------------

- (void)dealloc
{
    AudioConverterDispose(self.info->converterRef);
    [EZAudioUtilities freeBufferList:self.info->floatAudioBufferList];
    free(self.info->packetDescriptions);
    free(self.info);
}

//------------------------------------------------------------------------------
#pragma mark - Initialization
//------------------------------------------------------------------------------

- (instancetype)initWithInputFormat:(AudioStreamBasicDescription)inputFormat
{
    self = [super init];
    if (self)
    {
        self.info = (EZAudioFloatConverterInfo *)malloc(sizeof(EZAudioFloatConverterInfo));
        memset(self.info, 0, sizeof(EZAudioFloatConverterInfo));
        self.info->inputFormat = inputFormat;
        [self setup];
    }
    return self;
}

//------------------------------------------------------------------------------
#pragma mark - Setup
//------------------------------------------------------------------------------

- (void)setup
{
    // create output format
    self.info->outputFormat = [EZAudioUtilities floatFormatWithNumberOfChannels:self.info->inputFormat.mChannelsPerFrame
                                                                     sampleRate:self.info->inputFormat.mSampleRate];
    
    // create a new instance of the audio converter
    [EZAudioUtilities checkResult:AudioConverterNew(&self.info->inputFormat,
                                                    &self.info->outputFormat,
                                                    &self.info->converterRef)
                        operation:"Failed to create new audio converter"];
    
    // get max packets per buffer so you can allocate a proper AudioBufferList
    UInt32 packetsPerBuffer = 0;
    UInt32 outputBufferSize = EZAudioFloatConverterDefaultOutputBufferSize;
    UInt32 sizePerPacket = self.info->inputFormat.mBytesPerPacket;
    BOOL isVBR = sizePerPacket == 0;
    
    // VBR
    if (isVBR)
    {
        // determine the max output buffer size
        UInt32 maxOutputPacketSize;
        UInt32 propSize = sizeof(maxOutputPacketSize);
        OSStatus result = AudioConverterGetProperty(self.info->converterRef,
                                                    kAudioConverterPropertyMaximumOutputPacketSize,
                                                    &propSize,
                                                    &maxOutputPacketSize);
        if (result != noErr)
        {
            maxOutputPacketSize = EZAudioFloatConverterDefaultPacketSize;
        }
        
        // set the output buffer size to at least the max output size
        if (maxOutputPacketSize > outputBufferSize)
        {
            outputBufferSize = maxOutputPacketSize;
        }
        packetsPerBuffer = outputBufferSize / maxOutputPacketSize;
        
        // allocate memory for the packet descriptions
        self.info->packetDescriptions = (AudioStreamPacketDescription *)malloc(sizeof(AudioStreamPacketDescription) * packetsPerBuffer);
    }
    else
    {
        packetsPerBuffer = outputBufferSize / sizePerPacket;
    }
    self.info->packetsPerBuffer = packetsPerBuffer;
    
    // allocate the AudioBufferList to hold the float values
    BOOL isInterleaved = [EZAudioUtilities isInterleaved:self.info->outputFormat];
    self.info->floatAudioBufferList = [EZAudioUtilities audioBufferListWithNumberOfFrames:packetsPerBuffer
                                                                         numberOfChannels:self.info->outputFormat.mChannelsPerFrame
                                                                              interleaved:isInterleaved];
}

//------------------------------------------------------------------------------
#pragma mark - Events
//------------------------------------------------------------------------------

- (void)convertDataFromAudioBufferList:(AudioBufferList *)audioBufferList
                    withNumberOfFrames:(UInt32)frames
                        toFloatBuffers:(float **)buffers
{
    [self convertDataFromAudioBufferList:audioBufferList
                      withNumberOfFrames:frames
                          toFloatBuffers:buffers
                      packetDescriptions:self.info->packetDescriptions];
}

//------------------------------------------------------------------------------

- (void)convertDataFromAudioBufferList:(AudioBufferList *)audioBufferList
                    withNumberOfFrames:(UInt32)frames
                        toFloatBuffers:(float **)buffers
                    packetDescriptions:(AudioStreamPacketDescription *)packetDescriptions
{
    if (frames != 0)
    {
        //
        // Make sure the data size coming in is consistent with the number
        // of frames we're actually getting
        //
        for (int i = 0; i < audioBufferList->mNumberBuffers; i++) {
            audioBufferList->mBuffers[i].mDataByteSize = frames * self.info->inputFormat.mBytesPerFrame;
        }
        
        //
        // Fill out the audio converter with the source buffer
        //
        [EZAudioUtilities checkResult:AudioConverterFillComplexBuffer(self.info->converterRef,
                                                                      EZAudioFloatConverterCallback,
                                                                      audioBufferList,
                                                                      &frames,
                                                                      self.info->floatAudioBufferList,
                                                                      packetDescriptions ? packetDescriptions : self.info->packetDescriptions)
                            operation:"Failed to fill complex buffer in float converter"];
        
        //
        // Copy the converted buffers into the float buffer array stored
        // in memory
        //
        for (int i = 0; i < self.info->floatAudioBufferList->mNumberBuffers; i++)
        {
            memcpy(buffers[i],
                   self.info->floatAudioBufferList->mBuffers[i].mData,
                   self.info->floatAudioBufferList->mBuffers[i].mDataByteSize);
        }
    }
}

//------------------------------------------------------------------------------

@end