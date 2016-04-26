//
//  AKMetalBarAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#import "AKMetalBarAudioUnit.h"
#import "AKMetalBarDSPKernel.hpp"

#import <AVFoundation/AVFoundation.h>
#import "BufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>

@interface AKMetalBarAudioUnit()

@property AUAudioUnitBus *outputBus;

@property AUAudioUnitBusArray *outputBusArray;

@property (nonatomic, readwrite) AUParameterTree *parameterTree;

@end

@implementation AKMetalBarAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKMetalBarDSPKernel _kernel;

    BufferedInputBus _inputBus;
}
@synthesize parameterTree = _parameterTree;

- (void)setLeftboundarycondition:(float)leftBoundaryCondition {
    _kernel.setLeftboundarycondition(leftBoundaryCondition);
}
- (void)setRightboundarycondition:(float)rightBoundaryCondition {
    _kernel.setRightboundarycondition(rightBoundaryCondition);
}
- (void)setDecayduration:(float)decayDuration {
    _kernel.setDecayduration(decayDuration);
}
- (void)setScanspeed:(float)scanSpeed {
    _kernel.setScanspeed(scanSpeed);
}
- (void)setPosition:(float)position {
    _kernel.setPosition(position);
}
- (void)setStrikevelocity:(float)strikeVelocity {
    _kernel.setStrikevelocity(strikeVelocity);
}
- (void)setStrikewidth:(float)strikeWidth {
    _kernel.setStrikewidth(strikeWidth);
}

- (void)trigger {
    _kernel.trigger();
}

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

        // Create a parameter object for the leftBoundaryCondition.
    AUParameter *leftBoundaryConditionAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"leftBoundaryCondition"
                                              name:@"Boundary condition at left end of bar. 1 = clamped, 2 = pivoting, 3 = free"
                                           address:leftBoundaryConditionAddress
                                               min:1
                                               max:3
                                              unit:kAudioUnitParameterUnit_Hertz
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];
    // Create a parameter object for the rightBoundaryCondition.
    AUParameter *rightBoundaryConditionAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"rightBoundaryCondition"
                                              name:@"Boundary condition at right end of bar. 1 = clamped, 2 = pivoting, 3 = free"
                                           address:rightBoundaryConditionAddress
                                               min:1
                                               max:3
                                              unit:kAudioUnitParameterUnit_Hertz
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];
    // Create a parameter object for the decayDuration.
    AUParameter *decayDurationAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"decayDuration"
                                              name:@"30db decay time (in seconds)."
                                           address:decayDurationAddress
                                               min:0
                                               max:10
                                              unit:kAudioUnitParameterUnit_Hertz
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];
    // Create a parameter object for the scanSpeed.
    AUParameter *scanSpeedAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"scanSpeed"
                                              name:@"Speed of scanning the output location."
                                           address:scanSpeedAddress
                                               min:0
                                               max:100
                                              unit:kAudioUnitParameterUnit_Hertz
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];
    // Create a parameter object for the position.
    AUParameter *positionAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"position"
                                              name:@"Position along bar that strike occurs."
                                           address:positionAddress
                                               min:0
                                               max:1
                                              unit:kAudioUnitParameterUnit_Generic
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];
    // Create a parameter object for the strikeVelocity.
    AUParameter *strikeVelocityAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"strikeVelocity"
                                              name:@"Normalized strike velocity"
                                           address:strikeVelocityAddress
                                               min:0
                                               max:1000
                                              unit:kAudioUnitParameterUnit_Generic
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];
    // Create a parameter object for the strikeWidth.
    AUParameter *strikeWidthAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"strikeWidth"
                                              name:@"Spatial width of strike."
                                           address:strikeWidthAddress
                                               min:0
                                               max:1
                                              unit:kAudioUnitParameterUnit_Generic
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];

    _rampTime = AKSettings.rampTime;

    // Initialize the parameter values.
    leftBoundaryConditionAUParameter.value = 1;
    rightBoundaryConditionAUParameter.value = 1;
    decayDurationAUParameter.value = 3;
    scanSpeedAUParameter.value = 0.25;
    positionAUParameter.value = 0.2;
    strikeVelocityAUParameter.value = 500;
    strikeWidthAUParameter.value = 0.05;

    _kernel.setParameter(leftBoundaryConditionAddress,  leftBoundaryConditionAUParameter.value);
    _kernel.setParameter(rightBoundaryConditionAddress, rightBoundaryConditionAUParameter.value);
    _kernel.setParameter(decayDurationAddress,          decayDurationAUParameter.value);
    _kernel.setParameter(scanSpeedAddress,              scanSpeedAUParameter.value);
    _kernel.setParameter(positionAddress,               positionAUParameter.value);
    _kernel.setParameter(strikeVelocityAddress,         strikeVelocityAUParameter.value);
    _kernel.setParameter(strikeWidthAddress,            strikeWidthAUParameter.value);

    // Create the parameter tree.
    _parameterTree = [AUParameterTree createTreeWithChildren:@[
        leftBoundaryConditionAUParameter,
        rightBoundaryConditionAUParameter,
        decayDurationAUParameter,
        scanSpeedAUParameter,
        positionAUParameter,
        strikeVelocityAUParameter,
        strikeWidthAUParameter
    ]];

    // Create the input and output busses.
    _inputBus.init(defaultFormat, 8);
    _outputBus = [[AUAudioUnitBus alloc] initWithFormat:defaultFormat error:nil];

    _outputBusArray = [[AUAudioUnitBusArray alloc] initWithAudioUnit:self
                                                             busType:AUAudioUnitBusTypeOutput
                                                              busses: @[_outputBus]];

    // Make a local pointer to the kernel to avoid capturing self.
    __block AKMetalBarDSPKernel *blockKernel = &_kernel;

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

    [self setUpParameterRamp];

    return YES;
}

- (void)setUpParameterRamp {
    /*
     While rendering, we want to schedule all parameter changes. Setting them
     off the render thread is not thread safe.
     */
    __block AUScheduleParameterBlock scheduleParameter = self.scheduleParameterBlock;

    // Ramp over rampTime in seconds.
    __block AUAudioFrameCount rampTime = AUAudioFrameCount(_rampTime * self.outputBus.format.sampleRate);

    self.parameterTree.implementorValueObserver = ^(AUParameter *param, AUValue value) {
        scheduleParameter(AUEventSampleTimeImmediate, rampTime, param.address, value);
    };
}

- (void)deallocateRenderResources {
    [super deallocateRenderResources];
    _kernel.destroy();

    _inputBus.deallocateRenderResources();

    // Make a local pointer to the kernel to avoid capturing self.
    __block AKMetalBarDSPKernel *blockKernel = &_kernel;

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
    __block AKMetalBarDSPKernel *state = &_kernel;
    __block BufferedInputBus *input = &_inputBus;

    return ^AUAudioUnitStatus(
                              AudioUnitRenderActionFlags *actionFlags,
                              const AudioTimeStamp       *timestamp,
                              AVAudioFrameCount           frameCount,
                              NSInteger                   outputBusNumber,
                              AudioBufferList            *outputData,
                              const AURenderEvent        *realtimeEventListHead,
                              AURenderPullInputBlock      pullInputBlock) {

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


