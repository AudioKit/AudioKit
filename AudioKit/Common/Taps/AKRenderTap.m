//
//  AKRenderTap.m
//  AudioKit
//
//  Created by David O'Neill on 8/16/17.
//  Copyright © AudioKit. All rights reserved.
//

#import "AKRenderTap.h"
#import "TPCircularBuffer+AudioBufferList.h"
#import <pthread/pthread.h>


@implementation AKRenderTap{
    AudioUnit _audioUnit;
    AKRenderNotifyBlock _renderNotifyBlock;
    BOOL _started;
}

-(instancetype _Nullable )initWithAudioUnit:(AudioUnit _Nonnull)audioUnit {
    self = [super init];
    if (self) {
        _audioUnit = audioUnit;
    }
    return self;
}
-(BOOL)start:(NSError **)outError {
    if (_started) {
        return true;
    }
    _renderNotifyBlock = _renderNotifyBlock ?: self.renderNotifyBlock;
    if (!_renderNotifyBlock) {
        if (outError) {
            NSString *description = [NSString stringWithFormat:@"%@ start renderNotifyBlock nil!",NSStringFromClass(self.class)];
            *outError =  [NSError errorWithDomain:@"AKRenderTap"
                                             code:1
                                         userInfo:@{NSLocalizedDescriptionKey:description}];
        }
        return false;
    }
    OSStatus status = AudioUnitAddRenderNotify(_audioUnit, renderNotify, (__bridge void *)_renderNotifyBlock);
    if (status) {
        if (outError) {
            NSString *description = [NSString stringWithFormat:@"%@ start error",NSStringFromClass(self.class)];
            *outError =  [NSError errorWithDomain:NSOSStatusErrorDomain
                                             code:status
                                         userInfo:@{NSLocalizedDescriptionKey:description}];
        }
        return false;
    }
    _started = true;
    return true;
}
-(void)stop{
    if (!_started) {
        return;
    }
    OSStatus status = AudioUnitRemoveRenderNotify(_audioUnit, renderNotify, (__bridge void *)_renderNotifyBlock);
    if (status) {
        printf("%s OSStatus %d %d\n",NSStringFromClass(self.class).UTF8String,status,__LINE__);
    }
    _started = false;
}
-(BOOL)started {
    return _started;
}
-(instancetype)initWithNode:(AVAudioNode *)node {
    AVAudioUnit *avAudioUnit = (AVAudioUnit *)node;
    if (![avAudioUnit respondsToSelector:@selector(audioUnit)]) {
        NSLog(@"%@ doesn't have an accessible audioUnit",NSStringFromClass(node.class));
        return nil;
    }
    return [self initWithAudioUnit:avAudioUnit.audioUnit];
}

- (void)dealloc {
    [self stop];

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
