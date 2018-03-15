//
//  AKRenderTap.m
//  AudioKit
//
//  Created by David O'Neill, revision history on GitHub.
//  Copyright © AudioKit. All rights reserved.
//

#import "AKRenderTap.h"
#import "TPCircularBuffer+AudioBufferList.h"
#import <pthread/pthread.h>


@implementation AKRenderTap{
    AKRenderNotifyBlock _renderNotifyBlock;
}

-(instancetype)initWithNode:(AVAudioNode *)node renderNotify:(AKRenderNotifyBlock)block {
    AVAudioUnit *avAudioUnit = (AVAudioUnit *)node;
    if (![avAudioUnit respondsToSelector:@selector(audioUnit)]) {
        NSLog(@"%@ doesn't have an accessible audioUnit", NSStringFromClass(node.class));
        return nil;
    }
    return [self initWithAudioUnit:avAudioUnit.audioUnit renderNotify:block];
}
-(instancetype _Nullable )initWithAudioUnit:(AudioUnit _Nonnull)audioUnit renderNotify:(AKRenderNotifyBlock)block {
    if (!audioUnit) {
        NSLog(@"AKRenderTap.initWithAudioUnit needs an audio unit");
        return NULL;
    }
    self = [super init];
    if (self) {
        _audioUnit = audioUnit;
        _renderNotifyBlock = block ?: [self renderNotifyBlock];
        if (!_renderNotifyBlock) {
            NSLog(@"AKRenderTap.initWithAudioUnit - no render notify block!");
        }
        OSStatus status = AudioUnitAddRenderNotify(_audioUnit, renderNotify, (__bridge void *)_renderNotifyBlock);
        if (status) {
            NSLog(@"AKRenderTap AudioUnitAddRenderNotify error %i", (int)status);
            return nil;
        }
    }
    return self;
}


- (void)dealloc {

    OSStatus status = AudioUnitRemoveRenderNotify(_audioUnit, renderNotify, (__bridge void *)_renderNotifyBlock);
    if (status) {
        printf("%s OSStatus %d %d\n",NSStringFromClass(self.class).UTF8String, (int)status, __LINE__);
    }

    //Cleanup should happen after at least two render cycles so that nothing is deallocated mid-render
    double timeFromNow = 0.2;
    AKRenderNotifyBlock dBlock = _renderNotifyBlock;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeFromNow * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        AKRenderNotifyBlock block = dBlock;
        block = nil;
    });
}

static OSStatus renderNotify(void                        * inRefCon,
                             AudioUnitRenderActionFlags   * ioActionFlags,
                             const AudioTimeStamp         * inTimeStamp,
                             UInt32                       inBusNumber,
                             UInt32                       inNumberFrames,
                             AudioBufferList              * ioData) {

    __unsafe_unretained AKRenderNotifyBlock notifyBlock = (__bridge AKRenderNotifyBlock)(inRefCon);
    if (notifyBlock) {
        notifyBlock(ioActionFlags, inTimeStamp, inBusNumber, inNumberFrames, ioData);
    }
    return noErr;
}

@end
