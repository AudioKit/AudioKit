/*
 
 CsoundObj.m:
 
 Copyright (C) 2014 Steven Yi, Victor Lazzarini, Aurelius Prochazka
 
 This file is part of Csound for iOS.
 
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

#import <AudioToolbox/AudioConverter.h>
#import <AudioToolbox/AudioServices.h>
#import <AVFoundation/AVFoundation.h>

#import "CsoundObj.h"
//#import "CsoundMIDI.h"

OSStatus  Csound_Render(void *inRefCon,
                        AudioUnitRenderActionFlags *ioActionFlags,
                        const AudioTimeStamp *inTimeStamp,
                        UInt32 dump,
                        UInt32 inNumberFrames,
                        AudioBufferList *ioData);
void InterruptionListener(void *inClientData, UInt32 inInterruption);

@interface CsoundObj() {
    NSMutableArray *listeners;
    csdata mCsData;
    id  mMessageListener;
}

- (void)runCsound:(NSString *)csdFilePath;
- (void)runCsoundToDisk:(NSArray *)paths;

@end

@implementation CsoundObj

- (id)init
{
    self = [super init];
    if (self) {
        mCsData.shouldMute = false;
        _bindings = [[NSMutableArray alloc] init];
        listeners = [[NSMutableArray alloc] init];
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
    if (mCsData.cs != NULL) {
        csoundInputMessage(mCsData.cs, (char*)[score cStringUsingEncoding:NSASCIIStringEncoding]);
    }
}

- (void)play:(NSString *)csdFilePath
{
    mCsData.shouldRecord = false;
    [self performSelectorInBackground:@selector(runCsound:) withObject:csdFilePath];
}

- (void)updateOrchestra:(NSString *)orchestraString
{
    if (mCsData.cs != NULL) {
        csoundCompileOrc(mCsData.cs, (char*)[orchestraString cStringUsingEncoding:NSASCIIStringEncoding]);
    }
}

- (void)stop {
    mCsData.running = false;
}

- (void)mute {
    mCsData.shouldMute = true;
}

- (void)unmute {
    mCsData.shouldMute = false;
}

// -----------------------------------------------------------------------------
#  pragma mark - Recording
// -----------------------------------------------------------------------------

- (void)record:(NSString *)csdFilePath toURL:(NSURL *)outputURL
{
    mCsData.shouldRecord = true;
    self.outputURL = outputURL;
    [self performSelectorInBackground:@selector(runCsound:) withObject:csdFilePath];
}

- (void)record:(NSString *)csdFilePath toFile:(NSString *)outputFile
{
    mCsData.shouldRecord = false;
    
    [self performSelectorInBackground:@selector(runCsoundToDisk:)
                           withObject:[NSMutableArray arrayWithObjects:csdFilePath, outputFile, nil]];
}

- (void)recordToURL:(NSURL *)outputURL_
{
    // Define format for the audio file.
    AudioStreamBasicDescription destFormat, clientFormat;
    memset(&destFormat, 0, sizeof(AudioStreamBasicDescription));
    memset(&clientFormat, 0, sizeof(AudioStreamBasicDescription));
    destFormat.mFormatID = kAudioFormatLinearPCM;
    destFormat.mFormatFlags = kLinearPCMFormatFlagIsPacked | kLinearPCMFormatFlagIsSignedInteger;
    destFormat.mSampleRate = csoundGetSr(mCsData.cs);
    destFormat.mChannelsPerFrame = mCsData.nchnls;
    destFormat.mBytesPerPacket = mCsData.nchnls * 2;
    destFormat.mBytesPerFrame = mCsData.nchnls * 2;
    destFormat.mBitsPerChannel = 16;
    destFormat.mFramesPerPacket = 1;
    
    // Create the audio file.
    OSStatus err = noErr;
    CFURLRef fileURL = (__bridge CFURLRef)outputURL_;
    err = ExtAudioFileCreateWithURL(fileURL, kAudioFileWAVEType, &destFormat, NULL, kAudioFileFlags_EraseFile, &(mCsData.file));
    if (err == noErr) {
        // Get the stream format from the AU...
        UInt32 propSize = sizeof(AudioStreamBasicDescription);
        AudioUnitGetProperty(*(mCsData.aunit), kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &clientFormat, &propSize);
        // ...and set it as the client format for the audio file. The file will use this
        // format to perform any necessary conversions when asked to read or write.
        ExtAudioFileSetProperty(mCsData.file, kExtAudioFileProperty_ClientDataFormat, sizeof(clientFormat), &clientFormat);
        // Warm the file up.
        ExtAudioFileWriteAsync(mCsData.file, 0, NULL);
    } else {
        printf("***Not recording. Error: %d\n", (int)err);
        err = noErr;
    }
    
    mCsData.shouldRecord = true;
}

- (void)stopRecording
{
    mCsData.shouldRecord = false;
    ExtAudioFileDispose(mCsData.file);
}

// -----------------------------------------------------------------------------
#  pragma mark - Bindings
// -----------------------------------------------------------------------------

- (void)addBinding:(id<CsoundBinding>)binding
{
    if (binding != nil) {
        if (mCsData.running) [binding setup:self];
        [_bindings addObject:binding];
    }
}

- (void)removeBinding:(id<CsoundBinding>)binding
{
    if (binding != nil && [_bindings containsObject:binding]) {
        [_bindings removeObject:binding];
    }
}

- (void)setupBindings
{
    for (int i = 0; i < _bindings.count; i++) {
        id<CsoundBinding> binding = [_bindings objectAtIndex:i];
        [binding setup:self];
    }
}

- (void)cleanupBindings
{
    for (int i = 0; i < _bindings.count; i++) {
        id<CsoundBinding> binding = [_bindings objectAtIndex:i];
        if ([binding respondsToSelector:@selector(cleanup)]) {
            [binding cleanup];
        }
    }
}

- (void)updateAllValuesToCsound
{
    for (int i = 0; i < _bindings.count; i++) {
        id<CsoundBinding> binding = [_bindings objectAtIndex:i];
        if ([binding respondsToSelector:@selector(updateValuesToCsound)]) {
            [binding updateValuesToCsound];
        }
    }
}

// -----------------------------------------------------------------------------
#  pragma mark - Listeners and Messages
// -----------------------------------------------------------------------------

- (void)addListener:(id<CsoundObjListener>)listener {
    [listeners addObject:listener];
}

- (void)notifyListenersOfStartup
{
    for (id<CsoundObjListener> listener in listeners) {
        if ([listener respondsToSelector:@selector(csoundObjStarted:)]) {
            [listener csoundObjStarted:self];
        }
    }
}
- (void)notifyListenersOfCompletion
{
    for (id<CsoundObjListener> listener in listeners) {
        if ([listener respondsToSelector:@selector(csoundObjCompleted:)]) {
            [listener csoundObjCompleted:self];
        }
    }
}

static void messageCallback(CSOUND *cs, int attr, const char *format, va_list valist)
{
    @autoreleasepool {
        CsoundObj *obj = (__bridge CsoundObj *)(csoundGetHostData(cs));
        Message info;
        info.cs = cs;
        info.attr = attr;
        info.format = format;
        va_copy(info.valist,valist);
        NSValue *infoObj = [NSValue value:&info withObjCType:@encode(Message)];
        [obj performSelector:@selector(performMessageCallback:) withObject:infoObj];
    }
}

- (void)setMessageCallback:(SEL)method withListener:(id)listener
{
    self.messageCallbackSelector = method;
    mMessageListener = listener;
}

- (void)performMessageCallback:(NSValue *)infoObj
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [mMessageListener performSelector:self.messageCallbackSelector withObject:infoObj];
#pragma clang diagnostic pop
}

// -----------------------------------------------------------------------------
#  pragma mark - Csound Internals / Advanced Methods
// -----------------------------------------------------------------------------

- (CSOUND *)getCsound
{
    if (!mCsData.running) {
        return NULL;
    }
    return mCsData.cs;
}

- (AudioUnit *)getAudioUnit
{
    if (!mCsData.running) {
        return NULL;
    }
    return mCsData.aunit;
}

- (MYFLT *)getInputChannelPtr:(NSString *)channelName channelType:(controlChannelType)channelType
{
    MYFLT *value;
    csoundGetChannelPtr(mCsData.cs, &value, [channelName cStringUsingEncoding:NSASCIIStringEncoding],
                        channelType | CSOUND_INPUT_CHANNEL);
    return value;
}

- (MYFLT *)getOutputChannelPtr:(NSString *)channelName channelType:(controlChannelType)channelType
{
    MYFLT *value;
    csoundGetChannelPtr(mCsData.cs, &value, [channelName cStringUsingEncoding:NSASCIIStringEncoding],
                        channelType | CSOUND_OUTPUT_CHANNEL);
    return value;
}

- (NSData *)getOutSamples
{
    if (!mCsData.running) {
        return nil;
    }
    CSOUND *csound = [self getCsound];
    float *spout = csoundGetSpout(csound);
    int nchnls = csoundGetNchnls(csound);
    int ksmps = csoundGetKsmps(csound);
    return [NSData dataWithBytes:spout length:(nchnls * ksmps * sizeof(MYFLT))];
}

- (NSMutableData *)getMutableOutSamples
{
    if (!mCsData.running) {
        return nil;
    }
    CSOUND *csound = [self getCsound];
    float *spout = csoundGetSpout(csound);
    int nchnls = csoundGetNchnls(csound);
    int ksmps = csoundGetKsmps(csound);
    return [NSMutableData dataWithBytes:spout length:(nchnls * ksmps * sizeof(MYFLT))];
}

- (NSData *)getInSamples
{
    if (!mCsData.running) {
        return nil;
    }
    CSOUND *csound = [self getCsound];
    float *spin = csoundGetSpin(csound);
    int nchnls = csoundGetNchnls(csound);
    int ksmps = csoundGetKsmps(csound);
    return [NSData dataWithBytes:spin length:(nchnls * ksmps * sizeof(MYFLT))];
}

- (NSMutableData *)getMutableInSamples
{
    if (!mCsData.running) {
        return nil;
    }
    CSOUND *csound = [self getCsound];
    float *spin = csoundGetSpin(csound);
    int nchnls = csoundGetNchnls(csound);
    int ksmps = csoundGetKsmps(csound);
    return [NSMutableData dataWithBytes:spin length:(nchnls * ksmps * sizeof(MYFLT))];
}

- (int)getNumChannels
{
    if (!mCsData.running) {
        return -1;
    }
    return csoundGetNchnls(mCsData.cs);
}

- (int)getKsmps
{
    if (!mCsData.running) {
        return -1;
    }
    return csoundGetKsmps(mCsData.cs);
}

#pragma mark Csound Code

OSStatus  Csound_Render(void *inRefCon,
                        AudioUnitRenderActionFlags *ioActionFlags,
                        const AudioTimeStamp *inTimeStamp,
                        UInt32 dump,
                        UInt32 inNumberFrames,
                        AudioBufferList *ioData)
{
    csdata *cdata = (csdata *) inRefCon;
    int ret = cdata->ret, nchnls = cdata->nchnls;
    float coef = (float) INT_MAX / csoundGet0dBFS(cdata->cs);
    CSOUND *cs = cdata->cs;
    
    int k;
    int frame;
    int nsmps = cdata->nsmps;
    int insmps = nsmps;
    int ksmps = csoundGetKsmps(cs);
    MYFLT *spin = csoundGetSpin(cs);
    MYFLT *spout = csoundGetSpout(cs);
    SInt32 *buffer;
    
    AudioUnitRender(*cdata->aunit, ioActionFlags, inTimeStamp, 1, inNumberFrames, ioData);
    NSMutableArray* cache = cdata->valuesCache;
    
    
    for(frame=0;frame < inNumberFrames;frame++){
        @autoreleasepool {
            if(cdata->useAudioInput) {
                for (k = 0; k < nchnls; k++){
                    buffer = (SInt32 *) ioData->mBuffers[k].mData;
                    spin[insmps++] =(1./coef)*buffer[frame];
                }
            }
            
            for (k = 0; k < nchnls; k++) {
                buffer = (SInt32 *) ioData->mBuffers[k].mData;
                if (cdata->shouldMute == false) {
                    buffer[frame] = (SInt32) lrintf(spout[nsmps++]*coef) ;
                } else {
                    buffer[frame] = 0;
                }
            }
            
            if(nsmps == ksmps*nchnls){
                for (int i = 0; i < cache.count; i++) {
                    id<CsoundBinding> binding = [cache objectAtIndex:i];
                    if ([binding respondsToSelector:@selector(updateValuesToCsound)]) {
                        [binding updateValuesToCsound];
                    }
                }
                if(!ret) {
                    ret = csoundPerformKsmps(cdata->cs);
                } else {
                    cdata->running = false;
                }
                for (int i = 0; i < cache.count; i++) {
                    id<CsoundBinding> binding = [cache objectAtIndex:i];
                    if ([binding respondsToSelector:@selector(updateValuesFromCsound)]) {
                        [binding updateValuesFromCsound];
                    }
                }
                insmps = nsmps = 0;
            }
        }
    }
    
    // Write to file.
    if (cdata->shouldRecord) {
        OSStatus err = ExtAudioFileWriteAsync(cdata->file, inNumberFrames, ioData);
        if (err != noErr) {
            printf("***Error writing to file: %d\n", (int)err);
        }
    }
    
    cdata->nsmps = nsmps;
    cdata->ret = ret;
    return 0;
}

- (void)runCsoundToDisk:(NSArray *)paths
{
    @autoreleasepool {
        
        CSOUND *cs;
        
        cs = csoundCreate(NULL);
        
        char *argv[4] = { "csound",
            (char*)[[paths objectAtIndex:0] cStringUsingEncoding:NSASCIIStringEncoding], "-o", (char*)[[paths objectAtIndex:1] cStringUsingEncoding:NSASCIIStringEncoding]};
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
        NSError* error;
        BOOL success;
        
        cs = csoundCreate(NULL);
        csoundSetHostImplementedAudioIO(cs, 1, 0);
        
        csoundSetMessageCallback(cs, messageCallback);
        csoundSetHostData(cs, (__bridge void *)(self));
        
        if (_midiInEnabled) {
//            [CsoundMIDI setMidiInCallbacks:cs];
        }
        
        char *argv[2] = { "csound", (char*)[csdFilePath cStringUsingEncoding:NSASCIIStringEncoding]};
        int ret = csoundCompile(cs, 2, argv);
        mCsData.running = true;
        mCsData.nsmps = 0;
        
        if(!ret) {
            
            mCsData.cs = cs;
            mCsData.ret = ret;
            mCsData.nchnls = csoundGetNchnls(cs);
            mCsData.bufframes = (csoundGetOutputBufferSize(cs))/mCsData.nchnls;
            mCsData.running = true;
            mCsData.valuesCache = _bindings;
            mCsData.useAudioInput = _useAudioInput;
            AudioStreamBasicDescription format;
            OSStatus err;
            
            [self setupBindings];
            
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
            
            Float32 preferredBufferSize = mCsData.bufframes / csoundGetSr(cs);
            [session setPreferredIOBufferDuration:preferredBufferSize error:&error];
            
            success = [session setActive:YES error:&error];
            if(!success) {
                
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
                
                mCsData.aunit = &csAUHAL;
                UInt32 enableIO = 1;
                AudioUnitSetProperty(csAUHAL, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Output, 0, &enableIO, sizeof(enableIO));
                if (_useAudioInput) {
                    AudioUnitSetProperty(csAUHAL, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Input, 1, &enableIO, sizeof(enableIO));
                }
                
                if (enableIO) {
                    UInt32 maxFPS;
                    UInt32 outsize;
                    int elem;
                    for(elem = _useAudioInput ? 1 : 0; elem >= 0; elem--){
                        outsize = sizeof(maxFPS);
                        AudioUnitGetProperty(csAUHAL, kAudioUnitProperty_MaximumFramesPerSlice, kAudioUnitScope_Global, elem, &maxFPS, &outsize);
                        AudioUnitSetProperty(csAUHAL, kAudioUnitProperty_MaximumFramesPerSlice, kAudioUnitScope_Global, elem, (UInt32*)&(mCsData.bufframes), sizeof(UInt32));
                        outsize = sizeof(AudioStreamBasicDescription);
                        AudioUnitGetProperty(csAUHAL, kAudioUnitProperty_StreamFormat, (elem ? kAudioUnitScope_Output : kAudioUnitScope_Input), elem, &format, &outsize);
                        format.mSampleRate	= csoundGetSr(cs);
                        format.mFormatID = kAudioFormatLinearPCM;
                        format.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagsNativeEndian | kAudioFormatFlagIsPacked | kLinearPCMFormatFlagIsNonInterleaved;
                        format.mBytesPerPacket = sizeof(SInt32);
                        format.mFramesPerPacket = 1;
                        format.mBytesPerFrame = sizeof(SInt32);
                        format.mChannelsPerFrame = mCsData.nchnls;
                        format.mBitsPerChannel = sizeof(SInt32)*8;
                        err = AudioUnitSetProperty(csAUHAL, kAudioUnitProperty_StreamFormat, (elem ? kAudioUnitScope_Output : kAudioUnitScope_Input), elem, &format, sizeof(AudioStreamBasicDescription));
                    }
                    
                    if (mCsData.shouldRecord) {
                        
                        // Define format for the audio file.
                        AudioStreamBasicDescription destFormat, clientFormat;
                        memset(&destFormat, 0, sizeof(AudioStreamBasicDescription));
                        memset(&clientFormat, 0, sizeof(AudioStreamBasicDescription));
                        destFormat.mFormatID = kAudioFormatLinearPCM;
                        destFormat.mFormatFlags = kLinearPCMFormatFlagIsPacked | kLinearPCMFormatFlagIsSignedInteger;
                        destFormat.mSampleRate = csoundGetSr(cs);
                        destFormat.mChannelsPerFrame = mCsData.nchnls;
                        destFormat.mBytesPerPacket = mCsData.nchnls * 2;
                        destFormat.mBytesPerFrame = mCsData.nchnls * 2;
                        destFormat.mBitsPerChannel = 16;
                        destFormat.mFramesPerPacket = 1;
                        
                        // Create the audio file.
                        CFURLRef fileURL = (__bridge CFURLRef)self.outputURL;
                        err = ExtAudioFileCreateWithURL(fileURL, kAudioFileWAVEType, &destFormat, NULL, kAudioFileFlags_EraseFile, &(mCsData.file));
                        if (err == noErr) {
                            // Get the stream format from the AU...
                            UInt32 propSize = sizeof(AudioStreamBasicDescription);
                            AudioUnitGetProperty(csAUHAL, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &clientFormat, &propSize);
                            // ...and set it as the client format for the audio file. The file will use this
                            // format to perform any necessary conversions when asked to read or write.
                            ExtAudioFileSetProperty(mCsData.file, kExtAudioFileProperty_ClientDataFormat, sizeof(clientFormat), &clientFormat);
                            // Warm the file up.
                            ExtAudioFileWriteAsync(mCsData.file, 0, NULL);
                        } else {
                            printf("***Not recording. Error: %d\n", (int)err);
                            err = noErr;
                        }
                    }
                    
                    if(!err) {
                        AURenderCallbackStruct output;
                        output.inputProc = Csound_Render;
                        output.inputProcRefCon = &mCsData;
                        AudioUnitSetProperty(csAUHAL, kAudioUnitProperty_SetRenderCallback, kAudioUnitScope_Input, 0, &output, sizeof(output));
                        AudioUnitInitialize(csAUHAL);
                        
                        err = AudioOutputUnitStart(csAUHAL);
                        
                        [self notifyListenersOfStartup];
                        
                        if(!err) {
                            while (!mCsData.ret && mCsData.running) {
                                [NSThread sleepForTimeInterval:.001];
                            }
                        }
                        
                        ExtAudioFileDispose(mCsData.file);
                        mCsData.shouldRecord = false;
                        AudioOutputUnitStop(csAUHAL);
                        /* free(CAInputData); */
                    }
                    AudioUnitUninitialize(csAUHAL);
                    AudioComponentInstanceDispose(csAUHAL);
                }
            }
            csoundDestroy(cs);
        }
        
        mCsData.running = false;
        
        [self cleanupBindings];
        [self notifyListenersOfCompletion];
    }
}

- (void)handleInterruption:(NSNotification *)notification
{
    NSDictionary *interuptionDict = notification.userInfo;
    NSUInteger interuptionType = (NSUInteger)[interuptionDict
                                              valueForKey:AVAudioSessionInterruptionTypeKey];
    
    NSError *error;
    BOOL success;
    
    if (mCsData.running) {
        if (interuptionType == AVAudioSessionInterruptionTypeBegan) {
            AudioOutputUnitStop(*(mCsData.aunit));
        } else if (interuptionType == kAudioSessionEndInterruption) {
            // make sure we are again the active session
            success = [[AVAudioSession sharedInstance] setActive:YES error:&error];
            if(success) {
                AudioOutputUnitStart(*(mCsData.aunit));
            }
        }
    }
}

@end
