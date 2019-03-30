//
//  DIYSeqEngine.m
//  AudioKit
//
//  Created by Jeff Cooper on 1/25/19.
//  Copyright © 2019 AudioKit. All rights reserved.
//
#import <AudioKit/AudioKit-Swift.h>

#import "DIYSeqEngine.h"
#import "DIYSeqDSPKernel.hpp"

#import "BufferedAudioBus.hpp"

@implementation AKDIYSeqEngine {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKDIYSeqEngineDSPKernel _kernel;
    BufferedOutputBus _outputBusBuffer;
}
@synthesize parameterTree = _parameterTree;

-(void)setTempo:(double)bpm {
    _kernel.bpm = bpm;
}
-(double)getTempo {
    return _kernel.bpm;
}
-(void)setLengthInBeats:(double)length {
    _kernel.lengthInBeats = length;
}
-(double)getLengthInBeats {
    return _kernel.lengthInBeats;
}
-(void)setMaximumPlayCount:(double)maximumPlayCount {
    _kernel.maximumPlayCount = maximumPlayCount;
}
-(double)getMaximumPlayCount {
    return _kernel.maximumPlayCount;
}

-(void)setLoopEnabled:(bool)loopEnabled {
    _kernel.loopEnabled = loopEnabled;
}
-(bool)loopEnabled {
    return _kernel.loopEnabled;
}
-(void)setTarget:(AudioUnit)target {
    _kernel.setTargetAU(target);
}
-(void)addMIDIEvent:(uint8_t)status data1:(uint8_t)data1 data2:(uint8_t)data2 beat:(double)beat {
    _kernel.addMIDIEvent(status, data1, data2, beat);
}
-(void)setLoopCallback:(AKCCallback)callback {
    _kernel.loopCallback = callback;
}
-(void)clear {
    _kernel.clear();
}

- (void)start { _kernel.start(); }
- (void)stop { _kernel.stop(); }
- (BOOL)isPlaying { return _kernel.started; }
- (BOOL)isSetUp { return _kernel.resetted; }
- (void)setShouldBypassEffect:(BOOL)shouldBypassEffect {
    if (shouldBypassEffect) {
        _kernel.stop();
    } else {
        _kernel.start();
    }
}

- (void)createParameters {

self.rampDuration = AKSettings.rampDuration;
self.defaultFormat = [[AVAudioFormat alloc] initStandardFormatWithSampleRate:AKSettings.sampleRate channels:AKSettings.channelCount];
_kernel.init(self.defaultFormat.channelCount, self.defaultFormat.sampleRate);
_outputBusBuffer.init(self.defaultFormat, 2);
self.outputBus = _outputBusBuffer.bus;
self.outputBusArray = [[AUAudioUnitBusArray alloc] initWithAudioUnit:self busType:AUAudioUnitBusTypeOutput busses:@[self.outputBus]];

    // Create a parameter object for the start.
    AUParameter *startPointAUParameter = [AUParameter parameterWithIdentifier:@"startPoint"
                                                                         name:@"startPoint"
                                                                      address:startPointAddress
                                                                          min:0
                                                                          max:1
                                                                         unit:kAudioUnitParameterUnit_Generic];
    // Initialize the parameter values.
    startPointAUParameter.value = 0;

    _kernel.setParameter(startPointAddress,   startPointAUParameter.value);

    // Create the parameter tree.
    _parameterTree = [AUParameterTree treeWithChildren:@[
                                                         startPointAUParameter
                                                         ]];

    __block AKDIYSeqEngineDSPKernel *blockKernel = &_kernel;
    self.parameterTree.implementorValueObserver = ^(AUParameter *param, AUValue value) {
        blockKernel->setParameter(param.address, value);
    };
    self.parameterTree.implementorValueProvider = ^(AUParameter *param) {
        return blockKernel->getParameter(param.address);
    };
}

- (BOOL)allocateRenderResourcesAndReturnError:(NSError **)outError {
    if (![super allocateRenderResourcesAndReturnError:outError]) {
        return NO;
    }
    _outputBusBuffer.allocateRenderResources(self.maximumFramesToRender);
    _kernel.init(self.outputBus.format.channelCount, self.outputBus.format.sampleRate);
    _kernel.reset();
    return YES;
}

- (void)deallocateRenderResources {
    _outputBusBuffer.deallocateRenderResources();
    [super deallocateRenderResources];
}

- (AUInternalRenderBlock)internalRenderBlock {
    __block AKDIYSeqEngineDSPKernel *state = &_kernel;
    return ^AUAudioUnitStatus(
                              AudioUnitRenderActionFlags *actionFlags,
                              const AudioTimeStamp       *timestamp,
                              AVAudioFrameCount           frameCount,
                              NSInteger                   outputBusNumber,
                              AudioBufferList            *outputData,
                              const AURenderEvent        *realtimeEventListHead,
                              AURenderPullInputBlock      pullInputBlock) {
        _outputBusBuffer.prepareOutputBufferList(outputData, frameCount, true);
        state->setBuffer(outputData);
        state->processWithEvents(timestamp, frameCount, realtimeEventListHead);
        return noErr;
    };
}

@end
