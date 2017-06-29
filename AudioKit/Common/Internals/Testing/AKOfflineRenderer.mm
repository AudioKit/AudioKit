//
//  AKOfflineRenderer.m
//  AudioKit
//
//  Lifted from The Amazing Audio Engine by Michael Tyson.
//  https://github.com/TheAmazingAudioEngine/TheAmazingAudioEngine
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import "AKOfflineRenderer.h"

@implementation AKOfflineRenderer

- (instancetype)initWithEngine:(AVAudioEngine *)injun {
    self.engine = injun;
    return self;
}

- (void)render:(int)samples {
    [self render:samples andOutputUnit:self.engine.outputNode.audioUnit];
}

- (void)render:(int)samples andOutputUnit:(AudioUnit)outputUnit {
    AVAudioOutputNode *outputNode = self.engine.outputNode;
    AudioStreamBasicDescription const *audioDescription = [outputNode outputFormatForBus:0].streamDescription;
    NSUInteger lengthInFrames = (NSUInteger)samples;
    const NSUInteger kBufferLength = 512;
    AudioBufferList *bufferList = myCreateAudioBufferList(*audioDescription, kBufferLength);
    AudioTimeStamp timeStamp;
    memset (&timeStamp, 0, sizeof(timeStamp));
    timeStamp.mFlags = kAudioTimeStampSampleTimeValid;
    OSStatus status = noErr;
    
    for (NSUInteger i = kBufferLength; i < lengthInFrames; i += kBufferLength) {
        status = [self renderToBufferList:bufferList bufferLength:kBufferLength timeStamp:&timeStamp andOutputUnit:outputUnit];
        if (status != noErr)
            break;
    }
    
    if (status == noErr && timeStamp.mSampleTime < lengthInFrames) {
        NSUInteger restBufferLength = (NSUInteger) (lengthInFrames - timeStamp.mSampleTime);
        
        AudioBufferList *restBufferList = AEAudioBufferListCreate(*audioDescription, (int)restBufferLength);
        status = [self renderToBufferList:restBufferList bufferLength:restBufferLength timeStamp:&timeStamp andOutputUnit:outputUnit];
        AEAudioBufferListFree(restBufferList);
    }
    
    printf("\n\n");
}

- (OSStatus)renderToBufferList:(AudioBufferList *)bufferList
                  bufferLength:(NSUInteger)bufferLength
                     timeStamp:(AudioTimeStamp *)timeStamp andOutputUnit:(AudioUnit)outputUnit {
    [self clearBufferList:bufferList];
    
    /* DEBUG - set all values to 0.2, to determine whether audio unit render
     // is maintaining values or overwriting them
     for(int32_t b = 0; b < 1; b++) {
     AudioBuffer* buffer = bufferList->mBuffers + b;
     
     //printf("\nData byte size: %d", buffer->mDataByteSize);
     
     int32_t floatSize = buffer->mDataByteSize / sizeof(Float32);
     
     for(int32_t i = 0; i < floatSize; i++) {
     Float32* valuePointer = (Float32*)buffer->mData + i;
     *valuePointer = 0.2f;
     printf("\nIN: %d %d - Value: %f   Pointer: %p", b, i, *valuePointer, valuePointer);
     }
     }
     */
    
    OSStatus status = AudioUnitRender(outputUnit, 0, timeStamp, 0, (int)bufferLength, bufferList); // This is setting all values in the buffer to zero
    if (status != noErr) {
        NSLog(@"Can not render audio unit %d", (int)status);
        return status;
    }
    
    /* LOG BUFFER LIST */
    //    for(int32_t b = 0; b < bufferList->mNumberBuffers; b++) {
    //        AudioBuffer* buffer = bufferList->mBuffers + b;
    //
    //        printf("\nData byte size: %d", buffer->mDataByteSize);
    //
    //        int32_t floatSize = buffer->mDataByteSize / sizeof(Float32);
    //
    //        for(int32_t i = 0; i < floatSize; i++) {
    //            Float32* valuePointer = (Float32*)buffer->mData + i;
    //            printf("\nIN: %d %d - Value: %f   Pointer: %p", b, i, *valuePointer, valuePointer);
    //        }
    //    }
    /* LOG BUFFER LIST */
    
    timeStamp->mSampleTime += bufferLength;
    return status;
}

- (void)clearBufferList:(AudioBufferList *)bufferList {
    for (int bufferIndex = 0; bufferIndex < bufferList->mNumberBuffers; bufferIndex++) {
        memset(bufferList->mBuffers[bufferIndex].mData, 0, bufferList->mBuffers[bufferIndex].mDataByteSize);
    }
}

AudioBufferList *myCreateAudioBufferList(AudioStreamBasicDescription audioFormat, int frameCount) {
    int numberOfBuffers = audioFormat.mFormatFlags & kAudioFormatFlagIsNonInterleaved ? audioFormat.mChannelsPerFrame : 1;
    int channelsPerBuffer = audioFormat.mFormatFlags & kAudioFormatFlagIsNonInterleaved ? 1 : audioFormat.mChannelsPerFrame;
    int bytesPerBuffer = audioFormat.mBytesPerFrame * frameCount;
    
    AudioBufferList *audio = reinterpret_cast<AudioBufferList*>(new Byte[offsetof(AudioBufferList, mBuffers) + (numberOfBuffers * sizeof (AudioBuffer))]);
    if ( !audio ) {
        return NULL;
    }
    
    audio->mNumberBuffers = numberOfBuffers;
    
    for ( int i=0; i<numberOfBuffers; i++ ) {
        if ( bytesPerBuffer > 0 ) {
            audio->mBuffers[i].mData = calloc(bytesPerBuffer, 1);
            if ( !audio->mBuffers[i].mData ) {
                for ( int j=0; j<i; j++ ) free(audio->mBuffers[j].mData);
                free(audio);
                return NULL;
            }
        } else {
            audio->mBuffers[i].mData = NULL;
        }
        audio->mBuffers[i].mDataByteSize = bytesPerBuffer;
        audio->mBuffers[i].mNumberChannels = channelsPerBuffer;
    }
    
    return audio;
}

AudioBufferList *AEAudioBufferListCreate(AudioStreamBasicDescription audioFormat, int frameCount) {
    int numberOfBuffers = audioFormat.mFormatFlags & kAudioFormatFlagIsNonInterleaved ? audioFormat.mChannelsPerFrame : 1;
    int channelsPerBuffer = audioFormat.mFormatFlags & kAudioFormatFlagIsNonInterleaved ? 1 : audioFormat.mChannelsPerFrame;
    int bytesPerBuffer = audioFormat.mBytesPerFrame * frameCount;
    
    AudioBufferList *audio = (AudioBufferList*)malloc(sizeof(AudioBufferList) + (numberOfBuffers-1)*sizeof(AudioBuffer));
    if ( !audio ) {
        return NULL;
    }
    audio->mNumberBuffers = numberOfBuffers;
    for ( int i=0; i<numberOfBuffers; i++ ) {
        if ( bytesPerBuffer > 0 ) {
            audio->mBuffers[i].mData = calloc(bytesPerBuffer, 1);
            if ( !audio->mBuffers[i].mData ) {
                for ( int j=0; j<i; j++ ) free(audio->mBuffers[j].mData);
                free(audio);
                return NULL;
            }
        } else {
            audio->mBuffers[i].mData = NULL;
        }
        audio->mBuffers[i].mDataByteSize = bytesPerBuffer;
        audio->mBuffers[i].mNumberChannels = channelsPerBuffer;
    }
    return audio;
}
void AEAudioBufferListFree(AudioBufferList *bufferList ) {
    for ( int i=0; i<bufferList->mNumberBuffers; i++ ) {
        if ( bufferList->mBuffers[i].mData ) free(bufferList->mBuffers[i].mData);
    }
    free(bufferList);
}

@end
