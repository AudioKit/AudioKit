//
//  AKBandRejectButterworthFilterAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#import "AKBandRejectButterworthFilterAudioUnit.h"
#import "AKBandRejectButterworthFilterDSPKernel.hpp"

#import <AVFoundation/AVFoundation.h>
#import "AKBufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>

@interface AKBandRejectButterworthFilterAudioUnit()

@property AUAudioUnitBus *outputBus;
@property AUAudioUnitBusArray *inputBusArray;
@property AUAudioUnitBusArray *outputBusArray;

@property (nonatomic, readwrite) AUParameterTree *parameterTree;

@end

@implementation AKBandRejectButterworthFilterAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKBandRejectButterworthFilterDSPKernel _kernel;

    BufferedInputBus _inputBus;
}
@synthesize parameterTree = _parameterTree;

- (void)start {
    _kernel.start();
}

- (void)stop {
    _kernel.stop();
}

- (BOOL)isPlaying {
    return _kernel.started;
}

- (instancetype)initWithComponentDescription:(AudioComponentDescription)componentDescription
                                     options:(AudioComponentInstantiationOptions)options
                                       error:(NSError **)outError {
    self = [super initWithComponentDescription:componentDescription options:options error:outError];

    if (self == nil) {
        return nil;
    }

    // Initialize a default format for the busses.
    AVAudioFormat *defaultFormat = [[AVAudioFormat alloc] initStandardFormatWithSampleRate:AKSettings.sampleRate
                                                                                  channels:AKSettings.numberOfChannels];

    // Create a DSP kernel to handle the signal processing.
    _kernel.init(defaultFormat.channelCount, defaultFormat.sampleRate);

        // Create a parameter object for the centerFrequency.
    AUParameter *centerFrequencyAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"centerFrequency"
                                              name:@"Center Frequency (Hz)"
                                           address:centerFrequencyAddress
                                               min:12.0
                                               max:20000.0
                                              unit:kAudioUnitParameterUnit_Hertz
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];
    // Create a parameter object for the bandwidth.
    AUParameter *bandwidthAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"bandwidth"
                                              name:@"Bandwidth (Hz)"
                                           address:bandwidthAddress
                                               min:0.0
                                               max:20000.0
                                              unit:kAudioUnitParameterUnit_Hertz
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];

    // Initialize the parameter values.
    centerFrequencyAUParameter.value = 3000;
    bandwidthAUParameter.value = 2000;
    
    _inertia = 0.0002;

    _kernel.setParameter(centerFrequencyAddress, centerFrequencyAUParameter.value);
    _kernel.setParameter(bandwidthAddress,       bandwidthAUParameter.value);

    // Create the parameter tree.
    _parameterTree = [AUParameterTree createTreeWithChildren:@[
        centerFrequencyAUParameter,
        bandwidthAUParameter
    ]];

    // Create the input and output busses.
    _inputBus.init(defaultFormat, 8);
    _outputBus = [[AUAudioUnitBus alloc] initWithFormat:defaultFormat error:nil];

    // Create the input and output bus arrays.
    _inputBusArray  = [[AUAudioUnitBusArray alloc] initWithAudioUnit:self
                                                             busType:AUAudioUnitBusTypeInput
                                                              busses: @[_inputBus.bus]];
    _outputBusArray = [[AUAudioUnitBusArray alloc] initWithAudioUnit:self
                                                             busType:AUAudioUnitBusTypeOutput
                                                              busses: @[_outputBus]];

    // Make a local pointer to the kernel to avoid capturing self.
    __block AKBandRejectButterworthFilterDSPKernel *blockKernel = &_kernel;

    // implementorValueObserver is called when a parameter changes value.
    _parameterTree.implementorValueObserver = ^(AUParameter *param, AUValue value) {
        blockKernel->setParameter(param.address, value);
    };

    // implementorValueProvider is called when the value needs to be refreshed.
    _parameterTree.implementorValueProvider = ^(AUParameter *param) {
        return blockKernel->getParameter(param.address);
    };

    self.maximumFramesToRender = 512;

    return self;
}

#pragma mark - AUAudioUnit Overrides

- (AUAudioUnitBusArray *)inputBusses {
    return _inputBusArray;
}
- (AUAudioUnitBusArray *)outputBusses {
    return _outputBusArray;
}

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
        // Notify superclass that initialization was not successful
        self.renderResourcesAllocated = NO;

        return NO;
    }
    _inputBus.allocateRenderResources(self.maximumFramesToRender);

    _kernel.init(self.outputBus.format.channelCount, self.outputBus.format.sampleRate);
    _kernel.reset();
    
    return YES;
}

- (void)setUpParameterRamp {
    /*
     While rendering, we want to schedule all parameter changes. Setting them
     off the render thread is not thread safe.
     */
    __block AUScheduleParameterBlock scheduleParameter = self.scheduleParameterBlock;
    
    // Ramp over inertia time in seconds.
    __block AUAudioFrameCount rampTime = AUAudioFrameCount(_inertia * self.outputBus.format.sampleRate);
    
    self.parameterTree.implementorValueObserver = ^(AUParameter *param, AUValue value) {
        scheduleParameter(AUEventSampleTimeImmediate, rampTime, param.address, value);
    };
}

- (void)deallocateRenderResources {
    [super deallocateRenderResources];
    _kernel.destroy();

    _inputBus.deallocateRenderResources();

    // Make a local pointer to the kernel to avoid capturing self.
    __block AKBandRejectButterworthFilterDSPKernel *blockKernel = &_kernel;

    // Go back to setting parameters instead of scheduling them.
    self.parameterTree.implementorValueObserver = ^(AUParameter *param, AUValue value) {
        blockKernel->setParameter(param.address, value);
    };
}

- (AUInternalRenderBlock)internalRenderBlock {
    /*
     Capture in locals to avoid ObjC member lookups. If "self" is captured in
     render, we're doing it wrong.
     */
    __block AKBandRejectButterworthFilterDSPKernel *state = &_kernel;
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

        /*
         If the caller passed non-nil output pointers, use those. Otherwise,
         process in-place in the input buffer. If your algorithm cannot process
         in-place, then you will need to preallocate an output buffer and use
         it here.
         */
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


@end


