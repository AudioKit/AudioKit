//
//  AKInputDeviceAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

#import "AKInputDeviceAudioUnit.h"
#import "BufferedAudioBus.hpp"

@implementation AKInputDeviceAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    BufferedInputBus _inputBus;
    EZMicrophone *_mic;
    AudioBufferList *_micBufferList;
}
@synthesize parameterTree = _parameterTree;

- (void)createParameters {

//    standardSetup(InputDevice)  Might need input bus stuff

}

//AUAudioUnitGeneratorOverrides(InputDevice)

- (BOOL)allocateRenderResourcesAndReturnError:(NSError **)outError {
    if (![super allocateRenderResourcesAndReturnError:outError]) {
        return NO;
    }
    _inputBus.allocateRenderResources(self.maximumFramesToRender);
    *_micBufferList = AudioBufferList(); //Highly suspect
    _mic = [[EZMicrophone alloc] initWithMicrophoneDelegate:self];
    [_mic startFetchingAudio];
//    _kernel.init(self.outputBus.format.channelCount, self.outputBus.format.sampleRate);
//    _kernel.reset()
    return YES;
}

- (void)deallocateRenderResources {
    [super deallocateRenderResources];
//    _kernel.destroy();
    _inputBus.deallocateRenderResources();
}

- (AUInternalRenderBlock)internalRenderBlock {
//    __block AK##str##DSPKernel *state = &_kernel;
    __block BufferedInputBus *input = &_inputBus;
    return ^AUAudioUnitStatus(
                              AudioUnitRenderActionFlags *actionFlags,
                              const AudioTimeStamp       *timestamp,
                              AVAudioFrameCount           frameCount,
                              NSInteger                   outputBusNumber,
                              AudioBufferList            *outputData,
                              const AURenderEvent        *realtimeEventListHead,
                              AURenderPullInputBlock      pullInputBlock) {
//        AudioBufferList *inAudioBufferList = input->mutableAudioBufferList;
//        AudioBufferList *outAudioBufferList = outputData;
//        if (outAudioBufferList->mBuffers[0].mData == nullptr) {
//            for (UInt32 i = 0; i < outAudioBufferList->mNumberBuffers; ++i) {
//                outAudioBufferList->mBuffers[i].mData = inAudioBufferList->mBuffers[i].mData;
//            }
//        }
// This needs to get replaced with calls into EZMicrophone
//        state->setBuffer(outAudioBufferList);
//        state->processWithEvents(timestamp, frameCount, realtimeEventListHead);
        outputData = _micBufferList;
        return noErr;
    };
}

- (void) microphone:(EZMicrophone *)microphone
      hasBufferList:(AudioBufferList *)bufferList
     withBufferSize:(UInt32)bufferSize
withNumberOfChannels:(UInt32)numberOfChannels {
    _micBufferList = bufferList;
}

@end


