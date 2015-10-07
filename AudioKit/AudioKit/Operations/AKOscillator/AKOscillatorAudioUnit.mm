//
//  AKOscillatorAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka on 10/3/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

#import "AKOscillatorAudioUnit.h"
#import "AKOscillatorDSPKernel.hpp"

#import <AVFoundation/AVFoundation.h>
#import "AKBufferedAudioBus.hpp"

@interface AKOscillatorAudioUnit()

@property AUAudioUnitBus *outputBus;
@property AUAudioUnitBusArray *inputBusArray;
@property AUAudioUnitBusArray *outputBusArray;

@property (nonatomic, readwrite) AUParameterTree *parameterTree;

@end


@implementation AKOscillatorAudioUnit {
	// C++ members need to be ivars; they would be copied on access if they were properties.
    AKOscillatorDSPKernel _kernel;
    float buffer[2];
}
@synthesize parameterTree = _parameterTree;

- (instancetype)initWithComponentDescription:(AudioComponentDescription)componentDescription
                                     options:(AudioComponentInstantiationOptions)options
                                       error:(NSError **)outError {
    self = [super initWithComponentDescription:componentDescription options:options error:outError];

    if (self == nil) {
    	return nil;
    }
    buffer[0] = 0.0;
    buffer[1] = 0.0;

	// Initialize a default format for the busses.
    AVAudioFormat *defaultFormat = [[AVAudioFormat alloc] initStandardFormatWithSampleRate:44100.
                                                                                  channels:2];

	// Create a DSP kernel to handle the signal processing.
	_kernel.init(defaultFormat.channelCount, defaultFormat.sampleRate);

    // Create a parameter object for the frequency frequency.
    AUParameter *frequencyParam =
    [AUParameterTree createParameterWithIdentifier:@"frequency"
                                              name:@"Cutoff Frequency (Hz)"
                                           address:ParamCutoff
                                               min:12.0
                                               max:20000.0
                                              unit:kAudioUnitParameterUnit_Hertz
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];

    // Create a parameter object for the amplitude.
    AUParameter *amplitudeParam =
    [AUParameterTree createParameterWithIdentifier:@"amplitude"
                                              name:@"Resonance (%)"
                                           address:ParamResonance
                                               min:0.0
                                               max:100.0
                                              unit:kAudioUnitParameterUnit_Percent
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];

	// Initialize the parameter values.
	frequencyParam.value = 400.0;
	amplitudeParam.value = 3.0;
	_kernel.setParameter(ParamCutoff,    frequencyParam.value);
	_kernel.setParameter(ParamResonance, amplitudeParam.value);

	// Create the parameter tree.
    _parameterTree = [AUParameterTree createTreeWithChildren:@[
		frequencyParam,
		amplitudeParam
	]];

	// Create the output bus.
    _outputBus = [[AUAudioUnitBus alloc] initWithFormat:defaultFormat error:nil];

	// Create the output bus array.
	_outputBusArray = [[AUAudioUnitBusArray alloc] initWithAudioUnit:self
                                                             busType:AUAudioUnitBusTypeOutput
                                                              busses: @[_outputBus]];

	// Make a local pointer to the kernel to avoid capturing self.
	__block AKOscillatorDSPKernel *blockKernel = &_kernel;

	// implementorValueObserver is called when a parameter changes value.
	_parameterTree.implementorValueObserver = ^(AUParameter *param, AUValue value) {
		blockKernel->setParameter(param.address, value);
	};

	// implementorValueProvider is called when the value needs to be refreshed.
	_parameterTree.implementorValueProvider = ^(AUParameter *param) {
		return blockKernel->getParameter(param.address);
	};

	// A function to provide string representations of parameter values.
	_parameterTree.implementorStringFromValueCallback = ^(AUParameter *param, const AUValue *__nullable valuePtr) {
		AUValue value = valuePtr == nil ? param.value : *valuePtr;

		switch (param.address) {
			case ParamCutoff:
				return [NSString stringWithFormat:@"%.f", value];

			case ParamResonance:
				return [NSString stringWithFormat:@"%.2f", value];

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
    
	_kernel.init(self.outputBus.format.channelCount, self.outputBus.format.sampleRate);
	_kernel.reset();

	/*
		While rendering, we want to schedule all parameter changes. Setting them
        off the render thread is not thread safe.
	*/
	__block AUScheduleParameterBlock scheduleParameter = self.scheduleParameterBlock;

	// Ramp over 20 milliseconds.
	__block AUAudioFrameCount rampTime = AUAudioFrameCount(0.02 * self.outputBus.format.sampleRate);

	self.parameterTree.implementorValueObserver = ^(AUParameter *param, AUValue value) {
		scheduleParameter(AUEventSampleTimeImmediate, rampTime, param.address, value);
	};

	return YES;
}

- (void)deallocateRenderResources {
	[super deallocateRenderResources];

	// Make a local pointer to the kernel to avoid capturing self.
	__block AKOscillatorDSPKernel *blockKernel = &_kernel;

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
	__block AKOscillatorDSPKernel *state = &_kernel;

    return ^AUAudioUnitStatus(
			 AudioUnitRenderActionFlags *actionFlags,
			 const AudioTimeStamp       *timestamp,
			 AVAudioFrameCount           frameCount,
			 NSInteger                   outputBusNumber,
			 AudioBufferList            *outputData,
			 const AURenderEvent        *realtimeEventListHead,
			 AURenderPullInputBlock      pullInputBlock) {

		/*
			If the caller passed non-nil output pointers, use those. Otherwise,
            process in-place in the input buffer. If your algorithm cannot process
            in-place, then you will need to preallocate an output buffer and use
            it here.
		*/
		AudioBufferList *outAudioBufferList = outputData;
        if (outAudioBufferList->mBuffers[0].mData == nullptr) {
            for (UInt32 i = 0; i < outAudioBufferList->mNumberBuffers; ++i) {
                outAudioBufferList->mBuffers[i].mData = &buffer[i];
            }
        }
        

		state->setBuffers(outAudioBufferList);
		state->processWithEvents(timestamp, frameCount, realtimeEventListHead);

		return noErr;
	};
}


@end


