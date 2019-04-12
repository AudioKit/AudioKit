//
//  AKAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//


#import <AVFoundation/AVFoundation.h>

@protocol AKKernelUnit
-(AUImplementorValueProvider _Null_unspecified)getter;
-(AUImplementorValueObserver _Null_unspecified)setter;
@end

@interface AKAudioUnit : AUAudioUnit<AKKernelUnit>
@property AUAudioUnitBus * _Nonnull outputBus;
@property AUAudioUnitBusArray * _Nonnull inputBusArray;
@property AUAudioUnitBusArray * _Nonnull outputBusArray;
@property AVAudioFormat * _Nonnull defaultFormat;

- (void)start;
- (void)stop;
@property (readonly) BOOL isPlaying;
@property (readonly) BOOL isSetUp;

@property double rampDuration;

-(AUImplementorValueProvider _Null_unspecified)getter;
-(AUImplementorValueObserver _Null_unspecified)setter;

@end

//@protocol AUParameterCollection
//- (AUValue)objectAtIndexedSubscript:(AUParameter *)idx;
//- (void)setObject:(AUValue)obj atIndexedSubscript:(AUParameter *)idx;
//@end

@interface AUParameter(Ext)
//-(_Nonnull instancetype)init:(NSString * _Nonnull)identifier
//                        name:(NSString * _Nonnull)name
//                     address:(AUParameterAddress)address
//                         min:(AUValue)min
//                         max:(AUValue)max
//                        unit:(AudioUnitParameterUnit)unit
//                       flags:(AudioUnitParameterOptions)flags;

+(_Nonnull instancetype)parameterWithIdentifier:(NSString * _Nonnull)identifier
                                           name:(NSString * _Nonnull)name
                                        address:(AUParameterAddress)address
                                            min:(AUValue)min
                                            max:(AUValue)max
                                           unit:(AudioUnitParameterUnit)unit
                                          flags:(AudioUnitParameterOptions)flags;

+(_Nonnull instancetype)parameterWithIdentifier:(NSString * _Nonnull)identifier
                                           name:(NSString * _Nonnull)name
                                        address:(AUParameterAddress)address
                                            min:(AUValue)min
                                            max:(AUValue)max
                                           unit:(AudioUnitParameterUnit)unit;
//+(_Nonnull instancetype)frequency:(NSString * _Nonnull)identifier
//                             name:(NSString * _Nonnull)name
//                          address:(AUParameterAddress)address;

@end

@interface AUParameterTree(Ext)
+(_Nonnull instancetype)treeWithChildren:(NSArray<AUParameter *> * _Nonnull)children;
@end

//@interface AVAudioNode(Ext)
//-(instancetype)initWithComponent:(AudioComponentDescription)component;
//@end


#define standardKernelPassthroughs() \
- (void)start { _kernel.start(); } \
- (void)stop { _kernel.stop(); } \
- (BOOL)isPlaying { return _kernel.started; } \
- (BOOL)isSetUp { return _kernel.resetted; } \
- (void)setShouldBypassEffect:(BOOL)shouldBypassEffect { \
    if (shouldBypassEffect) {\
        _kernel.stop();\
    } else {\
        _kernel.start();\
    }\
}\

#define standardSetup(str) \
    self.rampDuration = AKSettings.rampDuration; \
    self.defaultFormat = [[AVAudioFormat alloc] initStandardFormatWithSampleRate:AKSettings.sampleRate \
                                                                        channels:AKSettings.channelCount]; \
    _kernel.init(self.defaultFormat.channelCount, self.defaultFormat.sampleRate); \
    _inputBus.init(self.defaultFormat, 8); \
    self.inputBusArray = [[AUAudioUnitBusArray alloc] initWithAudioUnit:self \
                                                                busType:AUAudioUnitBusTypeInput \
                                                                 busses:@[_inputBus.bus]];
#define standardGeneratorSetup(str) \
    self.rampDuration = AKSettings.rampDuration; \
    self.defaultFormat = [[AVAudioFormat alloc] initStandardFormatWithSampleRate:AKSettings.sampleRate \
                                                                        channels:AKSettings.channelCount]; \
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
