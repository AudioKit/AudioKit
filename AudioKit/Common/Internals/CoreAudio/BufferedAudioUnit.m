//
//  BufferedAudioUnit.m
//  AudioKit
//
//  Created by Dave O'Neill, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import "BufferedAudioUnit.h"
#import <AudioKit/AudioKit-Swift.h>

const int kMaxChannelCount = 16;

// Private AudioBufferList helpers.
static void    bufferListPrepare(AudioBufferList *audioBufferList, int channelCount, int frameCount);
static void    bufferListClear(AudioBufferList *audioBufferList);
static size_t  bufferListByteSize(int channelCount);
static Boolean bufferListHasNullData(AudioBufferList *bufferList);
static void    bufferListPointChannelDataToBuffer(AudioBufferList *bufferList, float *buffer);

@implementation BufferedAudioUnit
{
    float *_inputBuffer;
    float *_ouputBuffer;
    AUAudioUnitBusArray *_inputBusArray;
    AUAudioUnitBusArray *_outputBusArray;
    ProcessEventsBlock _processEventsBlock;
    BOOL _shouldClearOutputBuffer;
}

- (instancetype)initWithComponentDescription:(AudioComponentDescription)componentDescription
                                     options:(AudioComponentInstantiationOptions)options
                                       error:(NSError **)outError {
    self = [super initWithComponentDescription:componentDescription options:options error:outError];

    if (self != nil) {
        // Initialize a default format for the busses.
        AVAudioFormat *arbitraryFormat = AKSettings.audioFormat;

        if ([self shouldAllocateInputBus]) {
            _inputBusArray = [[AUAudioUnitBusArray alloc] initWithAudioUnit:self
                                                                    busType:AUAudioUnitBusTypeInput
                                                                     busses:@[[[AUAudioUnitBus alloc]initWithFormat:arbitraryFormat error:NULL]]];
        }

        _outputBusArray = [[AUAudioUnitBusArray alloc] initWithAudioUnit:self
                                                                 busType:AUAudioUnitBusTypeOutput
                                                                  busses:@[[[AUAudioUnitBus alloc]initWithFormat:arbitraryFormat error:NULL]]];

        _shouldClearOutputBuffer = [self shouldClearOutputBuffer];
    }
    return self;
}

- (BOOL)shouldAllocateInputBus {
    return true;
}

- (BOOL)shouldClearOutputBuffer {
    return false;
}

- (BOOL)allocateRenderResourcesAndReturnError:(NSError **)outError {
    if (![super allocateRenderResourcesAndReturnError:outError]) {
        return NO;
    }

    AVAudioFormat *format = _outputBusArray[0].format;
    if (_inputBusArray != NULL && [_inputBusArray[0].format isEqual:format] == false) {
        if (outError) {
            *outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:kAudioUnitErr_FormatNotSupported userInfo:nil];
        }
        NSLog(@"%@ input format must match output format", self.class);
        self.renderResourcesAllocated = NO;
        return NO;
    }

    assert(_inputBuffer == NULL && _ouputBuffer == NULL);

    size_t bufferSize = sizeof(float) * format.channelCount * self.maximumFramesToRender;
    if (self.shouldAllocateInputBus) {
        _inputBuffer = malloc(bufferSize);
    }

    if (self.canProcessInPlace == false || self.shouldAllocateInputBus == false) {
        _ouputBuffer = malloc(bufferSize);
    }

    _processEventsBlock = [self processEventsBlock:format];
    return YES;
}

- (void)deallocateRenderResources {
    if (_inputBuffer != NULL) {
        free(_inputBuffer);
    }

    if (_ouputBuffer != NULL) {
        free(_ouputBuffer);
    }
    _inputBuffer = NULL;
    _ouputBuffer = NULL;
    [super deallocateRenderResources];
}

- (ProcessEventsBlock)processEventsBlock:(AVAudioFormat *)format {
    return ^(AudioBufferList *inBuffer,
             AudioBufferList *outBuffer,
             const AudioTimeStamp *timestamp,
             AVAudioFrameCount frameCount,
             const AURenderEvent *realtimeEventListHead) {
               if (inBuffer == NULL) {
                   for (int i = 0; i < outBuffer->mNumberBuffers; i++) {
                       memset(outBuffer->mBuffers[i].mData, 0, outBuffer->mBuffers[i].mDataByteSize);
                   }
               } else {
                   for (int i = 0; i < inBuffer->mNumberBuffers; i++) {
                       memcpy(outBuffer->mBuffers[i].mData, inBuffer->mBuffers[i].mData, inBuffer->mBuffers[i].mDataByteSize);
                   }
               }
    };
}

- (AUInternalRenderBlock)internalRenderBlock {
    // Use untracked pointer and ivars to avoid Obj methods + ARC.
    __unsafe_unretained BufferedAudioUnit *welf = self;
    return ^AUAudioUnitStatus (AudioUnitRenderActionFlags *actionFlags,
                               const AudioTimeStamp *timestamp,
                               AVAudioFrameCount frameCount,
                               NSInteger outputBusNumber,
                               AudioBufferList *outputBufferList,
                               const AURenderEvent *realtimeEventListHead,
                               AURenderPullInputBlock pullInputBlock) {
               int channelCount = outputBufferList->mNumberBuffers;

               // Guard against potential stack overflow.
               assert(channelCount <= kMaxChannelCount);

               char inputBufferAllocation[bufferListByteSize(outputBufferList->mNumberBuffers)];
               AudioBufferList *inputBufferList = NULL;

               if (welf->_inputBuffer != NULL) {
                   // Prepare buffer for pull input.
                   inputBufferList = (AudioBufferList *)inputBufferAllocation;
                   bufferListPrepare(inputBufferList, channelCount, frameCount);
                   bufferListPointChannelDataToBuffer(inputBufferList, welf->_inputBuffer);

                   // Pull input into _inputBuffer.
                   AudioUnitRenderActionFlags flags = 0;
                   AUAudioUnitStatus status = pullInputBlock(&flags, timestamp, frameCount, 0, inputBufferList);
                   if (status) return status;
               }

               // If outputBufferList has null data, point to valid buffer before processing.
               if (bufferListHasNullData(outputBufferList)) {
                   float *buffer = welf->_ouputBuffer ? : welf->_inputBuffer;
                   bufferListPointChannelDataToBuffer(outputBufferList, buffer);
               }

               if (welf->_shouldClearOutputBuffer) {
                   bufferListClear(outputBufferList);
               }

               welf->_processEventsBlock(inputBufferList, outputBufferList, timestamp, frameCount, realtimeEventListHead);
               return noErr;
    };
}

- (AUAudioUnitBusArray *)inputBusses {
    return _inputBusArray;
}

- (AUAudioUnitBusArray *)outputBusses {
    return _outputBusArray;
}

@end

// Private AudioBufferList helpers.
static void bufferListPrepare(AudioBufferList *audioBufferList,
                              int             channelCount,
                              int             frameCount)
{
    audioBufferList->mNumberBuffers = channelCount;
    for (int channelIndex = 0; channelIndex < channelCount; channelIndex++) {
        audioBufferList->mBuffers[channelIndex].mNumberChannels = 1;
        audioBufferList->mBuffers[channelIndex].mDataByteSize = frameCount * sizeof(float);
    }
}

static void bufferListClear(AudioBufferList *audioBufferList)
{
    for (int i = 0; i < audioBufferList->mNumberBuffers; i++) {
        memset(audioBufferList->mBuffers[i].mData, 0, audioBufferList->mBuffers[i].mDataByteSize);
    }
}

static size_t bufferListByteSize(int channelCount)
{
    return sizeof(AudioBufferList) + (sizeof(AudioBuffer) * (channelCount - 1));
}

static Boolean bufferListHasNullData(AudioBufferList *bufferList)
{
    return bufferList->mBuffers[0].mData == NULL;
}

static void bufferListPointChannelDataToBuffer(AudioBufferList *bufferList, float *buffer)
{
    int frameCount = bufferList->mBuffers[0].mDataByteSize / sizeof(float);
    for (int channelIndex = 0; channelIndex < bufferList->mNumberBuffers; channelIndex++) {
        int offset = channelIndex * frameCount;
        bufferList->mBuffers[channelIndex].mData = buffer + offset;
    }
}
