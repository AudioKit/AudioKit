//
//  AKOfflineRenderAudioUnit.m
//  AudioKit For iOS
//
//  Created by Bang Means Do It on 27/03/2017.
//  Copyright © 2017 AudioKit. All rights reserved.
//

#import "AKOfflineRenderAudioUnit.h"
#import "AKOfflineRenderDSPKernel.hpp"
#import "BufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>

@implementation AKOfflineRenderAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKOfflineRenderDSPKernel _kernel;
    
    BufferedInputBus _inputBus;
}

@synthesize parameterTree = _parameterTree;

standardKernelPassthroughs();

- (void)createParameters {
    
    standardSetup(OfflineRender);
    
    parameterTreeBlock(OfflineRender);
}

// AUAudioUnitOverrides(OfflineRender);

- (BOOL)allocateRenderResourcesAndReturnError:(NSError **)outError {
    if (![super allocateRenderResourcesAndReturnError:outError]) {
        return NO;
    }
    if (self.outputBus.format.channelCount != _inputBus.bus.format.channelCount) {
        if (outError) {
            *outError = [NSError errorWithDomain:NSOSStatusErrorDomain
                                            code:kAudioUnitErr_FailedInitialization
                                        userInfo:nil];
        }
        self.renderResourcesAllocated = NO;
        return NO;
    }
    _inputBus.allocateRenderResources(self.maximumFramesToRender);
    _kernel.init(self.outputBus.format.channelCount, self.outputBus.format.sampleRate);
    _kernel.reset();
    return YES;
}

- (void)deallocateRenderResources {
    [super deallocateRenderResources];
    _kernel.destroy();
    _inputBus.deallocateRenderResources();
}

- (AUInternalRenderBlock)internalRenderBlock {
    __block AKOfflineRenderDSPKernel *state = &_kernel;
    __block BufferedInputBus *input = &_inputBus;
    
    return ^AUAudioUnitStatus(
                              AudioUnitRenderActionFlags *actionFlags,
                              const AudioTimeStamp       *timestamp,
                              AVAudioFrameCount           frameCount,
                              NSInteger                   outputBusNumber,
                              AudioBufferList            *outputData,
                              const AURenderEvent        *realtimeEventListHead,
                              AURenderPullInputBlock      pullInputBlock) {
        
        AudioUnitRenderActionFlags pullFlags = 0;

        AUAudioUnitStatus err = input->pullInput(&pullFlags, timestamp, frameCount, 0, pullInputBlock);
        
        if (err != 0) {
            return err;
        }
        
        AudioBufferList *inAudioBufferList = input->mutableAudioBufferList;
        AudioBufferList *outAudioBufferList = outputData;
        
        if (outAudioBufferList->mBuffers[0].mData == nullptr) {
            for (UInt32 i = 0; i < outAudioBufferList->mNumberBuffers; ++i) {
                outAudioBufferList->mBuffers[i].mData = inAudioBufferList->mBuffers[i].mData;
            }
        }
        
        state->setBuffers(inAudioBufferList, outAudioBufferList);
        state->processWithEvents(timestamp, frameCount, realtimeEventListHead);
        
        return noErr;
    };
}

// Custom set up
- (void)setUpAudioOutput:(CFURLRef)url {
    _kernel.setUpOutputAudioFile(url);
}

- (void)completeFileWrite {
    _kernel.completeFileWrite();
}

- (void)enableOfflineRender:(BOOL)enable {
    _kernel.enableOfflineRender(enable);
}

@end
