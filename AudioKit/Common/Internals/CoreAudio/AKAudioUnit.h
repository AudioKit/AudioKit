//
//  AKAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//


#import <AVFoundation/AVFoundation.h>

@protocol AKKernelUnit
-(AUImplementorValueProvider)getter;
-(AUImplementorValueObserver)setter;
@end

@interface AKAudioUnit : AUAudioUnit<AKKernelUnit>
@property AUAudioUnitBus *outputBus;
@property AUAudioUnitBusArray *inputBusArray;
@property AUAudioUnitBusArray *outputBusArray;
@property AVAudioFormat *defaultFormat;

- (void)start;
- (void)stop;
- (BOOL)isPlaying;
- (BOOL)isSetUp;

@property double rampTime;

-(AUImplementorValueProvider)getter;
-(AUImplementorValueObserver)setter;

@end

//@protocol AUParameterCollection
//- (AUValue)objectAtIndexedSubscript:(AUParameter *)idx;
//- (void)setObject:(AUValue)obj atIndexedSubscript:(AUParameter *)idx;
//@end

@interface AUParameter(Ext)
-(instancetype)init:(NSString *)identifier
               name:(NSString *)name
            address:(AUParameterAddress)address
                min:(AUValue)min
                max:(AUValue)max
               unit:(AudioUnitParameterUnit)unit;

+(instancetype)parameter:(NSString *)identifier
                    name:(NSString *)name
                 address:(AUParameterAddress)address
                     min:(AUValue)min
                     max:(AUValue)max
                    unit:(AudioUnitParameterUnit)unit;

+(instancetype)frequency:(NSString *)identifier
                    name:(NSString *)name
                 address:(AUParameterAddress)address;

@end

@interface AUParameterTree(Ext)
+(instancetype)tree:(NSArray<AUParameterNode *> *)children;
@end

@interface AVAudioNode(Ext)
-(instancetype)initWithComponent:(AudioComponentDescription)component;
@end


#define standardKernelPassthroughs() \
- (void)start { _kernel.start(); } \
- (void)stop { _kernel.stop(); } \
- (BOOL)isPlaying { return _kernel.started; } \
- (BOOL)isSetUp { return _kernel.resetted; }

#define standardSetup(str) \
    self.rampTime = AKSettings.rampTime; \
    self.defaultFormat = [[AVAudioFormat alloc] initStandardFormatWithSampleRate:AKSettings.sampleRate \
                                                                        channels:AKSettings.numberOfChannels]; \
    _kernel.init(self.defaultFormat.channelCount, self.defaultFormat.sampleRate); \
    _inputBus.init(self.defaultFormat, 8); \
    self.inputBusArray = [[AUAudioUnitBusArray alloc] initWithAudioUnit:self \
                                                                busType:AUAudioUnitBusTypeInput \
                                                                 busses:@[_inputBus.bus]];
#define standardGeneratorSetup(str) \
    self.rampTime = AKSettings.rampTime; \
    self.defaultFormat = [[AVAudioFormat alloc] initStandardFormatWithSampleRate:AKSettings.sampleRate \
                                                                        channels:AKSettings.numberOfChannels]; \
    _kernel.init(self.defaultFormat.channelCount, self.defaultFormat.sampleRate); \
    _outputBusBuffer.init(self.defaultFormat, 2); \
    self.outputBus = _outputBusBuffer.bus; \
    self.outputBusArray = [[AUAudioUnitBusArray alloc] initWithAudioUnit:self \
                                                                busType:AUAudioUnitBusTypeOutput \
                                                                 busses:@[self.outputBus]];
#define parameterTreeBlock(str) \
    __block AK##str##DSPKernel *blockKernel = &_kernel; \
    self.parameterTree.implementorValueObserver = ^(AUParameter *param, AUValue value) { \
        blockKernel->setParameter(param.address, value); \
    }; \
    self.parameterTree.implementorValueProvider = ^(AUParameter *param) { \
        return blockKernel->getParameter(param.address); \
    };

#define AUAudioUnitOverrides(str) \
\
- (BOOL)allocateRenderResourcesAndReturnError:(NSError **)outError { \
    if (![super allocateRenderResourcesAndReturnError:outError]) { \
        return NO; \
    } \
    if (self.outputBus.format.channelCount != _inputBus.bus.format.channelCount) { \
        if (outError) { \
            *outError = [NSError errorWithDomain:NSOSStatusErrorDomain \
                                            code:kAudioUnitErr_FailedInitialization \
                                        userInfo:nil]; \
        } \
        self.renderResourcesAllocated = NO; \
        return NO; \
    } \
    _inputBus.allocateRenderResources(self.maximumFramesToRender); \
    _kernel.init(self.outputBus.format.channelCount, self.outputBus.format.sampleRate); \
    _kernel.reset(); \
    return YES; \
} \
\
- (void)deallocateRenderResources { \
    [super deallocateRenderResources]; \
    _kernel.destroy(); \
    _inputBus.deallocateRenderResources(); \
} \
\
- (AUInternalRenderBlock)internalRenderBlock { \
    __block AK##str##DSPKernel *state = &_kernel; \
    __block BufferedInputBus *input = &_inputBus; \
    return ^AUAudioUnitStatus( \
                              AudioUnitRenderActionFlags *actionFlags, \
                              const AudioTimeStamp       *timestamp, \
                              AVAudioFrameCount           frameCount, \
                              NSInteger                   outputBusNumber, \
                              AudioBufferList            *outputData, \
                              const AURenderEvent        *realtimeEventListHead, \
                              AURenderPullInputBlock      pullInputBlock) { \
        AudioUnitRenderActionFlags pullFlags = 0; \
        AUAudioUnitStatus err = input->pullInput(&pullFlags, timestamp, frameCount, 0, pullInputBlock); \
        if (err != 0) { \
            return err; \
        } \
        AudioBufferList *inAudioBufferList = input->mutableAudioBufferList; \
        AudioBufferList *outAudioBufferList = outputData; \
        if (outAudioBufferList->mBuffers[0].mData == nullptr) { \
            for (UInt32 i = 0; i < outAudioBufferList->mNumberBuffers; ++i) { \
                outAudioBufferList->mBuffers[i].mData = inAudioBufferList->mBuffers[i].mData; \
            } \
        } \
        state->setBuffers(inAudioBufferList, outAudioBufferList); \
        state->processWithEvents(timestamp, frameCount, realtimeEventListHead); \
        return noErr; \
    }; \
}

#define AUAudioUnitGeneratorOverrides(str) \
\
- (BOOL)allocateRenderResourcesAndReturnError:(NSError **)outError { \
    if (![super allocateRenderResourcesAndReturnError:outError]) { \
        return NO; \
    } \
    _outputBusBuffer.allocateRenderResources(self.maximumFramesToRender); \
    _kernel.init(self.outputBus.format.channelCount, self.outputBus.format.sampleRate); \
    _kernel.reset(); \
    return YES; \
} \
\
- (void)deallocateRenderResources { \
    _outputBusBuffer.deallocateRenderResources(); \
    [super deallocateRenderResources]; \
} \
\
- (AUInternalRenderBlock)internalRenderBlock { \
    __block AK##str##DSPKernel *state = &_kernel; \
    return ^AUAudioUnitStatus( \
                              AudioUnitRenderActionFlags *actionFlags, \
                              const AudioTimeStamp       *timestamp, \
                              AVAudioFrameCount           frameCount, \
                              NSInteger                   outputBusNumber, \
                              AudioBufferList            *outputData, \
                              const AURenderEvent        *realtimeEventListHead, \
                              AURenderPullInputBlock      pullInputBlock) { \
        _outputBusBuffer.prepareOutputBufferList(outputData, frameCount, true); \
        state->setBuffer(outputData); \
        state->processWithEvents(timestamp, frameCount, realtimeEventListHead); \
        return noErr; \
    }; \
}

#define standardBankFunctions() \
- (BOOL)isSetUp { return _kernel.resetted; } \
- (void)setAttackDuration:(float)attackDuration { _kernel.setAttackDuration(attackDuration); } \
- (void)setDecayDuration:(float)decayDuration { _kernel.setDecayDuration(decayDuration); } \
- (void)setSustainLevel:(float)sustainLevel { _kernel.setSustainLevel(sustainLevel); } \
- (void)setReleaseDuration:(float)releaseDuration { _kernel.setReleaseDuration(releaseDuration); } \
- (void)setDetuningOffset:(float)detuningOffset { _kernel.setDetuningOffset(detuningOffset); } \
- (void)setDetuningMultiplier:(float)detuningMultiplier { _kernel.setDetuningMultiplier(detuningMultiplier); } \
- (void)stopNote:(uint8_t)note { _kernel.stopNote(note); } \
- (void)startNote:(uint8_t)note velocity:(uint8_t)velocity { _kernel.startNote(note, velocity); } \
- (void)startNote:(uint8_t)note velocity:(uint8_t)velocity frequency:(float)frequency { \
    _kernel.startNote(note, velocity, frequency); \
}

#define standardBankParameters() \
AudioUnitParameterOptions flags = kAudioUnitParameterFlag_IsWritable | kAudioUnitParameterFlag_IsReadable | kAudioUnitParameterFlag_DisplayLogarithmic;\
AUParameter *attackDurationAUParameter = \
[AUParameterTree createParameterWithIdentifier:@"attackDuration" \
                                          name:@"Attack" \
                                       address:attackDurationAddress \
                                           min:0 \
                                           max:1 \
                                          unit:kAudioUnitParameterUnit_Seconds \
                                      unitName:nil \
                                         flags:flags \
                                  valueStrings:nil \
                           dependentParameters:nil]; \
AUParameter *decayDurationAUParameter = \
[AUParameterTree createParameterWithIdentifier:@"decayDuration" \
                                          name:@"Decay" \
                                       address:decayDurationAddress \
                                           min:0 \
                                           max:1 \
                                          unit:kAudioUnitParameterUnit_Seconds \
                                      unitName:nil \
                                         flags:flags \
                                  valueStrings:nil \
                           dependentParameters:nil]; \
AUParameter *sustainLevelAUParameter = \
[AUParameterTree createParameterWithIdentifier:@"sustainLevel" \
                                          name:@"Sustain Level" \
                                       address:sustainLevelAddress \
                                           min:0 \
                                           max:1 \
                                          unit:kAudioUnitParameterUnit_Generic \
                                      unitName:nil \
                                         flags:flags \
                                  valueStrings:nil \
                           dependentParameters:nil]; \
AUParameter *releaseDurationAUParameter = \
[AUParameterTree createParameterWithIdentifier:@"releaseDuration" \
                                          name:@"Release" \
                                       address:releaseDurationAddress \
                                           min:0 \
                                           max:1 \
                                          unit:kAudioUnitParameterUnit_Seconds \
                                      unitName:nil \
                                         flags:flags \
                                  valueStrings:nil \
                           dependentParameters:nil]; \
AUParameter *detuningOffsetAUParameter = \
[AUParameterTree createParameterWithIdentifier:@"detuningOffset" \
                                          name:@"Detuning Offset" \
                                       address:detuningOffsetAddress \
                                           min:-1000 \
                                           max:1000 \
                                          unit:kAudioUnitParameterUnit_Hertz \
                                      unitName:nil \
                                         flags:0 \
                                  valueStrings:nil \
                           dependentParameters:nil]; \
AUParameter *detuningMultiplierAUParameter = \
[AUParameterTree createParameterWithIdentifier:@"detuningMultiplier" \
                                          name:@"Detuning Multiplier" \
                                       address:detuningMultiplierAddress \
                                           min:0.1 \
                                           max:2.0 \
                                          unit:kAudioUnitParameterUnit_Generic \
                                      unitName:nil \
                                         flags:0 \
                                  valueStrings:nil \
                           dependentParameters:nil]; \
attackDurationAUParameter.value = 0.1; \
decayDurationAUParameter.value = 0.1; \
sustainLevelAUParameter.value = 1.0; \
releaseDurationAUParameter.value = 0.1; \
detuningOffsetAUParameter.value = 0; \
detuningMultiplierAUParameter.value = 1; \
_kernel.setParameter(attackDurationAddress,  attackDurationAUParameter.value); \
_kernel.setParameter(decayDurationAddress,   decayDurationAUParameter.value); \
_kernel.setParameter(sustainLevelAddress,    sustainLevelAUParameter.value); \
_kernel.setParameter(releaseDurationAddress, releaseDurationAUParameter.value); \
_kernel.setParameter(detuningOffsetAddress,     detuningOffsetAUParameter.value); \
_kernel.setParameter(detuningMultiplierAddress, detuningMultiplierAUParameter.value);
