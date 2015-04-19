/*
 
 CsoundObj.m:
 
 Copyright (C) 2014 Steven Yi, Victor Lazzarini, Aurelius Prochazka
 Copyright (C) 2015 Stephane Peter

 This file is part of Csound for iOS and OS X.
 
 The Csound for iOS Library is free software; you can redistribute it
 and/or modify it under the terms of the GNU Lesser General Public
 License as published by the Free Software Foundation; either
 version 2.1 of the License, or (at your option) any later version.
 
 Csound is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU Lesser General Public License for more details.
 
 You should have received a copy of the GNU Lesser General Public
 License along with Csound; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
 02111-1307 USA
 
 */

@import AVFoundation;

#import <TargetConditionals.h>

#import "CsoundObj.h"
//#import "CsoundMIDI.h"

OSStatus  Csound_Render(void *inRefCon,
                        AudioUnitRenderActionFlags *ioActionFlags,
                        const AudioTimeStamp *inTimeStamp,
                        UInt32 dump,
                        UInt32 inNumberFrames,
                        AudioBufferList *ioData);

@interface CsoundObj ()
{
    CSOUND *_cs;
    long _bufframes;
    int _ret;
    int _nchnls;
    int _nsmps;
    int _nchnls_i;
    ExtAudioFileRef _file;
    AudioUnit *_aunit;
}

@property BOOL running, shouldRecord, shouldMute;

@property (strong) NSMutableArray *listeners;
@property (weak)   NSMutableArray *valuesCache;

@property (strong) NSThread *thread;

- (void)runCsound:(NSString *)csdFilePath;
- (void)runCsoundToDisk:(NSArray *)paths;

@end

@implementation CsoundObj

- (instancetype)init
{
    self = [super init];
    if (self) {
        _shouldMute = NO;
        _bindings = [[NSMutableArray alloc] init];
        _listeners = [[NSMutableArray alloc] init];
        _midiInEnabled = NO;
        _useAudioInput = YES;
    }
    
    return self;
}

// -----------------------------------------------------------------------------
#  pragma mark - CsoundObj Interface
// -----------------------------------------------------------------------------

- (void)sendScore:(NSString *)score
{
    if (_cs) {
        csoundInputMessage(_cs, (const char *)[score cStringUsingEncoding:NSASCIIStringEncoding]);
    }
}

- (void)play:(NSString *)csdFilePath
{
    self.shouldRecord = NO;
    self.thread = [[NSThread alloc] initWithTarget:self selector:@selector(runCsound:) object:csdFilePath];
    [self.thread start];
}

- (void)updateOrchestra:(NSString *)orchestraString
{
    if (_cs) {
        csoundCompileOrc(_cs, (const char *)[orchestraString cStringUsingEncoding:NSASCIIStringEncoding]);
    }
}

- (void)stop {
    self.running = NO;
    [self.thread cancel];
    while (!self.thread.finished) {
        [NSThread sleepForTimeInterval:0.01];
    }
}

- (void)mute {
    self.shouldMute = YES;
}

- (void)unmute {
    self.shouldMute = NO;
}

// -----------------------------------------------------------------------------
#  pragma mark - Recording
// -----------------------------------------------------------------------------

- (void)record:(NSString *)csdFilePath toURL:(NSURL *)outputURL
{
    self.shouldRecord = YES;
    self.outputURL = outputURL;
    self.thread = [[NSThread alloc] initWithTarget:self selector:@selector(runCsound:) object:csdFilePath];
    [self.thread start];
}

- (void)record:(NSString *)csdFilePath toFile:(NSString *)outputFile
{
    self.shouldRecord = NO;
    self.thread = [[NSThread alloc] initWithTarget:self selector:@selector(runCsoundToDisk:)
                                            object:@[csdFilePath, outputFile]];
    [self.thread start];
}

- (void)recordToURL:(NSURL *)outputURL_
{
    // Define format for the audio file.
    AudioStreamBasicDescription destFormat, clientFormat;
    memset(&destFormat, 0, sizeof(AudioStreamBasicDescription));
    memset(&clientFormat, 0, sizeof(AudioStreamBasicDescription));
    destFormat.mFormatID = kAudioFormatLinearPCM;
    destFormat.mFormatFlags = kLinearPCMFormatFlagIsPacked | kLinearPCMFormatFlagIsSignedInteger;
    destFormat.mSampleRate = csoundGetSr(_cs);
    destFormat.mChannelsPerFrame = _nchnls;
    destFormat.mBytesPerPacket = _nchnls * 2;
    destFormat.mBytesPerFrame = _nchnls * 2;
    destFormat.mBitsPerChannel = 16;
    destFormat.mFramesPerPacket = 1;
    
    // Create the audio file.
    OSStatus err = noErr;
    CFURLRef fileURL = (__bridge CFURLRef)outputURL_;
    err = ExtAudioFileCreateWithURL(fileURL, kAudioFileWAVEType, &destFormat, NULL, kAudioFileFlags_EraseFile, &_file);
    if (err == noErr) {
#if TARGET_OS_IPHONE // Not on Mac?
        // Get the stream format from the AU...
        UInt32 propSize = sizeof(AudioStreamBasicDescription);
        AudioUnitGetProperty(*_aunit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &clientFormat, &propSize);
        // ...and set it as the client format for the audio file. The file will use this
        // format to perform any necessary conversions when asked to read or write.
        ExtAudioFileSetProperty(_file, kExtAudioFileProperty_ClientDataFormat, sizeof(clientFormat), &clientFormat);
        // Warm the file up.
#endif
        ExtAudioFileWriteAsync(_file, 0, NULL);
    } else {
        NSLog(@"***Not recording. Error: %@", @(err));
        err = noErr;
    }
    
    self.shouldRecord = YES;
}

- (void)stopRecording
{
    self.shouldRecord = NO;
    ExtAudioFileDispose(_file);
}

// -----------------------------------------------------------------------------
#  pragma mark - Bindings
// -----------------------------------------------------------------------------

- (void)addBinding:(id<CsoundBinding>)binding
{
    if (binding != nil) {
        @synchronized(self.bindings) {
            if (self.running)
                [binding setup:self];
            [self.bindings addObject:binding];
        }
    }
}

- (void)removeBinding:(id<CsoundBinding>)binding
{
    if (binding != nil) {
        @synchronized(self.bindings) {
            [self.bindings removeObject:binding];
        }
    }
}

- (void)setupBindings
{
    @synchronized(self.bindings) {
        for (id<CsoundBinding> binding in self.bindings) {
            [binding setup:self];
        }
    }
}

- (void)cleanupBindings
{
    @synchronized(self.bindings) {
        for (id<CsoundBinding> binding in self.bindings) {
            if ([binding respondsToSelector:@selector(cleanup)]) {
                [binding cleanup];
            }
        }
    }
}

- (void)updateAllValuesToCsound
{
    @synchronized(self.bindings) {
        for (id<CsoundBinding> binding in self.bindings) {
            if ([binding respondsToSelector:@selector(updateValuesToCsound)]) {
                [binding updateValuesToCsound];
            }
        }
    }
}

- (void)updateAllValuesFromCsound
{
    @synchronized(self.bindings) {
        for (id<CsoundBinding> binding in self.bindings) {
            if ([binding respondsToSelector:@selector(updateValuesFromCsound)]) {
                [binding updateValuesFromCsound];
            }
        }
    }
}

// -----------------------------------------------------------------------------
#  pragma mark - Listeners and Messages
// -----------------------------------------------------------------------------

- (void)addListener:(id<CsoundObjListener>)listener {
    @synchronized(self.listeners) {
        [self.listeners addObject:listener];
    }
}

- (void)notifyListenersOfStartup
{
    @synchronized(self.listeners) {
        for (id<CsoundObjListener> listener in self.listeners) {
            if ([listener respondsToSelector:@selector(csoundObjStarted:)]) {
                [listener csoundObjStarted:self];
            }
        }
    }
}
- (void)notifyListenersOfCompletion
{
    @synchronized(self.listeners) {
        for (id<CsoundObjListener> listener in self.listeners) {
            if ([listener respondsToSelector:@selector(csoundObjCompleted:)]) {
                [listener csoundObjCompleted:self];
            }
        }
    }
}

static void messageCallback(CSOUND *cs, int attr, const char *format, va_list valist)
{
    @autoreleasepool {
        CsoundObj *obj = (__bridge CsoundObj *)csoundGetHostData(cs);
        if (obj.messageDelegate) {
            char message[1024];
            vsnprintf(message, 1024, format, valist);
            
            [obj.messageDelegate messageReceivedFrom:obj attr:attr message:[NSString stringWithUTF8String:message]];
        }
    }
}

// -----------------------------------------------------------------------------
#  pragma mark - Csound Internals / Advanced Methods
// -----------------------------------------------------------------------------

- (CSOUND *)getCsound
{
    if (self.running) {
        return _cs;
    }
    return nil;
}

- (AudioUnit *)getAudioUnit
{
    if (self.running) {
        return _aunit;
    }
    return nil;
}

- (MYFLT *)getInputChannelPtr:(NSString *)channelName channelType:(controlChannelType)channelType
{
    MYFLT *value;
    csoundGetChannelPtr(_cs, &value, [channelName cStringUsingEncoding:NSASCIIStringEncoding],
                        channelType | CSOUND_INPUT_CHANNEL);
    return value;
}

- (MYFLT *)getOutputChannelPtr:(NSString *)channelName channelType:(controlChannelType)channelType
{
    MYFLT *value;
    csoundGetChannelPtr(_cs, &value, [channelName cStringUsingEncoding:NSASCIIStringEncoding],
                        channelType | CSOUND_OUTPUT_CHANNEL);
    return value;
}

- (NSData *)getOutSamples
{
    if (!self.running) {
        return nil;
    }
    CSOUND *csound = self.csound;
    MYFLT *spout = csoundGetSpout(csound);
    int nchnls = csoundGetNchnls(csound);
    int ksmps = csoundGetKsmps(csound);
    return [NSData dataWithBytes:spout length:(nchnls * ksmps * sizeof(MYFLT))];
}

- (NSMutableData *)getMutableOutSamples
{
    if (!self.running) {
        return nil;
    }
    CSOUND *csound = self.csound;
    MYFLT *spout = csoundGetSpout(csound);
    int nchnls = csoundGetNchnls(csound);
    int ksmps = csoundGetKsmps(csound);
    return [NSMutableData dataWithBytes:spout length:(nchnls * ksmps * sizeof(MYFLT))];
}

- (NSData *)getInSamples
{
    if (!self.running) {
        return nil;
    }
    CSOUND *csound = self.csound;
    MYFLT *spin = csoundGetSpin(csound);
    int nchnls = csoundGetNchnls(csound);
    int ksmps = csoundGetKsmps(csound);
    return [NSData dataWithBytes:spin length:(nchnls * ksmps * sizeof(MYFLT))];
}

- (NSMutableData *)getMutableInSamples
{
    if (!self.running) {
        return nil;
    }
    CSOUND *csound = self.csound;
    MYFLT *spin = csoundGetSpin(csound);
    int nchnls = csoundGetNchnls(csound);
    int ksmps = csoundGetKsmps(csound);
    return [NSMutableData dataWithBytes:spin length:(nchnls * ksmps * sizeof(MYFLT))];
}

- (int)getNumChannels
{
    if (!self.running) {
        return -1;
    }
    return csoundGetNchnls(_cs);
}

- (int)getKsmps
{
    if (!self.running) {
        return -1;
    }
    return csoundGetKsmps(_cs);
}

#pragma mark Csound Code

OSStatus  Csound_Render(void *inRefCon,
                        AudioUnitRenderActionFlags *ioActionFlags,
                        const AudioTimeStamp *inTimeStamp,
                        UInt32 dump,
                        UInt32 inNumberFrames,
                        AudioBufferList *ioData)
{
    CsoundObj *obj = (__bridge CsoundObj *)inRefCon;
    CSOUND *cs = obj.csound;

    int ret = obj->_ret, nchnls = obj->_nchnls;
    
    int ksmps = csoundGetKsmps(cs);
    MYFLT *spin = csoundGetSpin(cs);
    MYFLT *spout = csoundGetSpout(cs);
#if TARGET_OS_IPHONE
    int k;
    int frame;
    int nsmps = obj->_nsmps;
    int insmps = nsmps;
    SInt32 *buffer;
    float coef = (float) INT_MAX / csoundGet0dBFS(cs);
#elif TARGET_OS_MAC
    int i, j, k;
    int slices = inNumberFrames/ksmps;
    Float32 *buffer;
#endif
    
    AudioUnitRender(*obj->_aunit, ioActionFlags, inTimeStamp, 1, inNumberFrames, ioData);
    NSMutableArray* cache = obj.valuesCache;
    
#if TARGET_OS_IPHONE
    for(frame=0;frame < inNumberFrames;frame++){
        @autoreleasepool {
            if(obj.useAudioInput) {
                for (k = 0; k < nchnls; k++){
                    buffer = (SInt32 *) ioData->mBuffers[k].mData;
                    spin[insmps++] =(1./coef)*buffer[frame];
                }
            }
            
            for (k = 0; k < nchnls; k++) {
                buffer = (SInt32 *) ioData->mBuffers[k].mData;
                if (obj.shouldMute == NO) {
                    buffer[frame] = (SInt32) lrintf(spout[nsmps++]*coef) ;
                } else {
                    buffer[frame] = 0;
                }
            }
            
            if(nsmps == ksmps*nchnls){
                for(id<CsoundBinding> binding in cache) {
                    if ([binding respondsToSelector:@selector(updateValuesToCsound)]) {
                        [binding updateValuesToCsound];
                    }
                }
                if(!ret) {
                    ret = csoundPerformKsmps(cs);
                } else {
                    obj.running = false;
                }
                for(id<CsoundBinding> binding in cache) {
                    if ([binding respondsToSelector:@selector(updateValuesFromCsound)]) {
                        [binding updateValuesFromCsound];
                    }
                }
                insmps = nsmps = 0;
            }
        }
    }
#elif TARGET_OS_MAC
    for(i=0; i < slices; i++){
        @autoreleasepool {
            for(id<CsoundBinding> binding in cache) {
                if ([binding respondsToSelector:@selector(updateValuesToCsound)]) {
                    [binding updateValuesToCsound];
                }
            }
            
            /* performance */
            if(obj.useAudioInput) {
                for (k = 0; k < nchnls; k++){
                    buffer = (Float32 *) ioData->mBuffers[k].mData;
                    for(j=0; j < ksmps; j++){
                        spin[j*nchnls+k] = buffer[j+i*ksmps];
                    }
                }
            }
            if(!ret) {
                ret = csoundPerformKsmps(cs);
            } else {
                obj.running = NO;
            }
            
            for (k = 0; k < nchnls; k++) {
                buffer = (Float32 *) ioData->mBuffers[k].mData;
                if (obj.shouldMute == NO) {
                    for(j=0; j < ksmps; j++){
                        buffer[j+i*ksmps] = (Float32) spout[j*nchnls+k];
                    }
                } else {
                    memset(buffer, 0, sizeof(Float32) * inNumberFrames);
                }
            }
            
            for(id<CsoundBinding> binding in cache) {
                if ([binding respondsToSelector:@selector(updateValuesFromCsound)]) {
                    [binding updateValuesFromCsound];
                }
            }
        }
    }
#endif
    
    // Write to file.
    if (obj.shouldRecord) {
        OSStatus err = ExtAudioFileWriteAsync(obj->_file, inNumberFrames, ioData);
        if (err != noErr) {
            NSLog(@"***Error writing to file: %@", @(err));
        }
    }
    
#if TARGET_OS_IPHONE
    obj->_nsmps = nsmps;
#endif
    obj->_ret = ret;
    return 0;
}

- (void)runCsoundToDisk:(NSArray *)paths
{
    @autoreleasepool {
        CSOUND *cs;
        
        cs = csoundCreate(NULL);
        
        char *argv[] = { "csound", (char*)[paths[0] cStringUsingEncoding:NSASCIIStringEncoding],
                         "-o", (char*)[paths[1] cStringUsingEncoding:NSASCIIStringEncoding]};
        int ret = csoundCompile(cs, 4, argv);
        
        [self setupBindings];
        [self notifyListenersOfStartup];
        
        [self updateAllValuesToCsound];
        
        if(!ret) {
            csoundPerform(cs);
            csoundCleanup(cs);
            csoundDestroy(cs);
        }
        
        [self cleanupBindings];
        [self notifyListenersOfCompletion];
    }
}

- (void)runCsound:(NSString *)csdFilePath
{
    @autoreleasepool {
        CSOUND *cs;
        
        cs = csoundCreate(NULL);
#if TARGET_OS_IPHONE
        csoundSetHostImplementedAudioIO(cs, 1, 0);
#endif
        csoundSetMessageCallback(cs, messageCallback);
        csoundSetHostData(cs, (__bridge void *)self);
        
        if (self.midiInEnabled) {
//            [CsoundMIDI setMidiInCallbacks:cs];
        }
        
#if TARGET_OS_IPHONE
        char *argv[] = { "csound",
# ifdef TRAVIS_CI
            "-+rtaudio=null",
# else
            "-+rtaudio=coreaudio",
# endif            
                        (char*)[csdFilePath cStringUsingEncoding:NSASCIIStringEncoding]};
#else
        char *argv[] = { "csound", "-+ignore_csopts=0",
# ifdef TRAVIS_CI
                         "-+rtaudio=null",
# else
                         "-+rtaudio=coreaudio",
# endif
                         "-b256", (char*)[csdFilePath cStringUsingEncoding:NSASCIIStringEncoding]};
#endif
        
        int ret = csoundCompile(cs, sizeof(argv)/sizeof(char *), argv);
        _running = true;
        _nsmps = 0;
        
        if(!ret) {
            _cs = cs;
            _ret = ret;
            _nchnls = csoundGetNchnls(cs);
            _bufframes = (csoundGetOutputBufferSize(cs))/_nchnls;
            self.running = YES;
            self.valuesCache = _bindings;
            
            [self setupBindings];
            
#if TARGET_OS_IPHONE
            AudioStreamBasicDescription format;
            OSStatus err;
            NSError* error;
            BOOL success;

            /* Audio Session handler */
            AVAudioSession* session = [AVAudioSession sharedInstance];
            
            if (_useAudioInput) {
                success = [session setCategory:AVAudioSessionCategoryPlayAndRecord
                                   withOptions:(AVAudioSessionCategoryOptionMixWithOthers |
                                                AVAudioSessionCategoryOptionDefaultToSpeaker)
                                         error:&error];
            } else {
                success = [session setCategory:AVAudioSessionCategoryPlayback
                                   withOptions:(AVAudioSessionCategoryOptionMixWithOthers | AVAudioSessionCategoryOptionDefaultToSpeaker)
                                         error:&error];
            }
            
            
            //            success = [session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&error];
            
            Float32 preferredBufferSize = _bufframes / csoundGetSr(cs);
            [session setPreferredIOBufferDuration:preferredBufferSize error:&error];
            
            success = [session setActive:YES error:&error];
            if(!success) {
                // Do something here?
            }
            
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(handleInterruption:)
                                                         name:AVAudioSessionInterruptionNotification
                                                       object:session];
            
            AudioComponentDescription cd = {kAudioUnitType_Output, kAudioUnitSubType_RemoteIO, kAudioUnitManufacturer_Apple, 0, 0};
            AudioComponent HALOutput = AudioComponentFindNext(NULL, &cd);
            
            AudioUnit csAUHAL;
            err = AudioComponentInstanceNew(HALOutput, &csAUHAL);
            
            if(!err) {
                
                _aunit = &csAUHAL;
                UInt32 enableIO = 1;
                AudioUnitSetProperty(csAUHAL, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Output, 0, &enableIO, sizeof(enableIO));
                if (self.useAudioInput) {
                    AudioUnitSetProperty(csAUHAL, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Input, 1, &enableIO, sizeof(enableIO));
                }
                
                if (enableIO) {
                    UInt32 maxFPS;
                    UInt32 outsize;
                    int elem;
                    for(elem = self.useAudioInput ? 1 : 0; elem >= 0; elem--){
                        outsize = sizeof(maxFPS);
                        AudioUnitGetProperty(csAUHAL, kAudioUnitProperty_MaximumFramesPerSlice, kAudioUnitScope_Global, elem, &maxFPS, &outsize);
                        AudioUnitSetProperty(csAUHAL, kAudioUnitProperty_MaximumFramesPerSlice, kAudioUnitScope_Global, elem, (UInt32*)&_bufframes, sizeof(UInt32));
                        outsize = sizeof(AudioStreamBasicDescription);
                        AudioUnitGetProperty(csAUHAL, kAudioUnitProperty_StreamFormat, (elem ? kAudioUnitScope_Output : kAudioUnitScope_Input), elem, &format, &outsize);
                        format.mSampleRate	= csoundGetSr(cs);
                        format.mFormatID = kAudioFormatLinearPCM;
                        format.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagsNativeEndian | kAudioFormatFlagIsPacked | kLinearPCMFormatFlagIsNonInterleaved;
                        format.mBytesPerPacket = sizeof(SInt32);
                        format.mFramesPerPacket = 1;
                        format.mBytesPerFrame = sizeof(SInt32);
                        format.mChannelsPerFrame = _nchnls;
                        format.mBitsPerChannel = sizeof(SInt32)*8;
                        err = AudioUnitSetProperty(csAUHAL, kAudioUnitProperty_StreamFormat, (elem ? kAudioUnitScope_Output : kAudioUnitScope_Input), elem, &format, sizeof(AudioStreamBasicDescription));
                    }
                    
                    if (self.shouldRecord) {
                        
                        // Define format for the audio file.
                        AudioStreamBasicDescription destFormat, clientFormat;
                        memset(&destFormat, 0, sizeof(AudioStreamBasicDescription));
                        memset(&clientFormat, 0, sizeof(AudioStreamBasicDescription));
                        destFormat.mFormatID = kAudioFormatLinearPCM;
                        destFormat.mFormatFlags = kLinearPCMFormatFlagIsPacked | kLinearPCMFormatFlagIsSignedInteger;
                        destFormat.mSampleRate = csoundGetSr(cs);
                        destFormat.mChannelsPerFrame = _nchnls;
                        destFormat.mBytesPerPacket = _nchnls * 2;
                        destFormat.mBytesPerFrame = _nchnls * 2;
                        destFormat.mBitsPerChannel = 16;
                        destFormat.mFramesPerPacket = 1;
                        
                        // Create the audio file.
                        CFURLRef fileURL = (__bridge CFURLRef)self.outputURL;
                        err = ExtAudioFileCreateWithURL(fileURL, kAudioFileWAVEType, &destFormat, NULL, kAudioFileFlags_EraseFile, &_file);
                        if (err == noErr) {
                            // Get the stream format from the AU...
                            UInt32 propSize = sizeof(AudioStreamBasicDescription);
                            AudioUnitGetProperty(csAUHAL, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &clientFormat, &propSize);
                            // ...and set it as the client format for the audio file. The file will use this
                            // format to perform any necessary conversions when asked to read or write.
                            ExtAudioFileSetProperty(_file, kExtAudioFileProperty_ClientDataFormat, sizeof(clientFormat), &clientFormat);
                            // Warm the file up.
                            ExtAudioFileWriteAsync(_file, 0, NULL);
                        } else {
                            NSLog(@"***Not recording. Error: %@", @(err));
                            err = noErr;
                        }
                    }
                    
                    if(!err) {
                        AURenderCallbackStruct output;
                        output.inputProc = Csound_Render;
                        output.inputProcRefCon = (__bridge void *)self;
                        AudioUnitSetProperty(csAUHAL, kAudioUnitProperty_SetRenderCallback, kAudioUnitScope_Input, 0, &output, sizeof(output));
                        AudioUnitInitialize(csAUHAL);
                        
                        err = AudioOutputUnitStart(csAUHAL);
                        
                        [self notifyListenersOfStartup];
                        
                        if(!err) {
                            while (!_ret && self.running) {
                                [NSThread sleepForTimeInterval:.001];
                            }
                        }
                        
                        ExtAudioFileDispose(_file);
                        _shouldRecord = false;
                        AudioOutputUnitStop(csAUHAL);
                        /* free(CAInputData); */
                    }
                    AudioUnitUninitialize(csAUHAL);
                    AudioComponentInstanceDispose(csAUHAL);
                }
            }
            csoundDestroy(cs);
        }
#elif TARGET_OS_MAC
        float coef = (float) SHRT_MAX / csoundGet0dBFS(cs);
        
        MYFLT* spout = csoundGetSpout(cs);
        AudioBufferList bufferList;
        bufferList.mNumberBuffers = 1;
        
        [self notifyListenersOfStartup];
        
        if (self.shouldRecord) {
            [self recordToURL:self.outputURL];
            bufferList.mBuffers[0].mNumberChannels = _nchnls;
            bufferList.mBuffers[0].mDataByteSize = _nchnls * csoundGetKsmps(cs) * 2; // 16-bit PCM output
            bufferList.mBuffers[0].mData = malloc(sizeof(short) * _nchnls * csoundGetKsmps(cs));
        }
        
        while (!_ret && self.running) {
            [self updateAllValuesToCsound];
            
            _ret = csoundPerformKsmps(_cs);
            
            // Write to file.
            if (self.shouldRecord) {
                short* data = (short*)bufferList.mBuffers[0].mData;
                for (int i = 0; i < csoundGetKsmps(cs) * _nchnls; i++) {
                    data[i] = (short)lrintf(spout[i] * coef);
                }
                OSStatus err = ExtAudioFileWriteAsync(_file, csoundGetKsmps(cs), &bufferList);
                if (err != noErr) {
                    NSLog(@"***Error writing to file: %@", @(err));
                }
 
            }
            [self updateAllValuesFromCsound];
        }
    }
    
    if (self.shouldRecord) {
        ExtAudioFileDispose(_file);
    }
    
    csoundDestroy(cs);
#endif
    
        self.running = NO;
    
        [self cleanupBindings];
        [self notifyListenersOfCompletion];
    }
}

#if TARGET_OS_IPHONE
- (void)handleInterruption:(NSNotification *)notification
{
    NSDictionary *interuptionDict = notification.userInfo;
    NSUInteger interuptionType = (NSUInteger)[interuptionDict
                                              valueForKey:AVAudioSessionInterruptionTypeKey];
    
    NSError *error;
    BOOL success;
    
    if (self.running) {
        if (interuptionType == AVAudioSessionInterruptionTypeBegan) {
            AudioOutputUnitStop(*_aunit);
        } else if (interuptionType == kAudioSessionEndInterruption) {
            // make sure we are again the active session
            success = [[AVAudioSession sharedInstance] setActive:YES error:&error];
            if(success) {
                AudioOutputUnitStart(*_aunit);
            }
        }
    }
}
#endif

@end
