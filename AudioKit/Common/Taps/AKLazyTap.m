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
    AudioUnit _audioUnit;
    AudioStreamBasicDescription asbd;
    AVAudioFormat *format;
    int headRoom;

    //Need cleanup
    TPCircularBuffer circularBuffer;
    pthread_mutex_t consumerLock;
}

-(instancetype _Nullable)initWithAudioUnit:(AudioUnit)audioUnit queueTime:(double)seconds {
    self = [super init];
    if (self) {

        seconds = seconds <= 0 ?: 0.25;

        _audioUnit = audioUnit;

        UInt32 propSize = sizeof(AudioStreamBasicDescription);
        OSStatus status = AudioUnitGetProperty(audioUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 0, &asbd, &propSize);
        if (status) {
            printf("%s OSStatus %d %d\n",__FILE__,status,__LINE__);
            return nil;
        }
        format = [[AVAudioFormat alloc]initWithStreamDescription:&asbd];

        //Need to use a lock as the Producer thread will also try to consume if buffer is too full.
        pthread_mutex_init(&consumerLock, nil);

        asbd = *format.streamDescription;

        //Minimum of samples buffer should hold at any given time.
        int capacity = asbd.mSampleRate * seconds;

        //When there is less room than headroom, buffer will purge samples to make room.
        headRoom = capacity * 0.2;

        int32_t frameSize = asbd.mBytesPerFrame * asbd.mChannelsPerFrame;
        TPCircularBufferInit(&circularBuffer, (capacity + headRoom) * frameSize);

        status = AudioUnitAddRenderNotify(audioUnit, renderCallback, (__bridge void *)self);
        if (status) {
            printf("%s OSStatus %d %d\n",__FILE__,status,__LINE__);
            return nil;
        }
    }
    return self;
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

    OSStatus status = AudioUnitRemoveRenderNotify(_audioUnit, renderCallback, (__bridge void *)self);
    if (status) printf("%s OSStatus %d %d\n",__FILE__,status,__LINE__);

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
    if (nextBuffer){
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
    while (bufferlist && buffer.frameLength < buffer.frameCapacity) {

        AudioBufferList *dst = buffer.mutableAudioBufferList;
        int framesInBuffer = bufferlist->mBuffers[0].mDataByteSize / asbd.mBytesPerFrame;
        int frames = MIN(buffer.frameCapacity - buffer.frameLength, framesInBuffer);
        int bytesPerFrame = asbd.mBytesPerFrame;
        int bytes = frames * bytesPerFrame;
        for (int i = 0; i < bufferlist->mNumberBuffers; i++){
            memcpy((char *)dst->mBuffers[i].mData + (buffer.frameLength * bytesPerFrame), bufferlist->mBuffers[i].mData, bytes);
        }
        buffer.frameLength += frames;
        TPCircularBufferConsumeNextBufferListPartial(&circularBuffer, frames, &asbd);
        bufferlist = TPCircularBufferNextBufferList(&circularBuffer, NULL);
    }
    pthread_mutex_unlock(&consumerLock);
    return buffer.frameLength != 0;
}
static OSStatus renderCallback(void                         * inRefCon,
                               AudioUnitRenderActionFlags   * ioActionFlags,
                               const AudioTimeStamp         * inTimeStamp,
                               UInt32                       inBusNumber,
                               UInt32                       inNumberFrames,
                               AudioBufferList              * ioData) {

    if (!(*ioActionFlags & kAudioUnitRenderAction_PostRender)) {
        return noErr;
    }

    AKLazyTap *self = (__bridge __unsafe_unretained AKLazyTap *)inRefCon;

    UInt32 space = TPCircularBufferGetAvailableSpace(&self->circularBuffer, &self->asbd);
    if (space < self->headRoom) {
        if (pthread_mutex_trylock(&self->consumerLock) == 0){
            while (space < self->headRoom) {
                TPCircularBufferConsumeNextBufferList(&self->circularBuffer);
                space = TPCircularBufferGetAvailableSpace(&self->circularBuffer, &self->asbd);
            }
            pthread_mutex_unlock(&self->consumerLock);
        }

    }
    if (space >= inNumberFrames) {
        TPCircularBufferCopyAudioBufferList(&self->circularBuffer, ioData, inTimeStamp, inNumberFrames, &self->asbd);
    } else {
        printf("AVLazy tap error in render callback - No Room!\n");
    }
    return noErr;
}

@end

