//
//  AKVocoderAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#import "AKVocoderAudioUnit.h"
#import "AKVocoderDSPKernel.hpp"

#import <AVFoundation/AVFoundation.h>
#import "BufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>

@interface AKVocoderAudioUnit()

@property AUAudioUnitBus *outputBus;
@property AUAudioUnitBusArray *inputBusArray;
@property AUAudioUnitBusArray *outputBusArray;

@property (nonatomic, readwrite) AUParameterTree *parameterTree;

@end

@implementation AKVocoderAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKVocoderDSPKernel _kernel;

    BufferedInputBus _inputBus;
    BufferedInputBus _exciteBus;
}
@synthesize parameterTree = _parameterTree;

- (void)setAttackTime:(float)attackTime {
    _kernel.setAttackTime(attackTime);
}
- (void)setReleaseTime:(float)releaseTime {
    _kernel.setReleaseTime(releaseTime);
}
- (void)setBandwidthRatio:(float)bandwidthRatio {
    _kernel.setBandwidthRatio(bandwidthRatio);
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

- (BOOL)isSetUp {
    return _kernel.resetted;
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

        // Create a parameter object for the attackTime.
    AUParameter *attackTimeAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"attackTime"
                                              name:@"Attack time (seconds)"
                                           address:attackTimeAddress
                                               min:0.001
                                               max:0.5
                                              unit:kAudioUnitParameterUnit_Seconds
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];
    // Create a parameter object for the releaseTime.
    AUParameter *releaseTimeAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"releaseTime"
                                              name:@"Release time (seconds)"
                                           address:releaseTimeAddress
                                               min:0.001
                                               max:0.5
                                              unit:kAudioUnitParameterUnit_Seconds
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];
    // Create a parameter object for the bandwidthRatio.
    AUParameter *bandwidthRatioAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"bandwidthRatio"
                                              name:@"Coeffecient to adjust the bandwidth of each band"
                                           address:bandwidthRatioAddress
                                               min:0.1
                                               max:2
                                              unit:kAudioUnitParameterUnit_Generic
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];


    // Initialize the parameter values.
    attackTimeAUParameter.value = 0.1;
    releaseTimeAUParameter.value = 0.1;
    bandwidthRatioAUParameter.value = 0.5;

    _rampTime = AKSettings.rampTime;

    _kernel.setParameter(attackTimeAddress,       attackTimeAUParameter.value);
    _kernel.setParameter(releaseTimeAddress,      releaseTimeAUParameter.value);
    _kernel.setParameter(bandwidthRatioAddress,   bandwidthRatioAUParameter.value);

    // Create the parameter tree.
    _parameterTree = [AUParameterTree createTreeWithChildren:@[
        attackTimeAUParameter,
        releaseTimeAUParameter,
        bandwidthRatioAUParameter
    ]];

    // Create the input and output busses.
    _inputBus.init(defaultFormat, 8);
    _exciteBus.init(defaultFormat, 8);
    _outputBus = [[AUAudioUnitBus alloc] initWithFormat:defaultFormat error:nil];

    // Create the input and output bus arrays.
    _inputBusArray  = [[AUAudioUnitBusArray alloc] initWithAudioUnit:self
                                                             busType:AUAudioUnitBusTypeInput
                                                              busses: @[_inputBus.bus, _exciteBus.bus]];
    _outputBusArray = [[AUAudioUnitBusArray alloc] initWithAudioUnit:self
                                                             busType:AUAudioUnitBusTypeOutput
                                                              busses: @[_outputBus]];

    // Make a local pointer to the kernel to avoid capturing self.
    __block AKVocoderDSPKernel *vocoderKernel = &_kernel;

    // implementorValueObserver is called when a parameter changes value.
    _parameterTree.implementorValueObserver = ^(AUParameter *param, AUValue value) {
        vocoderKernel->setParameter(param.address, value);
    };

    // implementorValueProvider is called when the value needs to be refreshed.
    _parameterTree.implementorValueProvider = ^(AUParameter *param) {
        return vocoderKernel->getParameter(param.address);
    };

    // A function to provide string representations of parameter values.
    _parameterTree.implementorStringFromValueCallback = ^(AUParameter *param, const AUValue *__nullable valuePtr) {
        AUValue value = valuePtr == nil ? param.value : *valuePtr;

        switch (param.address) {
            case attackTimeAddress:
                return [NSString stringWithFormat:@"%.3f", value];

            case releaseTimeAddress:
                return [NSString stringWithFormat:@"%.3f", value];

            case bandwidthRatioAddress:
                return [NSString stringWithFormat:@"%.3f", value];

            default:
                return @"?";
        }
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
    _exciteBus.allocateRenderResources(self.maximumFramesToRender);

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
    _exciteBus.deallocateRenderResources();
}

- (AUInternalRenderBlock)internalRenderBlock {
    /*
     Capture in locals to avoid ObjC member lookups. If "self" is captured in
     render, we're doing it wrong.
     */
    __block AKVocoderDSPKernel *state = &_kernel;
    __block BufferedInputBus *input = &_inputBus;
    __block BufferedInputBus *excite = &_exciteBus;

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
        
        AUAudioUnitStatus err2 = excite->pullInput(&pullFlags, timestamp, frameCount, 1, pullInputBlock);
        
        if (err2 != 0) {
            return err2;
        }

        AudioBufferList *inAudioBufferList = input->mutableAudioBufferList;
        AudioBufferList *exciteAudioBufferList = excite->mutableAudioBufferList;
        
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

        state->setBuffers(inAudioBufferList, exciteAudioBufferList, outAudioBufferList);
        state->processWithEvents(timestamp, frameCount, realtimeEventListHead);

        return noErr;
    };
}


@end


