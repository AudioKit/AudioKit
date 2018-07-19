//
//  AKGeneratorAudioUnitBase.mm
//  AudioKit
//
//  Created by Andrew Voelkel, revision history on GitHub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import "AKGeneratorAudioUnitBase.h"
#import "BufferedAudioBus.hpp"

@interface AKGeneratorAudioUnitBase ()

@property AKDSPBase* kernel;

@end

@implementation AKGeneratorAudioUnitBase {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKDSPBase* _kernel;
    BufferedOutputBus _outputBusBuffer;
}

@synthesize parameterTree = _parameterTree;

- (float) getParameterWithAddress: (AUParameterAddress) address; {
    return _kernel->getParameter(address);
}
- (void) setParameterWithAddress:(AUParameterAddress)address value:(AUValue)value {
    _kernel->setParameter(address, value);
}

- (void) setParameterImmediatelyWithAddress:(AUParameterAddress)address value:(AUValue)value {
    _kernel->setParameter(address, value, true);
}

- (void)start { _kernel->start(); }
- (void)stop { _kernel->stop(); }
- (void)clear { _kernel->clear(); };
- (void)initializeConstant:(AUValue)value { _kernel->initializeConstant(value); }
- (BOOL)isPlaying { return _kernel->isPlaying(); }
- (BOOL)isSetUp { return _kernel->isSetup(); }
- (void)setupWaveform:(int)size {
    _kernel->setupWaveform((uint32_t)size);
}
- (void)setWaveformValue:(float)value atIndex:(UInt32)index; {
    _kernel->setWaveformValue(index, value);
}
- (void)setupIndividualWaveform:(UInt32)waveform size:(int)size {
    _kernel->setupIndividualWaveform(waveform, (uint32_t)size);
}

- (void)setIndividualWaveform:(UInt32)waveform withValue:(float)value atIndex:(UInt32)index {
    _kernel->setIndividualWaveformValue(waveform, index, value);
}
- (void)trigger {
    _kernel->trigger();
}
- (void)triggerFrequency:(float)frequency amplitude:(float)amplitude {
    _kernel->triggerFrequencyAmplitude(frequency, amplitude);
}
/**
 This should be overridden. All the base class does is make sure that the pointer to the
 DSP is invalid.
 */

- (void*)initDSPWithSampleRate:(double) sampleRate channelCount:(AVAudioChannelCount) count {
    return (void*)(_kernel = NULL);
}

/**
 Sets up the parameter tree. The reason this method must exist explicitly is that the blocks
 associated with the parameter tree must be set up here. This is because the pointer to the
 parameterTree is being changed. If we set up the blocks in the init function, they would be
 associated with the "old" parameterTree when the parameterTree is setup for real.

 Otherwise, this code is just the same as what is in the Apple example code init function.
 */

- (void) setParameterTree: (AUParameterTree*) tree {
    _parameterTree = tree;

    // Make a local pointer to the kernel to avoid capturing self.
    __block AKDSPBase *kernel = _kernel;

    // implementorValueObserver is called when a parameter changes value.
    _parameterTree.implementorValueObserver = ^(AUParameter *param, AUValue value) {
        kernel->setParameter(param.address, value);
    };

    // implementorValueProvider is called when the value needs to be refreshed.
    _parameterTree.implementorValueProvider = ^(AUParameter *param) {
        return kernel->getParameter(param.address);
    };

    // implementorStringFromValueCallback is called to provide string representations of parameter values.
    _parameterTree.implementorStringFromValueCallback = ^(AUParameter *param, const AUValue *__nullable valuePtr) {
        // If value is nil, use the current value of the parameter.
        AUValue value = valuePtr == nil ? param.value : *valuePtr;
        return [NSString stringWithFormat:@"%.2f", value];
    };
}

/**
 Much simpler than the Apple example code version. We don't deal with presets, we don't set up
 a specific parameterTree, etc. The block set for parameterTree is moved to setParameterTree
 */

- (instancetype)initWithComponentDescription:(AudioComponentDescription)componentDescription
                                     options:(AudioComponentInstantiationOptions)options
                                       error:(NSError **)outError {

    self = [super initWithComponentDescription:componentDescription options:options error:outError];
    if (self == nil) { return nil; }

    // Initialize a default format for the busses.
    AVAudioFormat *defaultFormat = [[AVAudioFormat alloc] initStandardFormatWithSampleRate:44100.0
                                                                                  channels:2];

    _kernel = (AKDSPBase*)[self initDSPWithSampleRate:defaultFormat.sampleRate
                                         channelCount:defaultFormat.channelCount];

    // Create the output bus.
    _outputBusBuffer.init(defaultFormat, 2);
    _outputBus = [[AUAudioUnitBus alloc] initWithFormat:defaultFormat error:nil];

    // Create the output bus array.

    _outputBusArray = [[AUAudioUnitBusArray alloc] initWithAudioUnit:self
                                                             busType:AUAudioUnitBusTypeOutput
                                                              busses: @[self.outputBus]];

    // Create a default empty parameter tree.
    _parameterTree = [AUParameterTree createTreeWithChildren:@[]];

    self.maximumFramesToRender = 512;

    return self;
}

// ----- BEGIN UNMODIFIED COPY FROM APPLE CODE -----

- (AUAudioUnitBusArray *)outputBusses { return _outputBusArray; }

// Allocate resources required to render.
// Hosts must call this to initialize the AU before beginning to render.
- (BOOL)allocateRenderResourcesAndReturnError:(NSError **)outError {
    if (![super allocateRenderResourcesAndReturnError:outError]) {
        return NO;
    }
    _outputBusBuffer.allocateRenderResources(self.maximumFramesToRender);
    _kernel->init(self.outputBus.format.channelCount, self.outputBus.format.sampleRate);
    _kernel->reset();
    return YES;
}

// Deallocate resources allocated by allocateRenderResourcesAndReturnError:
// Hosts should call this after finishing rendering.

- (void)deallocateRenderResources {
    _outputBusBuffer.deallocateRenderResources();
    [super deallocateRenderResources];
}

// Subclassers must provide a AUInternalRenderBlock (via a getter) to implement rendering.

- (AUInternalRenderBlock)internalRenderBlock {
    // Capture in locals to avoid ObjC member lookups.
    // Specify captured objects are mutable.
    __block AKDSPBase *state = _kernel;
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

// Expresses whether an audio unit can process in place.
// In-place processing is the ability for an audio unit to transform an input signal to an
// output signal in-place in the input buffer, without requiring a separate output buffer.
// A host can express its desire to process in place by using null mData pointers in the output
// buffer list. The audio unit may process in-place in the input buffers.
// See the discussion of renderBlock.
// Partially bridged to the v2 property kAudioUnitProperty_InPlaceProcessing, the v3 property is not settable.
- (BOOL)canProcessInPlace {
    return NO;   // OK THIS IS DIFFERENT FROM APPLE EXAMPLE CODE
}

// ----- END UNMODIFIED COPY FROM APPLE CODE -----




@end

