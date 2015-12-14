//
//  EZOutput.m
//  EZAudio
//
//  Created by Syed Haris Ali on 12/2/13.
//  Copyright (c) 2015 Syed Haris Ali. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "EZOutput.h"
#import "EZAudioDevice.h"
#import "EZAudioFloatConverter.h"
#import "EZAudioUtilities.h"

//------------------------------------------------------------------------------
#pragma mark - Constants
//------------------------------------------------------------------------------

UInt32  const EZOutputMaximumFramesPerSlice = 4096;
Float64 const EZOutputDefaultSampleRate     = 44100.0f;

//------------------------------------------------------------------------------
#pragma mark - Data Structures
//------------------------------------------------------------------------------

typedef struct
{
    // stream format params
    AudioStreamBasicDescription inputFormat;
    AudioStreamBasicDescription clientFormat;
    
    // float converted data
    float **floatData;
    
    // nodes
    EZAudioNodeInfo converterNodeInfo;
    EZAudioNodeInfo mixerNodeInfo;
    EZAudioNodeInfo outputNodeInfo;
    
    // audio graph
    AUGraph graph;
} EZOutputInfo;

//------------------------------------------------------------------------------
#pragma mark - Callbacks (Declaration)
//------------------------------------------------------------------------------

OSStatus EZOutputConverterInputCallback(void                       *inRefCon,
                                        AudioUnitRenderActionFlags *ioActionFlags,
                                        const AudioTimeStamp       *inTimeStamp,
                                        UInt32					    inBusNumber,
                                        UInt32					    inNumberFrames,
                                        AudioBufferList            *ioData);

//------------------------------------------------------------------------------

OSStatus EZOutputGraphRenderCallback(void                       *inRefCon,
                                     AudioUnitRenderActionFlags *ioActionFlags,
                                     const AudioTimeStamp       *inTimeStamp,
                                     UInt32					     inBusNumber,
                                     UInt32                      inNumberFrames,
                                     AudioBufferList            *ioData);

//------------------------------------------------------------------------------
#pragma mark - EZOutput (Interface Extension)
//------------------------------------------------------------------------------

@interface EZOutput ()
@property (nonatomic, strong) EZAudioFloatConverter *floatConverter;
@property (nonatomic, assign) EZOutputInfo *info;
@end

//------------------------------------------------------------------------------
#pragma mark - EZOutput (Implementation)
//------------------------------------------------------------------------------

@implementation EZOutput

//------------------------------------------------------------------------------
#pragma mark - Dealloc
//------------------------------------------------------------------------------

- (void)dealloc
{
    if (self.floatConverter)
    {
        self.floatConverter = nil;
        [EZAudioUtilities freeFloatBuffers:self.info->floatData
                          numberOfChannels:self.info->clientFormat.mChannelsPerFrame];
    }
    [EZAudioUtilities checkResult:AUGraphStop(self.info->graph)
                        operation:"Failed to stop graph"];
    [EZAudioUtilities checkResult:AUGraphClose(self.info->graph)
                        operation:"Failed to close graph"];
    [EZAudioUtilities checkResult:DisposeAUGraph(self.info->graph)
                        operation:"Failed to dispose of graph"];
    free(self.info);
}

//------------------------------------------------------------------------------
#pragma mark - Initialization
//------------------------------------------------------------------------------

- (instancetype) init
{
    self = [super init];
    if (self)
    {
        [self setup];
    }
    return self;
}

//------------------------------------------------------------------------------

- (instancetype)initWithDataSource:(id<EZOutputDataSource>)dataSource
{
    self = [self init];
    if (self)
    {
        self.dataSource = dataSource;
    }
    return self;
}

//------------------------------------------------------------------------------

- (instancetype)initWithDataSource:(id<EZOutputDataSource>)dataSource
                       inputFormat:(AudioStreamBasicDescription)inputFormat
{
    self = [self initWithDataSource:dataSource];
    if (self)
    {
        self.inputFormat = inputFormat;
    }
    return self;
}

//------------------------------------------------------------------------------
#pragma mark - Class Initializers
//------------------------------------------------------------------------------

+ (instancetype)output
{
    return [[self alloc] init];
}

//------------------------------------------------------------------------------

+ (instancetype)outputWithDataSource:(id<EZOutputDataSource>)dataSource
{
    return [[self alloc] initWithDataSource:dataSource];
}

//------------------------------------------------------------------------------

+ (instancetype)outputWithDataSource:(id<EZOutputDataSource>)dataSource
                         inputFormat:(AudioStreamBasicDescription)inputFormat
{
    return [[self alloc] initWithDataSource:dataSource
                                inputFormat:inputFormat];
}

//------------------------------------------------------------------------------
#pragma mark - Singleton
//------------------------------------------------------------------------------

+ (instancetype)sharedOutput
{
    static EZOutput *output;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        output = [[self alloc] init];
    });
    return output;
}

//------------------------------------------------------------------------------
#pragma mark - Setup
//------------------------------------------------------------------------------

- (void)setup
{
    //
    // Create structure to hold state data
    //
    self.info = (EZOutputInfo *)malloc(sizeof(EZOutputInfo));
    memset(self.info, 0, sizeof(EZOutputInfo));
    
    //
    // Setup the audio graph
    //
    [EZAudioUtilities checkResult:NewAUGraph(&self.info->graph)
                        operation:"Failed to create graph"];
    
    //
    // Add converter node
    //
    AudioComponentDescription converterDescription;
    converterDescription.componentType = kAudioUnitType_FormatConverter;
    converterDescription.componentSubType = kAudioUnitSubType_AUConverter;
    converterDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
    [EZAudioUtilities checkResult:AUGraphAddNode(self.info->graph,
                                                 &converterDescription,
                                                 &self.info->converterNodeInfo.node)
                        operation:"Failed to add converter node to audio graph"];
    
    //
    // Add mixer node
    //
    AudioComponentDescription mixerDescription;
    mixerDescription.componentType = kAudioUnitType_Mixer;
#if TARGET_OS_IPHONE
    mixerDescription.componentSubType = kAudioUnitSubType_MultiChannelMixer;
#elif TARGET_OS_MAC
    mixerDescription.componentSubType = kAudioUnitSubType_StereoMixer;
#endif
    mixerDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
    [EZAudioUtilities checkResult:AUGraphAddNode(self.info->graph,
                                                 &mixerDescription,
                                                 &self.info->mixerNodeInfo.node)
                        operation:"Failed to add mixer node to audio graph"];
    
    //
    // Add output node
    //
    AudioComponentDescription outputDescription;
    outputDescription.componentType = kAudioUnitType_Output;
    outputDescription.componentSubType = [self outputAudioUnitSubType];
    outputDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
    [EZAudioUtilities checkResult:AUGraphAddNode(self.info->graph,
                                                 &outputDescription,
                                                 &self.info->outputNodeInfo.node)
                        operation:"Failed to add output node to audio graph"];
    
    //
    // Open the graph
    //
    [EZAudioUtilities checkResult:AUGraphOpen(self.info->graph)
                        operation:"Failed to open graph"];
    
    //
    // Make node connections
    //
    OSStatus status = [self connectOutputOfSourceNode:self.info->converterNodeInfo.node
                                  sourceNodeOutputBus:0
                                    toDestinationNode:self.info->mixerNodeInfo.node
                              destinationNodeInputBus:0
                                              inGraph:self.info->graph];
    [EZAudioUtilities checkResult:status
                        operation:"Failed to connect output of source node to destination node in graph"];
    
    //
    // Connect mixer to output
    //
    [EZAudioUtilities checkResult:AUGraphConnectNodeInput(self.info->graph,
                                                          self.info->mixerNodeInfo.node,
                                                          0,
                                                          self.info->outputNodeInfo.node,
                                                          0)
                        operation:"Failed to connect mixer node to output node"];
    
    //
    // Get the audio units
    //
    [EZAudioUtilities checkResult:AUGraphNodeInfo(self.info->graph,
                                                  self.info->converterNodeInfo.node,
                                                  &converterDescription,
                                                  &self.info->converterNodeInfo.audioUnit)
                        operation:"Failed to get converter audio unit"];
    [EZAudioUtilities checkResult:AUGraphNodeInfo(self.info->graph,
                                                  self.info->mixerNodeInfo.node,
                                                  &mixerDescription,
                                                  &self.info->mixerNodeInfo.audioUnit)
                        operation:"Failed to get mixer audio unit"];
    [EZAudioUtilities checkResult:AUGraphNodeInfo(self.info->graph,
                                                  self.info->outputNodeInfo.node,
                                                  &outputDescription,
                                                  &self.info->outputNodeInfo.audioUnit)
                        operation:"Failed to get output audio unit"];
    
    //
    // Add a node input callback for the converter node
    //
    AURenderCallbackStruct converterCallback;
    converterCallback.inputProc = EZOutputConverterInputCallback;
    converterCallback.inputProcRefCon = (__bridge void *)(self);
    [EZAudioUtilities checkResult:AUGraphSetNodeInputCallback(self.info->graph,
                                                              self.info->converterNodeInfo.node,
                                                              0,
                                                              &converterCallback)
                        operation:"Failed to set render callback on converter node"];
    
    //
    // Set stream formats
    //
    [self setClientFormat:[self defaultClientFormat]];
    [self setInputFormat:[self defaultInputFormat]];
    
    //
    // Use the default device
    //
    EZAudioDevice *currentOutputDevice = [EZAudioDevice currentOutputDevice];
    [self setDevice:currentOutputDevice];
    
    //
    // Set maximum frames per slice to 4096 to allow playback during
    // lock screen (iOS only?)
    //
    UInt32 maximumFramesPerSlice = EZOutputMaximumFramesPerSlice;
    [EZAudioUtilities checkResult:AudioUnitSetProperty(self.info->mixerNodeInfo.audioUnit,
                                                       kAudioUnitProperty_MaximumFramesPerSlice,
                                                       kAudioUnitScope_Global,
                                                       0,
                                                       &maximumFramesPerSlice,
                                                       sizeof(maximumFramesPerSlice))
                        operation:"Failed to set maximum frames per slice on mixer node"];
    
    //
    // Initialize all the audio units in the graph
    //
    [EZAudioUtilities checkResult:AUGraphInitialize(self.info->graph)
                        operation:"Failed to initialize graph"];
    
    //
    // Add render callback
    //
    [EZAudioUtilities checkResult:AudioUnitAddRenderNotify(self.info->mixerNodeInfo.audioUnit,
                                                           EZOutputGraphRenderCallback,
                                                           (__bridge void *)(self))
                        operation:"Failed to add render callback"];
}

//------------------------------------------------------------------------------
#pragma mark - Actions
//------------------------------------------------------------------------------

- (void)startPlayback
{
    //
    // Start the AUGraph
    //
    [EZAudioUtilities checkResult:AUGraphStart(self.info->graph)
                        operation:"Failed to start graph"];
    
    //
    // Notify delegate
    //
    if ([self.delegate respondsToSelector:@selector(output:changedPlayingState:)])
    {
        [self.delegate output:self changedPlayingState:[self isPlaying]];
    }
}

//------------------------------------------------------------------------------

- (void)stopPlayback
{
    //
    // Stop the AUGraph
    //
    [EZAudioUtilities checkResult:AUGraphStop(self.info->graph)
                        operation:"Failed to stop graph"];
    
    //
    // Notify delegate
    //
    if ([self.delegate respondsToSelector:@selector(output:changedPlayingState:)])
    {
        [self.delegate output:self changedPlayingState:[self isPlaying]];
    }
}

//------------------------------------------------------------------------------
#pragma mark - Getters
//------------------------------------------------------------------------------

- (AudioStreamBasicDescription)clientFormat
{
    return self.info->clientFormat;
}

//------------------------------------------------------------------------------

- (AudioStreamBasicDescription)inputFormat
{
    return self.info->inputFormat;
}

//------------------------------------------------------------------------------

- (BOOL)isPlaying
{
    Boolean isPlaying;
    [EZAudioUtilities checkResult:AUGraphIsRunning(self.info->graph,
                                                   &isPlaying)
                        operation:"Failed to check if graph is running"];
    return isPlaying;
}

//------------------------------------------------------------------------------

- (float)pan
{
    AudioUnitParameterID param;
#if TARGET_OS_IPHONE
    param = kMultiChannelMixerParam_Pan;
#elif TARGET_OS_MAC
    param = kStereoMixerParam_Pan;
#endif
    AudioUnitParameterValue pan;
    [EZAudioUtilities checkResult:AudioUnitGetParameter(self.info->mixerNodeInfo.audioUnit,
                                                        param,
                                                        kAudioUnitScope_Input,
                                                        0,
                                                        &pan) operation:"Failed to get pan from mixer unit"];
    return pan;
}

//------------------------------------------------------------------------------

- (float)volume
{
    AudioUnitParameterID param;
#if TARGET_OS_IPHONE
    param = kMultiChannelMixerParam_Volume;
#elif TARGET_OS_MAC
    param = kStereoMixerParam_Volume;
#endif
    AudioUnitParameterValue volume;
    [EZAudioUtilities checkResult:AudioUnitGetParameter(self.info->mixerNodeInfo.audioUnit,
                                                        param,
                                                        kAudioUnitScope_Input,
                                                        0,
                                                        &volume)
                        operation:"Failed to get volume from mixer unit"];
    return volume;
}

//------------------------------------------------------------------------------
#pragma mark - Setters
//------------------------------------------------------------------------------

- (void)setClientFormat:(AudioStreamBasicDescription)clientFormat
{
    if (self.floatConverter)
    {
        self.floatConverter = nil;
        [EZAudioUtilities freeFloatBuffers:self.info->floatData
                          numberOfChannels:self.clientFormat.mChannelsPerFrame];
    }
    
    self.info->clientFormat = clientFormat;
    [EZAudioUtilities checkResult:AudioUnitSetProperty(self.info->converterNodeInfo.audioUnit,
                                                       kAudioUnitProperty_StreamFormat,
                                                       kAudioUnitScope_Output,
                                                       0,
                                                       &self.info->clientFormat,
                                                       sizeof(self.info->clientFormat))
                        operation:"Failed to set output client format on converter audio unit"];
    [EZAudioUtilities checkResult:AudioUnitSetProperty(self.info->mixerNodeInfo.audioUnit,
                                                       kAudioUnitProperty_StreamFormat,
                                                       kAudioUnitScope_Input,
                                                       0,
                                                       &self.info->clientFormat,
                                                       sizeof(self.info->clientFormat))
                        operation:"Failed to set input client format on mixer audio unit"];
    [EZAudioUtilities checkResult:AudioUnitSetProperty(self.info->mixerNodeInfo.audioUnit,
                                                       kAudioUnitProperty_StreamFormat,
                                                       kAudioUnitScope_Output,
                                                       0,
                                                       &self.info->clientFormat,
                                                       sizeof(self.info->clientFormat))
                        operation:"Failed to set output client format on mixer audio unit"];
    
    self.floatConverter = [[EZAudioFloatConverter alloc] initWithInputFormat:clientFormat];
    self.info->floatData = [EZAudioUtilities floatBuffersWithNumberOfFrames:EZOutputMaximumFramesPerSlice
                                                           numberOfChannels:clientFormat.mChannelsPerFrame];
}

//------------------------------------------------------------------------------

- (void)setDevice:(EZAudioDevice *)device
{
#if TARGET_OS_IPHONE
    
    // if the devices are equal then ignore
    if ([device isEqual:self.device])
    {
        return;
    }
    
    NSError *error;
    [[AVAudioSession sharedInstance] setOutputDataSource:device.dataSource error:&error];
    if (error)
    {
        NSLog(@"Error setting output device data source (%@), reason: %@",
              device.dataSource,
              error.localizedDescription);
    }
    
#elif TARGET_OS_MAC
    UInt32 outputEnabled = device.outputChannelCount > 0;
    NSAssert(outputEnabled, @"Selected EZAudioDevice does not have any output channels");
    NSAssert([self outputAudioUnitSubType] == kAudioUnitSubType_HALOutput,
             @"Audio device selection on OSX is only available when using the kAudioUnitSubType_HALOutput output unit subtype");
    [EZAudioUtilities checkResult:AudioUnitSetProperty(self.info->outputNodeInfo.audioUnit,
                                                       kAudioOutputUnitProperty_EnableIO,
                                                       kAudioUnitScope_Output,
                                                       0,
                                                       &outputEnabled,
                                                       sizeof(outputEnabled))
                        operation:"Failed to set flag on device output"];
    
    AudioDeviceID deviceId = device.deviceID;
    [EZAudioUtilities checkResult:AudioUnitSetProperty(self.info->outputNodeInfo.audioUnit,
                                                       kAudioOutputUnitProperty_CurrentDevice,
                                                       kAudioUnitScope_Global,
                                                       0,
                                                       &deviceId,
                                                       sizeof(AudioDeviceID))
                        operation:"Couldn't set default device on I/O unit"];
#endif
    
    // store device
    _device = device;
    
    // notify delegate
    if ([self.delegate respondsToSelector:@selector(output:changedDevice:)])
    {
        [self.delegate output:self changedDevice:device];
    }
}

//------------------------------------------------------------------------------

- (void)setInputFormat:(AudioStreamBasicDescription)inputFormat
{
    self.info->inputFormat = inputFormat;
    [EZAudioUtilities checkResult:AudioUnitSetProperty(self.info->converterNodeInfo.audioUnit,
                                                       kAudioUnitProperty_StreamFormat,
                                                       kAudioUnitScope_Input,
                                                       0,
                                                       &inputFormat,
                                                       sizeof(inputFormat))
                        operation:"Failed to set input format on converter audio unit"];
}

//------------------------------------------------------------------------------

- (void)setPan:(float)pan
{
    AudioUnitParameterID param;
#if TARGET_OS_IPHONE
    param = kMultiChannelMixerParam_Pan;
#elif TARGET_OS_MAC
    param = kStereoMixerParam_Pan;
#endif
    [EZAudioUtilities checkResult:AudioUnitSetParameter(self.info->mixerNodeInfo.audioUnit,
                                                        param,
                                                        kAudioUnitScope_Input,
                                                        0,
                                                        pan,
                                                        0)
                        operation:"Failed to set volume on mixer unit"];
}

//------------------------------------------------------------------------------

- (void)setVolume:(float)volume
{
    AudioUnitParameterID param;
#if TARGET_OS_IPHONE
    param = kMultiChannelMixerParam_Volume;
#elif TARGET_OS_MAC
    param = kStereoMixerParam_Volume;
#endif
    [EZAudioUtilities checkResult:AudioUnitSetParameter(self.info->mixerNodeInfo.audioUnit,
                                                        param,
                                                        kAudioUnitScope_Input,
                                                        0,
                                                        volume,
                                                        0)
                        operation:"Failed to set volume on mixer unit"];
}

//------------------------------------------------------------------------------
#pragma mark - Core Audio Properties
//------------------------------------------------------------------------------

- (AUGraph)graph
{
    return self.info->graph;
}

//------------------------------------------------------------------------------

- (AudioUnit)converterAudioUnit
{
    return self.info->converterNodeInfo.audioUnit;
}

//------------------------------------------------------------------------------

- (AudioUnit)mixerAudioUnit
{
    return self.info->mixerNodeInfo.audioUnit;
}

//------------------------------------------------------------------------------

- (AudioUnit)outputAudioUnit
{
    return self.info->outputNodeInfo.audioUnit;
}

//------------------------------------------------------------------------------
#pragma mark - Subclass
//------------------------------------------------------------------------------

- (OSStatus)connectOutputOfSourceNode:(AUNode)sourceNode
                  sourceNodeOutputBus:(UInt32)sourceNodeOutputBus
                    toDestinationNode:(AUNode)destinationNode
              destinationNodeInputBus:(UInt32)destinationNodeInputBus
                              inGraph:(AUGraph)graph
{
    //
    // Default implementation is to just connect the source to destination
    //
    [EZAudioUtilities checkResult:AUGraphConnectNodeInput(graph,
                                                          sourceNode,
                                                          sourceNodeOutputBus,
                                                          destinationNode,
                                                          destinationNodeInputBus)
                        operation:"Failed to connect converter node to mixer node"];
    return noErr;
}

//------------------------------------------------------------------------------

- (AudioStreamBasicDescription)defaultClientFormat
{
    return [EZAudioUtilities stereoFloatNonInterleavedFormatWithSampleRate:EZOutputDefaultSampleRate];
}

//------------------------------------------------------------------------------

- (AudioStreamBasicDescription)defaultInputFormat
{
    return [EZAudioUtilities stereoFloatNonInterleavedFormatWithSampleRate:EZOutputDefaultSampleRate];
}

//------------------------------------------------------------------------------

- (OSType)outputAudioUnitSubType
{
#if TARGET_OS_IPHONE
    return kAudioUnitSubType_RemoteIO;
#elif TARGET_OS_MAC
    return kAudioUnitSubType_HALOutput;
#endif
}

//------------------------------------------------------------------------------

@end

//------------------------------------------------------------------------------
#pragma mark - Callbacks (Implementation)
//------------------------------------------------------------------------------

OSStatus EZOutputConverterInputCallback(void                       *inRefCon,
                                        AudioUnitRenderActionFlags *ioActionFlags,
                                        const AudioTimeStamp       *inTimeStamp,
                                        UInt32					    inBusNumber,
                                        UInt32					    inNumberFrames,
                                        AudioBufferList            *ioData)
{
    EZOutput *output = (__bridge EZOutput *)inRefCon;
    
    //
    // Try to ask the data source for audio data to fill out the output's
    // buffer list
    //
    if ([output.dataSource respondsToSelector:@selector(output:shouldFillAudioBufferList:withNumberOfFrames:timestamp:)])
    {
        return [output.dataSource output:output
               shouldFillAudioBufferList:ioData
                      withNumberOfFrames:inNumberFrames
                               timestamp:inTimeStamp];
    }
    else
    {
        //
        // Silence if there is nothing to output
        //
        for (int i = 0; i < ioData->mNumberBuffers; i++)
        {
            memset(ioData->mBuffers[i].mData,
                   0,
                   ioData->mBuffers[i].mDataByteSize);
        }
    }
    return noErr;
}

//------------------------------------------------------------------------------

OSStatus EZOutputGraphRenderCallback(void                       *inRefCon,
                                     AudioUnitRenderActionFlags *ioActionFlags,
                                     const AudioTimeStamp       *inTimeStamp,
                                     UInt32					     inBusNumber,
                                     UInt32                      inNumberFrames,
                                     AudioBufferList            *ioData)
{
    EZOutput *output = (__bridge EZOutput *)inRefCon;

    //
    // provide the audio received delegate callback
    //
    if (*ioActionFlags & kAudioUnitRenderAction_PostRender)
    {
        if ([output.delegate respondsToSelector:@selector(output:playedAudio:withBufferSize:withNumberOfChannels:)])
        {
            UInt32 frames = ioData->mBuffers[0].mDataByteSize / output.info->clientFormat.mBytesPerFrame;
            [output.floatConverter convertDataFromAudioBufferList:ioData
                                               withNumberOfFrames:frames
                                                   toFloatBuffers:output.info->floatData];
            [output.delegate output:output
                        playedAudio:output.info->floatData
                     withBufferSize:inNumberFrames
               withNumberOfChannels:output.info->clientFormat.mChannelsPerFrame];
        }
    }
    return noErr;
}