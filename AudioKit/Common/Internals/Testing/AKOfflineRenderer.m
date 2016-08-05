//
//  AKOfflineRenderer.m
//  AudioKit for iOS
//
//  Created by Aurelius Prochazka on 8/4/16.
//  Copyright © 2016 AudioKit. All rights reserved.
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
    AVAudioOutputNode *outputNode = self.engine.outputNode;
    AudioStreamBasicDescription const *audioDescription = [outputNode outputFormatForBus:0].streamDescription;
    NSUInteger lengthInFrames = (NSUInteger)samples;
    const NSUInteger kBufferLength = 3756;
    AudioBufferList *bufferList = AEAllocateAndInitAudioBufferList(*audioDescription, kBufferLength);
    AudioTimeStamp timeStamp;
    memset (&timeStamp, 0, sizeof(timeStamp));
    timeStamp.mFlags = kAudioTimeStampSampleTimeValid;
    OSStatus status = noErr;
    for (NSUInteger i = kBufferLength; i < lengthInFrames; i += kBufferLength) {
        status = [self renderToBufferList:bufferList bufferLength:kBufferLength timeStamp:&timeStamp];
        if (status != noErr)
            break;
    }
    if (status == noErr && timeStamp.mSampleTime < lengthInFrames) {
        NSUInteger restBufferLength = (NSUInteger) (lengthInFrames - timeStamp.mSampleTime);
        AudioBufferList *restBufferList = AEAllocateAndInitAudioBufferList(*audioDescription, (int)restBufferLength);
        status = [self renderToBufferList:restBufferList bufferLength:restBufferLength timeStamp:&timeStamp];
        AEFreeAudioBufferList(restBufferList);
    }
}

- (OSStatus)renderToBufferList:(AudioBufferList *)bufferList
bufferLength:(NSUInteger)bufferLength
timeStamp:(AudioTimeStamp *)timeStamp {
    [self clearBufferList:bufferList];
    AudioUnit outputUnit = self.engine.outputNode.audioUnit;
    OSStatus status = AudioUnitRender(outputUnit, 0, timeStamp, 0, (int)bufferLength, bufferList);
    if (status != noErr) {
        NSLog(@"Can not render audio unit");
        return status;
    }
    timeStamp->mSampleTime += bufferLength;
    return status;
}

- (void)clearBufferList:(AudioBufferList *)bufferList {
    for (int bufferIndex = 0; bufferIndex < bufferList->mNumberBuffers; bufferIndex++) {
        memset(bufferList->mBuffers[bufferIndex].mData, 0, bufferList->mBuffers[bufferIndex].mDataByteSize);
    }
}

AudioBufferList *AEAllocateAndInitAudioBufferList(AudioStreamBasicDescription audioFormat, int frameCount) {
    int numberOfBuffers = audioFormat.mFormatFlags & kAudioFormatFlagIsNonInterleaved ? audioFormat.mChannelsPerFrame : 1;
    int channelsPerBuffer = audioFormat.mFormatFlags & kAudioFormatFlagIsNonInterleaved ? 1 : audioFormat.mChannelsPerFrame;
    int bytesPerBuffer = audioFormat.mBytesPerFrame * frameCount;
    AudioBufferList *audio = malloc(sizeof(AudioBufferList) + (numberOfBuffers - 1) * sizeof(AudioBuffer));
    if (!audio) {
        return NULL;
    }
    audio->mNumberBuffers = numberOfBuffers;
    for (int i = 0; i < numberOfBuffers; i++) {
        if (bytesPerBuffer > 0) {
            audio->mBuffers[i].mData = calloc(bytesPerBuffer, 1);
            if (!audio->mBuffers[i].mData) {
                for (int j = 0; j < i; j++) free(audio->mBuffers[j].mData);
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

void AEFreeAudioBufferList(AudioBufferList *bufferList) {
    for (int i = 0; i < bufferList->mNumberBuffers; i++) {
        if (bufferList->mBuffers[i].mData) free(bufferList->mBuffers[i].mData);
    }
    free(bufferList);
}

@end
