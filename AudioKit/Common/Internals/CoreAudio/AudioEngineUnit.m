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
        [self setIOFormat:[[AVAudioFormat alloc]initStandardFormatWithSampleRate:44100 channels:2] error:NULL];
    }
    return self;
}

-(BOOL)allocateRenderResourcesAndReturnError:(NSError * _Nullable __autoreleasing *)outError {
    if (![super allocateRenderResourcesAndReturnError:outError]) return false;

    AVAudioFormat *format = self.outputBusses[0].format;
    return [self setIOFormat:format error: outError] && [self.audioEngine startAndReturnError: outError];
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

- (BOOL)setIOFormat:(AVAudioFormat *)format error:(NSError **)outError{

    BOOL success =  [self.audioEngine enableManualRenderingMode:AVAudioEngineManualRenderingModeRealtime
                                                         format:format
                                              maximumFrameCount:self.maximumFramesToRender
                                                          error: outError];

    if (success && self.shouldAllocateInputBus) {
        __unsafe_unretained AudioEngineUnit *welf = self;
        success = [self.audioEngine.inputNode setManualRenderingInputPCMFormat:format inputBlock:^const AudioBufferList *(AVAudioFrameCount _) {
            return welf->inputNodeBufferlist;
        }];

        if (!success && outError != NULL) {
            *outError = [NSError errorWithDomain:@"AudioEngineUnit"
                                            code:0
                                        userInfo: @{NSLocalizedDescriptionKey: @"setManualRenderingInputPCMFormat fail"}];
        }
    }
    return success;
}

@end
