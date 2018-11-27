//
//  AudioEngineUnit.m
//  AudioKit
//
//  Created by Dave O'Neill, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import "AudioEngineUnit.h"

@implementation AudioEngineUnit {
    AudioBufferList *inputNodeBufferlist;
}

-(instancetype)initWithComponentDescription:(AudioComponentDescription)componentDescription options:(AudioComponentInstantiationOptions)options error:(NSError * _Nullable __autoreleasing *)outError {
    self = [super initWithComponentDescription:componentDescription options:options error:outError];
    if (self) {
        _audioEngine = [[AVAudioEngine alloc]init];
    }
    return self;
}

-(BOOL)allocateRenderResourcesAndReturnError:(NSError * _Nullable __autoreleasing *)outError {
    if (![super allocateRenderResourcesAndReturnError:outError]) return false;

    AVAudioFormat *format = self.outputBusses[0].format;
    NSError *error = NULL;
    BOOL success = [self.audioEngine enableManualRenderingMode:AVAudioEngineManualRenderingModeRealtime
                                                           format:format
                                                maximumFrameCount:self.maximumFramesToRender
                                                            error: &error];
    if (!success) {
        NSLog(@"AudioEngine enableManualRenderingMode failed: %@", error.localizedDescription);
        return false;
    }

    if (self.shouldAllocateInputBus) {
        __unsafe_unretained AudioEngineUnit *welf = self;
        [self.audioEngine.inputNode setManualRenderingInputPCMFormat:format inputBlock:^const AudioBufferList * _Nullable(AVAudioFrameCount inNumberOfFrames) {
            return welf->inputNodeBufferlist;
        }];
    }

    if (![self.audioEngine startAndReturnError:&error]) {
        NSLog(@"AudioEngine start() failed: %@", error.localizedDescription);
        return false;
    }

    return true;
}

-(void)deallocateRenderResources {
    [self.audioEngine stop];
    [self.audioEngine disableManualRenderingMode];
    [super deallocateRenderResources];
}

-(ProcessEventsBlock)processEventsBlock:(AVAudioFormat *)format {

    AVAudioEngineManualRenderingBlock manualRenderingBlock = self.audioEngine.manualRenderingBlock;
    __unsafe_unretained AudioEngineUnit *welf = self;
    ProcessEventsBlock passThrough = [super processEventsBlock:format];

    return ^(AudioBufferList       *inBuffer,
             AudioBufferList       *outBuffer,
             const AudioTimeStamp  *timestamp,
             AVAudioFrameCount     frameCount,
             const AURenderEvent   *eventListHead) {

        welf->inputNodeBufferlist = inBuffer;
        AVAudioEngineManualRenderingStatus status = manualRenderingBlock(frameCount, outBuffer, NULL);
        if (status != AVAudioEngineManualRenderingStatusSuccess) {
            passThrough(inBuffer, outBuffer, timestamp, frameCount, eventListHead);
        }
    };
}

@end
