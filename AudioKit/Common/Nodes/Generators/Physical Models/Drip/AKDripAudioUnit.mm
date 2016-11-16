//
//  AKDripAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#import "AKDripAudioUnit.h"
#import "AKDripDSPKernel.hpp"

#import <AVFoundation/AVFoundation.h>
#import "BufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>

@interface AKDripAudioUnit()

@property AUAudioUnitBus *outputBus;
@property AUAudioUnitBusArray *outputBusArray;

@end

@implementation AKDripAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKDripDSPKernel _kernel;

    BufferedInputBus _inputBus;
}
@synthesize parameterTree = _parameterTree;

- (void)setIntensity:(float)intensity {
    _kernel.setIntensity(intensity);
}
- (void)setDampingFactor:(float)dampingFactor {
    _kernel.setDampingFactor(dampingFactor);
}
- (void)setEnergyReturn:(float)energyReturn {
    _kernel.setEnergyReturn(energyReturn);
}
- (void)setMainResonantFrequency:(float)mainResonantFrequency {
    _kernel.setMainResonantFrequency(mainResonantFrequency);
}
- (void)setFirstResonantFrequency:(float)firstResonantFrequency {
    _kernel.setFirstResonantFrequency(firstResonantFrequency);
}
- (void)setSecondResonantFrequency:(float)secondResonantFrequency {
    _kernel.setSecondResonantFrequency(secondResonantFrequency);
}
- (void)setAmplitude:(float)amplitude {
    _kernel.setAmplitude(amplitude);
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

        // Create a parameter object for the intensity.
    AUParameter *intensityAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"intensity"
                                              name:@"The intensity of the dripping sounds."
                                           address:intensityAddress
                                               min:0
                                               max:100
                                              unit:kAudioUnitParameterUnit_Generic
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];
    // Create a parameter object for the dampingFactor.
    AUParameter *dampingFactorAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"dampingFactor"
                                              name:@"The damping factor. Maximum value is 2.0."
                                           address:dampingFactorAddress
                                               min:0.0
                                               max:2.0
                                              unit:kAudioUnitParameterUnit_Generic
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];
    // Create a parameter object for the energyReturn.
    AUParameter *energyReturnAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"energyReturn"
                                              name:@"The amount of energy to add back into the system."
                                           address:energyReturnAddress
                                               min:0
                                               max:100
                                              unit:kAudioUnitParameterUnit_Generic
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];
    // Create a parameter object for the mainResonantFrequency.
    AUParameter *mainResonantFrequencyAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"mainResonantFrequency"
                                              name:@"Main resonant frequency."
                                           address:mainResonantFrequencyAddress
                                               min:0
                                               max:22000
                                              unit:kAudioUnitParameterUnit_Hertz
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];
    // Create a parameter object for the firstResonantFrequency.
    AUParameter *firstResonantFrequencyAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"firstResonantFrequency"
                                              name:@"The first resonant frequency."
                                           address:firstResonantFrequencyAddress
                                               min:0
                                               max:22000
                                              unit:kAudioUnitParameterUnit_Hertz
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];
    // Create a parameter object for the secondResonantFrequency.
    AUParameter *secondResonantFrequencyAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"secondResonantFrequency"
                                              name:@"The second resonant frequency."
                                           address:secondResonantFrequencyAddress
                                               min:0
                                               max:22000
                                              unit:kAudioUnitParameterUnit_Hertz
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];
    // Create a parameter object for the amplitude.
    AUParameter *amplitudeAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"amplitude"
                                              name:@"Amplitude."
                                           address:amplitudeAddress
                                               min:0
                                               max:1
                                              unit:kAudioUnitParameterUnit_Generic
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];


    // Initialize the parameter values.
    intensityAUParameter.value = 10;
    dampingFactorAUParameter.value = 0.2;
    energyReturnAUParameter.value = 0;
    mainResonantFrequencyAUParameter.value = 450;
    firstResonantFrequencyAUParameter.value = 600;
    secondResonantFrequencyAUParameter.value = 750;
    amplitudeAUParameter.value = 0.3;

    _rampTime = AKSettings.rampTime;

    _kernel.setParameter(intensityAddress,               intensityAUParameter.value);
    _kernel.setParameter(dampingFactorAddress,           dampingFactorAUParameter.value);
    _kernel.setParameter(energyReturnAddress,            energyReturnAUParameter.value);
    _kernel.setParameter(mainResonantFrequencyAddress,   mainResonantFrequencyAUParameter.value);
    _kernel.setParameter(firstResonantFrequencyAddress,  firstResonantFrequencyAUParameter.value);
    _kernel.setParameter(secondResonantFrequencyAddress, secondResonantFrequencyAUParameter.value);
    _kernel.setParameter(amplitudeAddress,               amplitudeAUParameter.value);

    // Create the parameter tree.
    _parameterTree = [AUParameterTree createTreeWithChildren:@[
        intensityAUParameter,
        dampingFactorAUParameter,
        energyReturnAUParameter,
        mainResonantFrequencyAUParameter,
        firstResonantFrequencyAUParameter,
        secondResonantFrequencyAUParameter,
        amplitudeAUParameter
    ]];

    // Create the input and output busses.
    _inputBus.init(defaultFormat, 8);
    _outputBus = [[AUAudioUnitBus alloc] initWithFormat:defaultFormat error:nil];

    // Create the output bus arrays.
    _outputBusArray = [[AUAudioUnitBusArray alloc] initWithAudioUnit:self
                                                             busType:AUAudioUnitBusTypeOutput
                                                              busses: @[_outputBus]];

    // Make a local pointer to the kernel to avoid capturing self.
    __block AKDripDSPKernel *dripKernel = &_kernel;

    // implementorValueObserver is called when a parameter changes value.
    _parameterTree.implementorValueObserver = ^(AUParameter *param, AUValue value) {
        dripKernel->setParameter(param.address, value);
    };

    // implementorValueProvider is called when the value needs to be refreshed.
    _parameterTree.implementorValueProvider = ^(AUParameter *param) {
        return dripKernel->getParameter(param.address);
    };

    // A function to provide string representations of parameter values.
    _parameterTree.implementorStringFromValueCallback = ^(AUParameter *param, const AUValue *__nullable valuePtr) {
        AUValue value = valuePtr == nil ? param.value : *valuePtr;

        switch (param.address) {
            case intensityAddress:
                return [NSString stringWithFormat:@"%.3f", value];

            case dampingFactorAddress:
                return [NSString stringWithFormat:@"%.3f", value];

            case energyReturnAddress:
                return [NSString stringWithFormat:@"%.3f", value];

            case mainResonantFrequencyAddress:
                return [NSString stringWithFormat:@"%.3f", value];

            case firstResonantFrequencyAddress:
                return [NSString stringWithFormat:@"%.3f", value];

            case secondResonantFrequencyAddress:
                return [NSString stringWithFormat:@"%.3f", value];

            case amplitudeAddress:
                return [NSString stringWithFormat:@"%.3f", value];

            default:
                return @"?";
        }
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
}

- (AUInternalRenderBlock)internalRenderBlock {
    /*
     Capture in locals to avoid ObjC member lookups. If "self" is captured in
     render, we're doing it wrong.
     */
    __block AKDripDSPKernel *state = &_kernel;
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

        state->setBuffer(outAudioBufferList);
        state->processWithEvents(timestamp, frameCount, realtimeEventListHead);

        return noErr;
    };
}


@end


