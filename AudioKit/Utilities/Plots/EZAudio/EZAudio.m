//
//  EZAudio.m
//  EZAudio
//
//  Created by Syed Haris Ali on 11/21/13.
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

#import "EZAudio.h"

@implementation EZAudio

#pragma mark - AudioBufferList Utility
+(AudioBufferList *)audioBufferListWithNumberOfFrames:(UInt32)frames
                                     numberOfChannels:(UInt32)channels
                                          interleaved:(BOOL)interleaved
{
    AudioBufferList *audioBufferList = (AudioBufferList*)malloc(sizeof(AudioBufferList));
    UInt32 outputBufferSize = 32 * frames; // 32 KB
    audioBufferList->mNumberBuffers = interleaved ? 1 : channels;
    for( int i = 0; i < audioBufferList->mNumberBuffers; i++ )
    {
        audioBufferList->mBuffers[i].mNumberChannels = channels;
        audioBufferList->mBuffers[i].mDataByteSize = channels * outputBufferSize;
        audioBufferList->mBuffers[i].mData = (float*)malloc(channels * sizeof(float) *outputBufferSize);
    }
    return audioBufferList;
}

+(void)freeBufferList:(AudioBufferList *)bufferList
{
    if( bufferList )
    {
        if( bufferList->mNumberBuffers )
        {
            for( int i = 0; i < bufferList->mNumberBuffers; i++ )
            {
                if( bufferList->mBuffers[i].mData )
                {
                    free(bufferList->mBuffers[i].mData);
                }
            }
        }
        free(bufferList);
    }
    bufferList = NULL;
}

#pragma mark - AudioStreamBasicDescription Utility
+(AudioStreamBasicDescription)AIFFFormatWithNumberOfChannels:(UInt32)channels
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

+(AudioStreamBasicDescription)iLBCFormatWithSampleRate:(float)sampleRate
{
    AudioStreamBasicDescription asbd;
    memset(&asbd, 0, sizeof(asbd));
    asbd.mFormatID          = kAudioFormatiLBC;
    asbd.mChannelsPerFrame  = 1;
    asbd.mSampleRate        = sampleRate;
    
    // Fill in the rest of the descriptions using the Audio Format API
    UInt32 propSize = sizeof(asbd);
    [EZAudio checkResult:AudioFormatGetProperty(kAudioFormatProperty_FormatInfo,
                                                0,
                                                NULL,
                                                &propSize,
                                                &asbd)
               operation:"Failed to fill out the rest of the m4a AudioStreamBasicDescription"];
    
    return asbd;
}

+(AudioStreamBasicDescription)M4AFormatWithNumberOfChannels:(UInt32)channels
                                                 sampleRate:(float)sampleRate
{
    AudioStreamBasicDescription asbd;
    memset(&asbd, 0, sizeof(asbd));
    asbd.mFormatID          = kAudioFormatMPEG4AAC;
    asbd.mChannelsPerFrame  = channels;
    asbd.mSampleRate        = sampleRate;
    
    // Fill in the rest of the descriptions using the Audio Format API
    UInt32 propSize = sizeof(asbd);
    [EZAudio checkResult:AudioFormatGetProperty(kAudioFormatProperty_FormatInfo,
                                                0,
                                                NULL,
                                                &propSize,
                                                &asbd)
               operation:"Failed to fill out the rest of the m4a AudioStreamBasicDescription"];
    
    return asbd;
}

+(AudioStreamBasicDescription)monoFloatFormatWithSampleRate:(float)sampleRate
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

+(AudioStreamBasicDescription)monoCanonicalFormatWithSampleRate:(float)sampleRate
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

+(AudioStreamBasicDescription)stereoCanonicalNonInterleavedFormatWithSampleRate:(float)sampleRate
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

+(AudioStreamBasicDescription)stereoFloatInterleavedFormatWithSampleRate:(float)sampleRate
{
    AudioStreamBasicDescription asbd;
    UInt32 floatByteSize   = sizeof(float);
    asbd.mChannelsPerFrame = 2;
    asbd.mBitsPerChannel   = 8 * floatByteSize;
    asbd.mBytesPerFrame    = asbd.mChannelsPerFrame * floatByteSize;
    asbd.mBytesPerPacket   = asbd.mChannelsPerFrame * floatByteSize;
    asbd.mFormatFlags      = kAudioFormatFlagIsPacked|kAudioFormatFlagIsFloat;
    asbd.mFormatID         = kAudioFormatLinearPCM;
    asbd.mFramesPerPacket  = 1;
    asbd.mSampleRate       = sampleRate;
    return asbd;
}

+(AudioStreamBasicDescription)stereoFloatNonInterleavedFormatWithSampleRate:(float)sampleRate
{
    AudioStreamBasicDescription asbd;
    UInt32 floatByteSize   = sizeof(float);
    asbd.mBitsPerChannel   = 8 * floatByteSize;
    asbd.mBytesPerFrame    = floatByteSize;
    asbd.mBytesPerPacket   = floatByteSize;
    asbd.mChannelsPerFrame = 2;
    asbd.mFormatFlags      = kAudioFormatFlagIsFloat|kAudioFormatFlagIsNonInterleaved;
    asbd.mFormatID         = kAudioFormatLinearPCM;
    asbd.mFramesPerPacket  = 1;
    asbd.mSampleRate       = sampleRate;
    return asbd;
}

+(void)printASBD:(AudioStreamBasicDescription)asbd {
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

+(void)setCanonicalAudioStreamBasicDescription:(AudioStreamBasicDescription*)asbd
                              numberOfChannels:(UInt32)nChannels
                                   interleaved:(BOOL)interleaved {
    
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

#pragma mark - OSStatus Utility
+(void)checkResult:(OSStatus)result
         operation:(const char *)operation {
	if (result == noErr) return;
	char errorString[20];
	// see if it appears to be a 4-char-code
	*(UInt32 *)(errorString + 1) = CFSwapInt32HostToBig(result);
	if (isprint(errorString[1]) && isprint(errorString[2]) && isprint(errorString[3]) && isprint(errorString[4])) {
		errorString[0] = errorString[5] = '\'';
		errorString[6] = '\0';
	} else
		// no, format it as an integer
		sprintf(errorString, "%d", (int)result);
	fprintf(stderr, "Error: %s (%s)\n", operation, errorString);
	exit(1);
}

#pragma mark - Math Utility
+(void)appendBufferAndShift:(float*)buffer
             withBufferSize:(int)bufferLength
            toScrollHistory:(float*)scrollHistory
      withScrollHistorySize:(int)scrollHistoryLength {
    NSAssert(scrollHistoryLength>=bufferLength,@"Scroll history array length must be greater buffer length");
    NSAssert(scrollHistoryLength>0,@"Scroll history array length must be greater than 0");
    NSAssert(bufferLength>0,@"Buffer array length must be greater than 0");
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

+(void)    appendValue:(float)value
       toScrollHistory:(float*)scrollHistory
 withScrollHistorySize:(int)scrollHistoryLength {
    float val[1]; val[0] = value;
    [self appendBufferAndShift:val
                withBufferSize:1
               toScrollHistory:scrollHistory
         withScrollHistorySize:scrollHistoryLength];
}

+(float)MAP:(float)value
    leftMin:(float)leftMin
    leftMax:(float)leftMax
   rightMin:(float)rightMin
   rightMax:(float)rightMax {
    float leftSpan    = leftMax  - leftMin;
    float rightSpan   = rightMax - rightMin;
    float valueScaled = ( value  - leftMin ) / leftSpan;
    return rightMin + (valueScaled * rightSpan);
}

+(float)RMS:(MYFLT *)buffer
     length:(int)bufferSize {
    float sum = 0.0;
    for(int i = 0; i < bufferSize; i++)
        sum += buffer[i] * buffer[i];
    return sqrtf( sum / bufferSize );
}

+(float)SGN:(float)value
{
    return value < 0 ? -1.0f : ( value > 0 ? 1.0f : 0.0f );
}

#pragma mark - Plot Utility
+(void)updateScrollHistory:(float **)scrollHistory
                withLength:(int)scrollHistoryLength
                   atIndex:(int*)index
                withBuffer:(MYFLT *)buffer
            withBufferSize:(int)bufferSize
      isResolutionChanging:(BOOL*)isChanging {
    
    //
    size_t floatByteSize = sizeof(float);
    
    //
    if( *scrollHistory == NULL ){
        // Create the history buffer
        *scrollHistory = (float*)calloc(kEZAudioPlotMaxHistoryBufferLength,floatByteSize);
    }
    
    //
    if( !*isChanging ){
        float rms = [EZAudio RMS:buffer length:bufferSize];
        if( *index < scrollHistoryLength ){
            float *hist = *scrollHistory;
            hist[*index] = rms;
            (*index)++;
        }
        else {
            [EZAudio appendValue:rms
                 toScrollHistory:*scrollHistory
           withScrollHistorySize:scrollHistoryLength];
        }
    }
    
}

#pragma mark - TPCircularBuffer Utility
+(void)circularBuffer:(TPCircularBuffer *)circularBuffer withSize:(int)size {
    TPCircularBufferInit(circularBuffer,size);
}

+(void)appendDataToCircularBuffer:(TPCircularBuffer*)circularBuffer
              fromAudioBufferList:(AudioBufferList*)audioBufferList {
    TPCircularBufferProduceBytes(circularBuffer,
                                 audioBufferList->mBuffers[0].mData,
                                 audioBufferList->mBuffers[0].mDataByteSize);
}

+(void)freeCircularBuffer:(TPCircularBuffer *)circularBuffer {
    TPCircularBufferClear(circularBuffer);
    TPCircularBufferCleanup(circularBuffer);
}

@end