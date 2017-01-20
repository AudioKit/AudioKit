//
//  EZMicrophone.m
//  EZAudio
//
//  Created by Syed Haris Ali on 9/2/13.
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

#import "EZMicrophone.h"
#import "EZAudioFloatConverter.h"
#import "EZAudioUtilities.h"
#import "EZAudioDevice.h"

//------------------------------------------------------------------------------
#pragma mark - Data Structures
//------------------------------------------------------------------------------

typedef struct EZMicrophoneInfo
{
    AudioUnit                     audioUnit;
    AudioBufferList              *audioBufferList;
    float                       **floatData;
    AudioStreamBasicDescription   inputFormat;
    AudioStreamBasicDescription   streamFormat;
} EZMicrophoneInfo;

//------------------------------------------------------------------------------
#pragma mark - Callbacks
//------------------------------------------------------------------------------

static OSStatus EZAudioMicrophoneCallback(void                       *inRefCon,
                                          AudioUnitRenderActionFlags *ioActionFlags,
                                          const AudioTimeStamp       *inTimeStamp,
                                          UInt32                      inBusNumber,
                                          UInt32                      inNumberFrames,
                                          AudioBufferList            *ioData);

//------------------------------------------------------------------------------
#pragma mark - EZMicrophone (Interface Extension)
//------------------------------------------------------------------------------

@interface EZMicrophone ()
@property (nonatomic, strong) EZAudioFloatConverter *floatConverter;
@property (nonatomic, assign) EZMicrophoneInfo      *info;
@end

@implementation EZMicrophone

//------------------------------------------------------------------------------
#pragma mark - Dealloc
//------------------------------------------------------------------------------

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [EZAudioUtilities checkResult:AudioUnitUninitialize(self.info->audioUnit)
                        operation:"Failed to unintialize audio unit for microphone"];
    [EZAudioUtilities freeBufferList:self.info->audioBufferList];
    [EZAudioUtilities freeFloatBuffers:self.info->floatData
                      numberOfChannels:self.info->streamFormat.mChannelsPerFrame];
    free(self.info);
}

//------------------------------------------------------------------------------
#pragma mark - Initialization
//------------------------------------------------------------------------------

- (id)init
{
    self = [super init];
    if(self)
    {
        self.info = (EZMicrophoneInfo *)malloc(sizeof(EZMicrophoneInfo));
        memset(self.info, 0, sizeof(EZMicrophoneInfo));
        [self setup];
    }
    return self;
}

//------------------------------------------------------------------------------

- (EZMicrophone *)initWithMicrophoneDelegate:(id<EZMicrophoneDelegate>)delegate
{
    self = [super init];
    if(self)
    {
        self.info = (EZMicrophoneInfo *)malloc(sizeof(EZMicrophoneInfo));
        memset(self.info, 0, sizeof(EZMicrophoneInfo));
        _delegate = delegate;
        [self setup];
    }
    return self;
}

//------------------------------------------------------------------------------

-(EZMicrophone *)initWithMicrophoneDelegate:(id<EZMicrophoneDelegate>)delegate
            withAudioStreamBasicDescription:(AudioStreamBasicDescription)audioStreamBasicDescription
{
    self = [self initWithMicrophoneDelegate:delegate];
    if(self)
    {
        [self setAudioStreamBasicDescription:audioStreamBasicDescription];
    }
    return self;
}

//------------------------------------------------------------------------------

- (EZMicrophone *)initWithMicrophoneDelegate:(id<EZMicrophoneDelegate>)delegate
                           startsImmediately:(BOOL)startsImmediately
{
    self = [self initWithMicrophoneDelegate:delegate];
    if(self)
    {
        startsImmediately ? [self startFetchingAudio] : -1;
    }
    return self;
}

//------------------------------------------------------------------------------

-(EZMicrophone *)initWithMicrophoneDelegate:(id<EZMicrophoneDelegate>)delegate
            withAudioStreamBasicDescription:(AudioStreamBasicDescription)audioStreamBasicDescription
                          startsImmediately:(BOOL)startsImmediately
{
    self = [self initWithMicrophoneDelegate:delegate
            withAudioStreamBasicDescription:audioStreamBasicDescription];
    if(self)
    {
        startsImmediately ? [self startFetchingAudio] : -1;
    }
    return self;
}

//------------------------------------------------------------------------------
#pragma mark - Class Initializers
//------------------------------------------------------------------------------

+ (EZMicrophone *)microphoneWithDelegate:(id<EZMicrophoneDelegate>)delegate
{
    return [[EZMicrophone alloc] initWithMicrophoneDelegate:delegate];
}

//------------------------------------------------------------------------------

+ (EZMicrophone *)microphoneWithDelegate:(id<EZMicrophoneDelegate>)delegate
         withAudioStreamBasicDescription:(AudioStreamBasicDescription)audioStreamBasicDescription
{
    return [[EZMicrophone alloc] initWithMicrophoneDelegate:delegate
                            withAudioStreamBasicDescription:audioStreamBasicDescription];
}

//------------------------------------------------------------------------------

+ (EZMicrophone *)microphoneWithDelegate:(id<EZMicrophoneDelegate>)delegate
                        startsImmediately:(BOOL)startsImmediately
{
    return [[EZMicrophone alloc] initWithMicrophoneDelegate:delegate
                                          startsImmediately:startsImmediately];
}

//------------------------------------------------------------------------------

+ (EZMicrophone *)microphoneWithDelegate:(id<EZMicrophoneDelegate>)delegate
         withAudioStreamBasicDescription:(AudioStreamBasicDescription)audioStreamBasicDescription
                       startsImmediately:(BOOL)startsImmediately
{
    return [[EZMicrophone alloc] initWithMicrophoneDelegate:delegate
                            withAudioStreamBasicDescription:audioStreamBasicDescription
                                          startsImmediately:startsImmediately];
}

//------------------------------------------------------------------------------
#pragma mark - Singleton
//------------------------------------------------------------------------------

+ (EZMicrophone *)sharedMicrophone
{
    static EZMicrophone *_sharedMicrophone = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedMicrophone = [[EZMicrophone alloc] init];
    });
    return _sharedMicrophone;
}

//------------------------------------------------------------------------------
#pragma mark - Setup
//------------------------------------------------------------------------------

- (void)setup
{
    // Create an input component description for mic input
    AudioComponentDescription inputComponentDescription;
    inputComponentDescription.componentType = kAudioUnitType_Output;
    inputComponentDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
#if TARGET_OS_IPHONE
    inputComponentDescription.componentSubType = kAudioUnitSubType_RemoteIO;
#elif TARGET_OS_MAC
    inputComponentDescription.componentSubType = kAudioUnitSubType_HALOutput;
#endif
    
    // get the first matching component
    AudioComponent inputComponent = AudioComponentFindNext( NULL , &inputComponentDescription);
    NSAssert(inputComponent, @"Couldn't get input component unit!");
    
    // create new instance of component
    [EZAudioUtilities checkResult:AudioComponentInstanceNew(inputComponent, &self.info->audioUnit)
                        operation:"Failed to get audio component instance"];
    
#if TARGET_OS_IPHONE
    // must enable input scope for remote IO unit
    UInt32 flag = 1;
    [EZAudioUtilities checkResult:AudioUnitSetProperty(self.info->audioUnit,
                                                       kAudioOutputUnitProperty_EnableIO,
                                                       kAudioUnitScope_Input,
                                                       1,
                                                       &flag,
                                                       sizeof(flag))
                        operation:"Couldn't enable input on remote IO unit."];
#endif
    [self setDevice:[EZAudioDevice currentInputDevice]];
    
    UInt32 propSize = sizeof(self.info->inputFormat);
    [EZAudioUtilities checkResult:AudioUnitGetProperty(self.info->audioUnit,
                                                       kAudioUnitProperty_StreamFormat,
                                                       kAudioUnitScope_Input,
                                                       1,
                                                       &self.info->inputFormat,
                                                       &propSize)
                        operation:"Failed to get stream format of microphone input scope"];
#if TARGET_OS_IPHONE
    self.info->inputFormat.mSampleRate = [[AVAudioSession sharedInstance] sampleRate];
    NSAssert(self.info->inputFormat.mSampleRate, @"Expected AVAudioSession sample rate to be greater than 0.0. Did you setup the audio session?");
#elif TARGET_OS_MAC
#endif
    [self setAudioStreamBasicDescription:[self defaultStreamFormat]];
    
    // render callback
    AURenderCallbackStruct renderCallbackStruct;
    renderCallbackStruct.inputProc = EZAudioMicrophoneCallback;
    renderCallbackStruct.inputProcRefCon = (__bridge void *)(self);
    [EZAudioUtilities checkResult:AudioUnitSetProperty(self.info->audioUnit,
                                                       kAudioOutputUnitProperty_SetInputCallback,
                                                       kAudioUnitScope_Global,
                                                       1,
                                                       &renderCallbackStruct,
                                                       sizeof(renderCallbackStruct))
                        operation:"Failed to set render callback"];
    
    [EZAudioUtilities checkResult:AudioUnitInitialize(self.info->audioUnit)
                        operation:"Failed to initialize input unit"];
    
    // setup notifications
    [self setupNotifications];
}

- (void)setupNotifications
{
#if TARGET_OS_IPHONE
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(microphoneWasInterrupted:)
                                                 name:AVAudioSessionInterruptionNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(microphoneRouteChanged:)
                                                 name:AVAudioSessionRouteChangeNotification
                                               object:nil];
#elif TARGET_OS_MAC
#endif
}

//------------------------------------------------------------------------------
#pragma mark - Notifications
//------------------------------------------------------------------------------

#if TARGET_OS_IPHONE

- (void)microphoneWasInterrupted:(NSNotification *)notification
{
    AVAudioSessionInterruptionType type = [notification.userInfo[AVAudioSessionInterruptionTypeKey] unsignedIntegerValue];
    switch (type)
    {
        case AVAudioSessionInterruptionTypeBegan:
        {
            [self stopFetchingAudio];
            break;
        }
        case AVAudioSessionInterruptionTypeEnded:
        {
            AVAudioSessionInterruptionOptions option = [notification.userInfo[AVAudioSessionInterruptionOptionKey] unsignedIntegerValue];
            if (option == AVAudioSessionInterruptionOptionShouldResume)
            {
                [self startFetchingAudio];
            }
            break;
        }
        default:
        {
            break;
        }
    }
}

//------------------------------------------------------------------------------

- (void)microphoneRouteChanged:(NSNotification *)notification
{
    EZAudioDevice *device = [EZAudioDevice currentInputDevice];
    [self setDevice:device];
}

#elif TARGET_OS_MAC
#endif

//------------------------------------------------------------------------------
#pragma mark - Events
//------------------------------------------------------------------------------

-(void)startFetchingAudio
{
    //
    // Start output unit
    //
    [EZAudioUtilities checkResult:AudioOutputUnitStart(self.info->audioUnit)
                        operation:"Failed to start microphone audio unit"];
    
    //
    // Notify delegate
    //
    if ([self.delegate respondsToSelector:@selector(microphone:changedPlayingState:)])
    {
        [self.delegate microphone:self changedPlayingState:YES];
    }
}

//------------------------------------------------------------------------------

-(void)stopFetchingAudio
{
    //
    // Stop output unit
    //
    [EZAudioUtilities checkResult:AudioOutputUnitStop(self.info->audioUnit)
                        operation:"Failed to stop microphone audio unit"];
    
    //
    // Notify delegate
    //
    if ([self.delegate respondsToSelector:@selector(microphone:changedPlayingState:)])
    {
        [self.delegate microphone:self changedPlayingState:NO];
    }
}

//------------------------------------------------------------------------------
#pragma mark - Getters
//------------------------------------------------------------------------------

-(AudioStreamBasicDescription)audioStreamBasicDescription
{
    return self.info->streamFormat;
}

//------------------------------------------------------------------------------

-(AudioUnit *)audioUnit
{
    return &self.info->audioUnit;
}

//------------------------------------------------------------------------------

- (UInt32)maximumBufferSize
{
    UInt32 maximumBufferSize;
    UInt32 propSize = sizeof(maximumBufferSize);
    [EZAudioUtilities checkResult:AudioUnitGetProperty(self.info->audioUnit,
                                                       kAudioUnitProperty_MaximumFramesPerSlice,
                                                       kAudioUnitScope_Global,
                                                       0,
                                                       &maximumBufferSize,
                                                       &propSize)
                        operation:"Failed to get maximum number of frames per slice"];
    return maximumBufferSize;
}

//------------------------------------------------------------------------------
#pragma mark - Setters
//------------------------------------------------------------------------------

- (void)setMicrophoneOn:(BOOL)microphoneOn
{
    _microphoneOn = microphoneOn;
    if (microphoneOn)
    {
        [self startFetchingAudio];
    }
    else {
        [self stopFetchingAudio];
    }
}

//------------------------------------------------------------------------------

- (void)setAudioStreamBasicDescription:(AudioStreamBasicDescription)asbd
{
    if (self.floatConverter)
    {
        [EZAudioUtilities freeBufferList:self.info->audioBufferList];
        [EZAudioUtilities freeFloatBuffers:self.info->floatData
                          numberOfChannels:self.info->streamFormat.mChannelsPerFrame];
    }
    
    // set new stream format
    self.info->streamFormat = asbd;
    [EZAudioUtilities checkResult:AudioUnitSetProperty(self.info->audioUnit,
                                                       kAudioUnitProperty_StreamFormat,
                                                       kAudioUnitScope_Input,
                                                       0,
                                                       &asbd,
                                                       sizeof(asbd))
                        operation:"Failed to set stream format on input scope"];
    [EZAudioUtilities checkResult:AudioUnitSetProperty(self.info->audioUnit,
                                                       kAudioUnitProperty_StreamFormat,
                                                       kAudioUnitScope_Output,
                                                       1,
                                                       &asbd,
                                                       sizeof(asbd))
                        operation:"Failed to set stream format on output scope"];
    
    // allocate float buffers
    UInt32 maximumBufferSize = [self maximumBufferSize];
    BOOL isInterleaved = [EZAudioUtilities isInterleaved:asbd];
    UInt32 channels = asbd.mChannelsPerFrame;
    self.floatConverter = [[EZAudioFloatConverter alloc] initWithInputFormat:asbd];
    self.info->floatData = [EZAudioUtilities floatBuffersWithNumberOfFrames:maximumBufferSize
                                                      numberOfChannels:channels];
    self.info->audioBufferList = [EZAudioUtilities audioBufferListWithNumberOfFrames:maximumBufferSize
                                                               numberOfChannels:channels
                                                                    interleaved:isInterleaved];
    
    // notify delegate
    if ([self.delegate respondsToSelector:@selector(microphone:hasAudioStreamBasicDescription:)])
    {
        [self.delegate microphone:self hasAudioStreamBasicDescription:asbd];
    }
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
    [[AVAudioSession sharedInstance] setPreferredInput:device.port error:&error];
    if (error)
    {
        NSLog(@"Error setting input device port (%@), reason: %@",
              device.port,
              error.localizedDescription);
    }
    else
    {
        if (device.dataSource)
        {
            [[AVAudioSession sharedInstance] setInputDataSource:device.dataSource error:&error];
            if (error)
            {
                NSLog(@"Error setting input data source (%@), reason: %@",
                      device.dataSource,
                      error.localizedDescription);
            }
        }
    }
    
#elif TARGET_OS_MAC
    UInt32 inputEnabled = device.inputChannelCount > 0;
    [EZAudioUtilities checkResult:AudioUnitSetProperty(self.info->audioUnit,
                                                       kAudioOutputUnitProperty_EnableIO,
                                                       kAudioUnitScope_Input,
                                                       1,
                                                       &inputEnabled,
                                                       sizeof(inputEnabled))
                        operation:"Failed to set flag on device input"];
    
    UInt32 outputEnabled = device.outputChannelCount > 0;
    [EZAudioUtilities checkResult:AudioUnitSetProperty(self.info->audioUnit,
                                                       kAudioOutputUnitProperty_EnableIO,
                                                       kAudioUnitScope_Output,
                                                       0,
                                                       &outputEnabled,
                                                       sizeof(outputEnabled))
                        operation:"Failed to set flag on device output"];
    
    AudioDeviceID deviceId = device.deviceID;
    [EZAudioUtilities checkResult:AudioUnitSetProperty(self.info->audioUnit,
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
    if ([self.delegate respondsToSelector:@selector(microphone:changedDevice:)])
    {
        [self.delegate microphone:self changedDevice:device];
    }
}

//------------------------------------------------------------------------------
#pragma mark - Output
//------------------------------------------------------------------------------

- (void)setOutput:(EZOutput *)output
{
    _output = output;
    _output.inputFormat = self.audioStreamBasicDescription;
    _output.dataSource = self;
}

//------------------------------------------------------------------------------
#pragma mark - EZOutputDataSource
//------------------------------------------------------------------------------

- (OSStatus)        output:(EZOutput *)output
 shouldFillAudioBufferList:(AudioBufferList *)audioBufferList
        withNumberOfFrames:(UInt32)frames
                 timestamp:(const AudioTimeStamp *)timestamp
{
    memcpy(audioBufferList,
           self.info->audioBufferList,
           sizeof(AudioBufferList) + (self.info->audioBufferList->mNumberBuffers - 1)*sizeof(AudioBuffer));
    return noErr;
}

//------------------------------------------------------------------------------
#pragma mark - Subclass
//------------------------------------------------------------------------------

- (AudioStreamBasicDescription)defaultStreamFormat
{
    return [EZAudioUtilities floatFormatWithNumberOfChannels:[self numberOfChannels]
                                                  sampleRate:self.info->inputFormat.mSampleRate];
}

//------------------------------------------------------------------------------

- (UInt32)numberOfChannels
{
#if TARGET_OS_IPHONE
    return 1;
#elif TARGET_OS_MAC
    return (UInt32)self.device.inputChannelCount;
#endif
}

//------------------------------------------------------------------------------

@end

//------------------------------------------------------------------------------
#pragma mark - Callbacks
//------------------------------------------------------------------------------

static OSStatus EZAudioMicrophoneCallback(void                       *inRefCon,
                                          AudioUnitRenderActionFlags *ioActionFlags,
                                          const AudioTimeStamp       *inTimeStamp,
                                          UInt32                      inBusNumber,
                                          UInt32                      inNumberFrames,
                                          AudioBufferList            *ioData)
{
    EZMicrophone *microphone = (__bridge EZMicrophone *)inRefCon;
    EZMicrophoneInfo *info = (EZMicrophoneInfo *)microphone.info;
    
    // render audio into buffer
    OSStatus result = AudioUnitRender(info->audioUnit,
                                      ioActionFlags,
                                      inTimeStamp,
                                      inBusNumber,
                                      inNumberFrames,
                                      info->audioBufferList);
    
    // notify delegate of new buffer list to process
    if ([microphone.delegate respondsToSelector:@selector(microphone:hasBufferList:withBufferSize:withNumberOfChannels:)])
    {
        [microphone.delegate microphone:microphone
                          hasBufferList:info->audioBufferList
                         withBufferSize:inNumberFrames
                   withNumberOfChannels:info->streamFormat.mChannelsPerFrame];
    }
    
    // notify delegate of new float data processed
    if ([microphone.delegate respondsToSelector:@selector(microphone:hasAudioReceived:withBufferSize:withNumberOfChannels:)])
    {
        // convert to float
        [microphone.floatConverter convertDataFromAudioBufferList:info->audioBufferList
                                               withNumberOfFrames:inNumberFrames
                                                   toFloatBuffers:info->floatData];
        [microphone.delegate microphone:microphone
                       hasAudioReceived:info->floatData
                         withBufferSize:inNumberFrames
                   withNumberOfChannels:info->streamFormat.mChannelsPerFrame];
    }
    
    return result;
}