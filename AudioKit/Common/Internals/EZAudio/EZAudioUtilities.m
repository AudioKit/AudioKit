//
//  EZAudioUtilities.m
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

#import "EZAudioUtilities.h"

static float    const  EZAudioUtilitiesFixedNoteA       = 440.0f;
static int      const  EZAudioUtilitiesFixedNoteAIndex  = 9;
static int      const  EZAudioUtilitiesFixedNoteAOctave = 4;
static float    const  EZAudioUtilitiesEQFrequencyRatio = 1.059463094359f;
static int      const  EZAudioUtilitiesNotesLength      = 12;
static NSString * const EZAudioUtilitiesNotes[EZAudioUtilitiesNotesLength] =
{
    @"C", @"C#",
    @"D", @"D#",
    @"E",
    @"F", @"F#",
    @"G", @"G#",
    @"A", @"A#",
    @"B"
};

BOOL __shouldExitOnCheckResultFail = YES;

@implementation EZAudioUtilities

//------------------------------------------------------------------------------
#pragma mark - Debugging
//------------------------------------------------------------------------------

+ (void)setShouldExitOnCheckResultFail:(BOOL)shouldExitOnCheckResultFail
{
    __shouldExitOnCheckResultFail = shouldExitOnCheckResultFail;
}

//------------------------------------------------------------------------------

+ (BOOL)shouldExitOnCheckResultFail
{
    return __shouldExitOnCheckResultFail;
}

//------------------------------------------------------------------------------
#pragma mark - AudioBufferList Utility
//------------------------------------------------------------------------------

+ (AudioBufferList *)audioBufferListWithNumberOfFrames:(UInt32)frames
                                      numberOfChannels:(UInt32)channels
                                           interleaved:(BOOL)interleaved
{
    unsigned nBuffers;
    unsigned bufferSize;
    unsigned channelsPerBuffer;
    if (interleaved)
    {
        nBuffers = 1;
        bufferSize = sizeof(float) * frames * channels;
        channelsPerBuffer = channels;
    }
    else
    {
        nBuffers = channels;
        bufferSize = sizeof(float) * frames;
        channelsPerBuffer = 1;
    }
    
    AudioBufferList *audioBufferList = (AudioBufferList *)malloc(sizeof(AudioBufferList) + sizeof(AudioBuffer) * (channels-1));
    audioBufferList->mNumberBuffers = nBuffers;
    for(unsigned i = 0; i < nBuffers; i++)
    {
        audioBufferList->mBuffers[i].mNumberChannels = channelsPerBuffer;
        audioBufferList->mBuffers[i].mDataByteSize = bufferSize;
        audioBufferList->mBuffers[i].mData = calloc(bufferSize, 1);
    }
    return audioBufferList;
}

//------------------------------------------------------------------------------

+ (float **)floatBuffersWithNumberOfFrames:(UInt32)frames
                          numberOfChannels:(UInt32)channels
{
    size_t size = sizeof(float *) * channels;
    float **buffers = (float **)malloc(size);
    for (int i = 0; i < channels; i++)
    {
        size = sizeof(float) * frames;
        buffers[i] = (float *)malloc(size);
    }
    return buffers;
}

//------------------------------------------------------------------------------

+ (void)freeBufferList:(AudioBufferList *)bufferList
{
    if (bufferList)
    {
        if (bufferList->mNumberBuffers)
        {
            for( int i = 0; i < bufferList->mNumberBuffers; i++)
            {
                if (bufferList->mBuffers[i].mData)
                {
                    free(bufferList->mBuffers[i].mData);
                }
            }
        }
        free(bufferList);
    }
    bufferList = NULL;
}

//------------------------------------------------------------------------------

+ (void)freeFloatBuffers:(float **)buffers numberOfChannels:(UInt32)channels
{
    if (!buffers || !*buffers)
    {
        return;
    }

    for (int i = 0; i < channels; i++)
    {
        free(buffers[i]);
    }
    free(buffers);
}

//------------------------------------------------------------------------------
#pragma mark - AudioStreamBasicDescription Utility
//------------------------------------------------------------------------------

+ (AudioStreamBasicDescription)AIFFFormatWithNumberOfChannels:(UInt32)channels
                                                   sampleRate:(float)sampleRate
{
    AudioStreamBasicDescription asbd;
    memset(&asbd, 0, sizeof(asbd));
    asbd.mFormatID          = kAudioFormatLinearPCM;
    asbd.mFormatFlags       = kAudioFormatFlagIsBigEndian|kAudioFormatFlagIsPacked|kAudioFormatFlagIsSignedInteger;
    asbd.mSampleRate        = sampleRate;
    asbd.mChannelsPerFrame  = channels;
    asbd.mBitsPerChannel    = 32;
    asbd.mBytesPerPacket    = (asbd.mBitsPerChannel / 8) * asbd.mChannelsPerFrame;
    asbd.mFramesPerPacket   = 1;
    asbd.mBytesPerFrame     = (asbd.mBitsPerChannel / 8) * asbd.mChannelsPerFrame;
    return asbd;
}

//------------------------------------------------------------------------------

+ (AudioStreamBasicDescription)iLBCFormatWithSampleRate:(float)sampleRate
{
    AudioStreamBasicDescription asbd;
    memset(&asbd, 0, sizeof(asbd));
    asbd.mFormatID          = kAudioFormatiLBC;
    asbd.mChannelsPerFrame  = 1;
    asbd.mSampleRate        = sampleRate;
    
    // Fill in the rest of the descriptions using the Audio Format API
    UInt32 propSize = sizeof(asbd);
    [EZAudioUtilities checkResult:AudioFormatGetProperty(kAudioFormatProperty_FormatInfo,
                                                         0,
                                                         NULL,
                                                         &propSize,
                                                         &asbd)
                        operation:"Failed to fill out the rest of the iLBC AudioStreamBasicDescription"];
    
    return asbd;
}

//------------------------------------------------------------------------------

+ (AudioStreamBasicDescription)floatFormatWithNumberOfChannels:(UInt32)channels
                                                    sampleRate:(float)sampleRate
{
    AudioStreamBasicDescription asbd;
    UInt32 floatByteSize   = sizeof(float);
    asbd.mBitsPerChannel   = 8 * floatByteSize;
    asbd.mBytesPerFrame    = floatByteSize;
    asbd.mBytesPerPacket   = floatByteSize;
    asbd.mChannelsPerFrame = channels;
    asbd.mFormatFlags      = kAudioFormatFlagIsFloat|kAudioFormatFlagIsNonInterleaved;
    asbd.mFormatID         = kAudioFormatLinearPCM;
    asbd.mFramesPerPacket  = 1;
    asbd.mSampleRate       = sampleRate;
    return asbd;
}

//------------------------------------------------------------------------------

+ (AudioStreamBasicDescription)M4AFormatWithNumberOfChannels:(UInt32)channels
                                                  sampleRate:(float)sampleRate
{
    AudioStreamBasicDescription asbd;
    memset(&asbd, 0, sizeof(asbd));
    asbd.mFormatID          = kAudioFormatMPEG4AAC;
    asbd.mChannelsPerFrame  = channels;
    asbd.mSampleRate        = sampleRate;
    
    // Fill in the rest of the descriptions using the Audio Format API
    UInt32 propSize = sizeof(asbd);
    [EZAudioUtilities checkResult:AudioFormatGetProperty(kAudioFormatProperty_FormatInfo,
                                                         0,
                                                         NULL,
                                                         &propSize,
                                                         &asbd)
                        operation:"Failed to fill out the rest of the m4a AudioStreamBasicDescription"];
    
    return asbd;
}

//------------------------------------------------------------------------------

+ (AudioStreamBasicDescription)monoFloatFormatWithSampleRate:(float)sampleRate
{
    AudioStreamBasicDescription asbd;
    UInt32 byteSize = sizeof(float);
    asbd.mBitsPerChannel   = 8 * byteSize;
    asbd.mBytesPerFrame    = byteSize;
    asbd.mBytesPerPacket   = byteSize;
    asbd.mChannelsPerFrame = 1;
    asbd.mFormatFlags      = kAudioFormatFlagIsPacked|kAudioFormatFlagIsFloat;
    asbd.mFormatID         = kAudioFormatLinearPCM;
    asbd.mFramesPerPacket  = 1;
    asbd.mSampleRate       = sampleRate;
    return asbd;
}

//------------------------------------------------------------------------------

+ (AudioStreamBasicDescription)monoCanonicalFormatWithSampleRate:(float)sampleRate
{
    AudioStreamBasicDescription asbd;
    UInt32 byteSize = sizeof(float);
    asbd.mBitsPerChannel   = 8 * byteSize;
    asbd.mBytesPerFrame    = byteSize;
    asbd.mBytesPerPacket   = byteSize;
    asbd.mChannelsPerFrame = 1;
    asbd.mFormatFlags      = kAudioFormatFlagsNativeFloatPacked|kAudioFormatFlagIsNonInterleaved;
    asbd.mFormatID         = kAudioFormatLinearPCM;
    asbd.mFramesPerPacket  = 1;
    asbd.mSampleRate       = sampleRate;
    return asbd;
}

//------------------------------------------------------------------------------

+ (AudioStreamBasicDescription)stereoCanonicalNonInterleavedFormatWithSampleRate:(float)sampleRate
{
    AudioStreamBasicDescription asbd;
    UInt32 byteSize = sizeof(float);
    asbd.mBitsPerChannel   = 8 * byteSize;
    asbd.mBytesPerFrame    = byteSize;
    asbd.mBytesPerPacket   = byteSize;
    asbd.mChannelsPerFrame = 2;
    asbd.mFormatFlags      = kAudioFormatFlagsNativeFloatPacked|kAudioFormatFlagIsNonInterleaved;
    asbd.mFormatID         = kAudioFormatLinearPCM;
    asbd.mFramesPerPacket  = 1;
    asbd.mSampleRate       = sampleRate;
    return asbd;
}

//------------------------------------------------------------------------------

+ (AudioStreamBasicDescription)stereoFloatInterleavedFormatWithSampleRate:(float)sampleRate
{
    AudioStreamBasicDescription asbd;
    UInt32 floatByteSize   = sizeof(float);
    asbd.mChannelsPerFrame = 2;
    asbd.mBitsPerChannel   = 8 * floatByteSize;
    asbd.mBytesPerFrame    = asbd.mChannelsPerFrame * floatByteSize;
    asbd.mFramesPerPacket  = 1;
    asbd.mBytesPerPacket   = asbd.mFramesPerPacket * asbd.mBytesPerFrame;
    asbd.mFormatFlags      = kAudioFormatFlagIsFloat;
    asbd.mFormatID         = kAudioFormatLinearPCM;
    asbd.mSampleRate       = sampleRate;
    asbd.mReserved         = 0;
    return asbd;
}

//------------------------------------------------------------------------------

+ (AudioStreamBasicDescription)stereoFloatNonInterleavedFormatWithSampleRate:(float)sampleRate
{
    AudioStreamBasicDescription asbd;
    UInt32 floatByteSize   = sizeof(float);
    asbd.mBitsPerChannel   = 8 * floatByteSize;
    asbd.mBytesPerFrame    = floatByteSize;
    asbd.mChannelsPerFrame = 2;
    asbd.mFormatFlags      = kAudioFormatFlagIsFloat|kAudioFormatFlagIsNonInterleaved;
    asbd.mFormatID         = kAudioFormatLinearPCM;
    asbd.mFramesPerPacket  = 1;
    asbd.mBytesPerPacket   = asbd.mFramesPerPacket * asbd.mBytesPerFrame;
    asbd.mSampleRate       = sampleRate;
    return asbd;
}

//------------------------------------------------------------------------------

+ (BOOL)isFloatFormat:(AudioStreamBasicDescription)asbd
{
    return asbd.mFormatFlags & kAudioFormatFlagIsFloat;
}

//------------------------------------------------------------------------------

+ (BOOL)isInterleaved:(AudioStreamBasicDescription)asbd
{
    return !(asbd.mFormatFlags & kAudioFormatFlagIsNonInterleaved);
}

//------------------------------------------------------------------------------

+ (BOOL)isLinearPCM:(AudioStreamBasicDescription)asbd
{
    return asbd.mFormatID == kAudioFormatLinearPCM;
}

//------------------------------------------------------------------------------

+ (void)printASBD:(AudioStreamBasicDescription)asbd
{
    char formatIDString[5];
    UInt32 formatID = CFSwapInt32HostToBig(asbd.mFormatID);
    bcopy (&formatID, formatIDString, 4);
    formatIDString[4] = '\0';
    NSLog (@"  Sample Rate:         %10.0f",  asbd.mSampleRate);
    NSLog (@"  Format ID:           %10s",    formatIDString);
    NSLog (@"  Format Flags:        %10X",    (unsigned int)asbd.mFormatFlags);
    NSLog (@"  Bytes per Packet:    %10d",    (unsigned int)asbd.mBytesPerPacket);
    NSLog (@"  Frames per Packet:   %10d",    (unsigned int)asbd.mFramesPerPacket);
    NSLog (@"  Bytes per Frame:     %10d",    (unsigned int)asbd.mBytesPerFrame);
    NSLog (@"  Channels per Frame:  %10d",    (unsigned int)asbd.mChannelsPerFrame);
    NSLog (@"  Bits per Channel:    %10d",    (unsigned int)asbd.mBitsPerChannel);
}

//------------------------------------------------------------------------------

+ (NSString *)displayTimeStringFromSeconds:(NSTimeInterval)seconds
{
    int totalSeconds = (int)ceil(seconds);
    int secondsComponent = totalSeconds % 60;
    int minutesComponent = (totalSeconds / 60) % 60;
    return [NSString stringWithFormat:@"%02d:%02d", minutesComponent, secondsComponent];
}

//------------------------------------------------------------------------------

+ (NSString *)stringForAudioStreamBasicDescription:(AudioStreamBasicDescription)asbd
{
    char formatIDString[5];
    UInt32 formatID = CFSwapInt32HostToBig(asbd.mFormatID);
    bcopy (&formatID, formatIDString, 4);
    formatIDString[4] = '\0';
    return [NSString stringWithFormat:
            @"\nSample Rate:       %10.0f,\n"
            @"Format ID:           %10s,\n"
            @"Format Flags:        %10X,\n"
            @"Bytes per Packet:    %10d,\n"
            @"Frames per Packet:   %10d,\n"
            @"Bytes per Frame:     %10d,\n"
            @"Channels per Frame:  %10d,\n"
            @"Bits per Channel:    %10d,\n"
            @"IsInterleaved:       %i,\n"
            @"IsFloat:             %i,",
            asbd.mSampleRate,
            formatIDString,
            (unsigned int)asbd.mFormatFlags,
            (unsigned int)asbd.mBytesPerPacket,
            (unsigned int)asbd.mFramesPerPacket,
            (unsigned int)asbd.mBytesPerFrame,
            (unsigned int)asbd.mChannelsPerFrame,
            (unsigned int)asbd.mBitsPerChannel,
            [self isInterleaved:asbd],
            [self isFloatFormat:asbd]];
}

//------------------------------------------------------------------------------

+ (void)setCanonicalAudioStreamBasicDescription:(AudioStreamBasicDescription*)asbd
                               numberOfChannels:(UInt32)nChannels
                                    interleaved:(BOOL)interleaved
{
    
    asbd->mFormatID = kAudioFormatLinearPCM;
#if TARGET_OS_IPHONE
    int sampleSize = sizeof(float);
    asbd->mFormatFlags = kAudioFormatFlagsNativeFloatPacked;
#elif TARGET_OS_MAC
    int sampleSize = sizeof(Float32);
    asbd->mFormatFlags = kAudioFormatFlagsNativeFloatPacked;
#endif
    asbd->mBitsPerChannel = 8 * sampleSize;
    asbd->mChannelsPerFrame = nChannels;
    asbd->mFramesPerPacket = 1;
    if (interleaved)
        asbd->mBytesPerPacket = asbd->mBytesPerFrame = nChannels * sampleSize;
    else {
        asbd->mBytesPerPacket = asbd->mBytesPerFrame = sampleSize;
        asbd->mFormatFlags |= kAudioFormatFlagIsNonInterleaved;
    }
}

//------------------------------------------------------------------------------
#pragma mark - Math Utilities
//------------------------------------------------------------------------------

+ (void)appendBufferAndShift:(float*)buffer
              withBufferSize:(int)bufferLength
             toScrollHistory:(float*)scrollHistory
       withScrollHistorySize:(int)scrollHistoryLength
{
    int    shiftLength    = scrollHistoryLength - bufferLength;
    size_t floatByteSize  = sizeof(float);
    size_t shiftByteSize  = shiftLength  * floatByteSize;
    size_t bufferByteSize = bufferLength * floatByteSize;
    memmove(&scrollHistory[0],
            &scrollHistory[bufferLength],
            shiftByteSize);
    memmove(&scrollHistory[shiftLength],
            &buffer[0],
            bufferByteSize);
}

//------------------------------------------------------------------------------

+ (void)   appendValue:(float)value
       toScrollHistory:(float*)scrollHistory
 withScrollHistorySize:(int)scrollHistoryLength
{
    float val[1]; val[0] = value;
    [self appendBufferAndShift:val
                withBufferSize:1
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
    float leftSpan    = leftMax  - leftMin;
    float rightSpan   = rightMax - rightMin;
    float valueScaled = ( value  - leftMin) / leftSpan;
    return rightMin + (valueScaled * rightSpan);
}

//------------------------------------------------------------------------------

+ (float)RMS:(float *)buffer   length:(int)bufferSize
{
    float sum = 0.0;
    for(int i = 0; i < bufferSize; i++)
        sum += buffer[i] * buffer[i];
    return sqrtf( sum / bufferSize);
}

//------------------------------------------------------------------------------

+ (float)SGN:(float)value
{
    return value < 0 ? -1.0f : ( value > 0 ? 1.0f : 0.0f);
}

//------------------------------------------------------------------------------
#pragma mark - Music Utilities
//------------------------------------------------------------------------------

+ (NSString *)noteNameStringForFrequency:(float)frequency
                           includeOctave:(BOOL)includeOctave
{
    NSMutableString *noteName = [NSMutableString string];
    int halfStepsFromFixedNote = roundf(log(frequency / EZAudioUtilitiesFixedNoteA) / log(EZAudioUtilitiesEQFrequencyRatio));
    int halfStepsModOctaves = halfStepsFromFixedNote % EZAudioUtilitiesNotesLength;
    int indexOfNote = EZAudioUtilitiesFixedNoteAIndex + halfStepsModOctaves;
    float octaves = halfStepsFromFixedNote / EZAudioUtilitiesNotesLength;
    if (indexOfNote >= EZAudioUtilitiesNotesLength)
    {
        indexOfNote -= EZAudioUtilitiesNotesLength;
        octaves += 1;
    }
    else if (indexOfNote < 0)
    {
        indexOfNote += EZAudioUtilitiesNotesLength;
        octaves = -1;
    }
    [noteName appendString:EZAudioUtilitiesNotes[indexOfNote]];
    if (includeOctave)
    {
        int noteOctave = EZAudioUtilitiesFixedNoteAOctave + octaves;
        [noteName appendFormat:@"%i", noteOctave];
    }
    return noteName;
}

//------------------------------------------------------------------------------
#pragma mark - OSStatus Utility
//------------------------------------------------------------------------------

+ (void)checkResult:(OSStatus)result operation:(const char *)operation
{
    if (result == noErr) return;
    char errorString[20];
    // see if it appears to be a 4-char-code
    *(UInt32 *)(errorString + 1) = CFSwapInt32HostToBig(result);
    if (isprint(errorString[1]) && isprint(errorString[2]) && isprint(errorString[3]) && isprint(errorString[4]))
    {
        errorString[0] = errorString[5] = '\'';
        errorString[6] = '\0';
    } else
        // no, format it as an integer
        sprintf(errorString, "%d", (int)result);
    fprintf(stderr, "Error: %s (%s)\n", operation, errorString);
    if (__shouldExitOnCheckResultFail)
    {
        exit(-1);
    }
}

//------------------------------------------------------------------------------

+ (NSString *)stringFromUInt32Code:(UInt32)code
{
    char errorString[20];
    // see if it appears to be a 4-char-code
    *(UInt32 *)(errorString + 1) = CFSwapInt32HostToBig(code);
    if (isprint(errorString[1]) &&
        isprint(errorString[2]) &&
        isprint(errorString[3]) &&
        isprint(errorString[4]))
    {
        errorString[0] = errorString[5] = '\'';
        errorString[6] = '\0';
    }
    return [NSString stringWithUTF8String:errorString];
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
    //
    size_t floatByteSize = sizeof(float);
    if(*scrollHistory == NULL)
    {
        // Create the history buffer
        *scrollHistory = (float *)calloc(8192, floatByteSize);
    }
    
    //
    if(!*isChanging)
    {
        float rms = [EZAudioUtilities RMS:buffer length:bufferSize];
        if(*index < scrollHistoryLength)
        {
            float *hist = *scrollHistory;
            hist[*index] = rms;
            (*index)++;
        }
        else
        {
            [EZAudioUtilities appendValue:rms
                          toScrollHistory:*scrollHistory
                    withScrollHistorySize:scrollHistoryLength];
        }
    }
}

//------------------------------------------------------------------------------
#pragma mark - Color Utility
//------------------------------------------------------------------------------

///-----------------------------------------------------------
/// @name Color Utility
///-----------------------------------------------------------

+ (void)getColorComponentsFromCGColor:(CGColorRef)color
                                  red:(CGFloat *)red
                                green:(CGFloat *)green
                                 blue:(CGFloat *)blue
                                alpha:(CGFloat *)alpha
{
    size_t componentCount = CGColorGetNumberOfComponents(color);
    if (componentCount == 4)
    {
        const CGFloat *components = CGColorGetComponents(color);
        *red = components[0];
        *green = components[1];
        *blue = components[2];
        *alpha = components[3];
    }
}

//------------------------------------------------------------------------------
#pragma mark - TPCircularBuffer Utility
//------------------------------------------------------------------------------

+ (void)appendDataToCircularBuffer:(TPCircularBuffer *)circularBuffer
               fromAudioBufferList:(AudioBufferList *)audioBufferList
{
    TPCircularBufferProduceBytes(circularBuffer,
                                 audioBufferList->mBuffers[0].mData,
                                 audioBufferList->mBuffers[0].mDataByteSize);
}

//------------------------------------------------------------------------------

+ (void)circularBuffer:(TPCircularBuffer *)circularBuffer withSize:(int)size
{
    TPCircularBufferInit(circularBuffer, size);
}

//------------------------------------------------------------------------------

+ (void)freeCircularBuffer:(TPCircularBuffer *)circularBuffer
{
    TPCircularBufferClear(circularBuffer);
    TPCircularBufferCleanup(circularBuffer);
}

//------------------------------------------------------------------------------
#pragma mark - EZPlotHistoryInfo Utility
//------------------------------------------------------------------------------

+ (void)appendBufferRMS:(float *)buffer
         withBufferSize:(UInt32)bufferSize
          toHistoryInfo:(EZPlotHistoryInfo *)historyInfo
{
    //
    // Calculate RMS and append to buffer
    //
    float rms = [EZAudioUtilities RMS:buffer length:bufferSize];
    float src[1];
    src[0] = isnan(rms) ? 0.0 : rms;
    [self appendBuffer:src withBufferSize:1 toHistoryInfo:historyInfo];
}

//------------------------------------------------------------------------------

+ (void)appendBuffer:(float *)buffer
      withBufferSize:(UInt32)bufferSize
       toHistoryInfo:(EZPlotHistoryInfo *)historyInfo
{
    //
    // Do nothing if there is no buffer
    //
    if (bufferSize == 0)
    {
        return;
    }
    
    //
    // Update the scroll history datasource
    //
    TPCircularBufferProduceBytes(&historyInfo->circularBuffer, buffer, bufferSize * sizeof(float));
    int32_t targetBytes = historyInfo->bufferSize * sizeof(float);
    int32_t availableBytes = 0;
    float *historyBuffer = TPCircularBufferTail(&historyInfo->circularBuffer, &availableBytes);
    int32_t bytes = MIN(targetBytes, availableBytes);
    memmove(historyInfo->buffer, historyBuffer, bytes);
    if (targetBytes <= availableBytes)
    {
        TPCircularBufferConsume(&historyInfo->circularBuffer, availableBytes - targetBytes);
    }
}

//------------------------------------------------------------------------------

+ (void)clearHistoryInfo:(EZPlotHistoryInfo *)historyInfo
{
    memset(historyInfo->buffer, 0, historyInfo->bufferSize * sizeof(float));
    TPCircularBufferClear(&historyInfo->circularBuffer);
}

//------------------------------------------------------------------------------

+ (void)freeHistoryInfo:(EZPlotHistoryInfo *)historyInfo
{
    // This seems to be in the wrong order. It is causing memory errors in sporadic ways.
    //    free(historyInfo->buffer);
    //    free(historyInfo);
    //    TPCircularBufferCleanup(&historyInfo->circularBuffer);
    
    // I believe the order should be:
    
    free(historyInfo->buffer);
    TPCircularBufferCleanup(&historyInfo->circularBuffer);
    free(historyInfo);
}

//------------------------------------------------------------------------------

+ (EZPlotHistoryInfo *)historyInfoWithDefaultLength:(int)defaultLength
                                      maximumLength:(int)maximumLength
{
    //
    // Setup buffers
    //
    EZPlotHistoryInfo *historyInfo = (EZPlotHistoryInfo *)malloc(sizeof(EZPlotHistoryInfo));
    historyInfo->bufferSize = defaultLength;
    historyInfo->buffer = calloc(maximumLength, sizeof(float));
    TPCircularBufferInit(&historyInfo->circularBuffer, maximumLength);
    
    //
    // Zero out circular buffer
    //
    float emptyBuffer[maximumLength];
    memset(emptyBuffer, 0, sizeof(emptyBuffer));
    TPCircularBufferProduceBytes(&historyInfo->circularBuffer,
                                 emptyBuffer,
                                 (int32_t)sizeof(emptyBuffer));
    
    return historyInfo;
}

//------------------------------------------------------------------------------

@end
