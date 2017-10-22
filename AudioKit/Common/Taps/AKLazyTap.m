//
//  AKLazyTap.m
//  AudioKit
//
//  Created by David O'Neill on 8/16/17.
//  Copyright © AudioKit. All rights reserved.
//

#import "AKLazyTap.h"
#import "TPCircularBuffer+AudioBufferList.h"
#import <pthread/pthread.h>


@implementation AKLazyTap{
    AVAudioFormat *format;
    int headRoom;
    TPCircularBuffer circularBuffer;
    pthread_mutex_t consumerLock;
    AKRenderTap *tap;
}

-(instancetype _Nullable)initWithAudioUnit:(AudioUnit)audioUnit queueTime:(double)seconds {
    self = [super init];
    if (self) {
        
        seconds = seconds <= 0 ?: 0.25;
        
        UInt32 propSize = sizeof(AudioStreamBasicDescription);
        AudioStreamBasicDescription asbd;
        OSStatus status = AudioUnitGetProperty(audioUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 0, &asbd, &propSize);
        if (status) {
            printf("%s OSStatus %d %d\n",__FILE__,(int)status,__LINE__);
            return nil;
        }
        format = [[AVAudioFormat alloc]initWithStreamDescription:&asbd];
        
        //Need to use a lock as the Producer thread will also try to consume if buffer is too full.
        pthread_mutex_init(&consumerLock, nil);
        
        //Minimum of samples buffer should hold at any given time.
        int capacity = asbd.mSampleRate * seconds;
        
        //When there is less room than headroom, buffer will purge samples to make room.
        headRoom = capacity * 0.2;
        
        int32_t frameSize = asbd.mBytesPerFrame * asbd.mChannelsPerFrame;
        TPCircularBufferInit(&circularBuffer, (capacity + headRoom) * frameSize);
        
        //        [self start:nil];
        tap = [[AKRenderTap alloc]initWithAudioUnit:audioUnit renderNotify:[self renderNotifyBlock]];
    }
    return self;
}
-(instancetype)initWithAudioUnit:(AudioUnit)audioUnit {
    return [self initWithAudioUnit:audioUnit queueTime:0];
}
-(instancetype)initWithNode:(AVAudioNode *)node{
    return [self initWithNode:node queueTime:0];
}
-(instancetype)initWithNode:(AVAudioNode *)node queueTime:(double)seconds{
    AVAudioUnit *avAudioUnit = (AVAudioUnit *)node;
    if (![avAudioUnit respondsToSelector:@selector(audioUnit)]) {
        NSLog(@"%@ doesn't have an accessible audioUnit",NSStringFromClass(node.class));
        return nil;
    }
    return [self initWithAudioUnit:avAudioUnit.audioUnit queueTime:seconds];
}
-(void)clear {
    pthread_mutex_lock(&consumerLock);
    TPCircularBufferClear(&circularBuffer);
    pthread_mutex_unlock(&consumerLock);
}
- (void)dealloc {
    //Cleanup should happen after at least two render cycles so that nothing is deallocated mid-render
    double timeFromNow = 0.2;
    
    __block pthread_mutex_t lock = consumerLock;
    __block TPCircularBuffer dBuffer = circularBuffer;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeFromNow * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        TPCircularBufferCleanup(&dBuffer);
        pthread_mutex_destroy(&lock);
    });
}


-(BOOL)copyNextBufferList:(AudioBufferList *)bufferlistOut timeStamp:(AudioTimeStamp *)timeStamp{
    pthread_mutex_lock(&consumerLock);
    AudioBufferList *nextBuffer = TPCircularBufferNextBufferList(&circularBuffer, timeStamp);
    if (nextBuffer) {
        for (int i = 0; i < nextBuffer->mNumberBuffers; i++) {
            bufferlistOut->mNumberBuffers = 1;
            bufferlistOut->mBuffers[i].mDataByteSize = nextBuffer->mBuffers[i].mDataByteSize;
            memcpy(bufferlistOut->mBuffers[i].mData, nextBuffer->mBuffers[i].mData, nextBuffer->mBuffers[i].mDataByteSize);
        }
        TPCircularBufferConsumeNextBufferList(&circularBuffer);
    }
    pthread_mutex_unlock(&consumerLock);
    return nextBuffer != nil;
}

-(BOOL)fillNextBuffer:(AVAudioPCMBuffer * _Nonnull)buffer timeStamp:(AudioTimeStamp *)timeStamp{
    
    NSAssert([format isEqual:buffer.format],@"Lazy tap format doesn't match buffer in fillNextBuffer");
    
    pthread_mutex_lock(&consumerLock);
    buffer.frameLength = 0;
    
    AudioBufferList *bufferlist = TPCircularBufferNextBufferList(&circularBuffer, timeStamp);
    AudioStreamBasicDescription asbd = *format.streamDescription;
    
    while (bufferlist && buffer.frameLength < buffer.frameCapacity) {
        
        AudioBufferList *dst = buffer.mutableAudioBufferList;
        int framesInBuffer = bufferlist->mBuffers[0].mDataByteSize / asbd.mBytesPerFrame;
        int frames = MIN(buffer.frameCapacity - buffer.frameLength, framesInBuffer);
        int bytesPerFrame = asbd.mBytesPerFrame;
        int bytes = frames * bytesPerFrame;
        for (int i = 0; i < bufferlist->mNumberBuffers; i++) {
            memcpy((char *)dst->mBuffers[i].mData + (buffer.frameLength * bytesPerFrame), bufferlist->mBuffers[i].mData, bytes);
        }
        buffer.frameLength += frames;
        TPCircularBufferConsumeNextBufferListPartial(&circularBuffer, frames, &asbd);
        bufferlist = TPCircularBufferNextBufferList(&circularBuffer, NULL);
    }
    pthread_mutex_unlock(&consumerLock);
    return buffer.frameLength != 0;
}
-(AKRenderNotifyBlock)renderNotifyBlock {
    
    TPCircularBuffer *buffer = &self->circularBuffer;
    pthread_mutex_t *lock = &consumerLock;
    AudioStreamBasicDescription asbd = *format.streamDescription;
    int headroom = headRoom;
    
    return ^(AudioUnitRenderActionFlags *ioActionFlags,
             const AudioTimeStamp       *inTimeStamp,
             UInt32                     inBusNumber,
             UInt32                     inNumberFrames,
             AudioBufferList            *ioData) {
        
        if (!(*ioActionFlags & kAudioUnitRenderAction_PostRender)) {
            return;
        }
        
        UInt32 space = TPCircularBufferGetAvailableSpace(buffer, &asbd);
        if (space < headroom) {
            if (pthread_mutex_trylock(lock) == 0) {
                while (space < headroom) {
                    TPCircularBufferConsumeNextBufferList(buffer);
                    space = TPCircularBufferGetAvailableSpace(buffer, &asbd);
                }
                pthread_mutex_unlock(lock);
            }
        }
        if (space >= inNumberFrames) {
            TPCircularBufferCopyAudioBufferList(buffer, ioData, inTimeStamp, inNumberFrames, &asbd);
        } else {
            printf("AVLazy tap error in render callback - No Room!\n");
        }
    };
}

@end
