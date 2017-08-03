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
        AudioBufferList *inAudioBufferList = input->mutableAudioBufferList; \
        AudioBufferList *outAudioBufferList = outputData; \
        if (outAudioBufferList->mBuffers[0].mData == nullptr) { \
            for (UInt32 i = 0; i < outAudioBufferList->mNumberBuffers; ++i) { \
                outAudioBufferList->mBuffers[i].mData = inAudioBufferList->mBuffers[i].mData; \
            } \
        } \
        state->setBuffer(outAudioBufferList); \
        state->processWithEvents(timestamp, frameCount, realtimeEventListHead); \
        return noErr; \
    }; \
}
