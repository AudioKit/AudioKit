/*
 
 CsoundObj.m:
 
 Copyright (C) 2014 Steven Yi, Victor Lazzarini, Aurelius Prochazka
 
 This file is part of Csound for OS X.
 
 The Csound for OSX Library is free software; you can redistribute it
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
        //        UInt32 propSize = sizeof(AudioStreamBasicDescription);
        //        AudioUnitGetProperty(*(mCsData.aunit), kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &clientFormat, &propSize);
        //        // ...and set it as the client format for the audio file. The file will use this
        //        // format to perform any necessary conversions when asked to read or write.
        //        ExtAudioFileSetProperty(mCsData.file, kExtAudioFileProperty_ClientDataFormat, sizeof(clientFormat), &clientFormat);
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

- (NSData *)getOutSamples {
    if (!mCsData.running) {
        return nil;
    }
    CSOUND *csound = [self getCsound];
    MYFLT *spout = csoundGetSpout(csound);
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
    MYFLT *spin = csoundGetSpin(csound);
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
    CSOUND *cs = cdata->cs;
    
    int i,j,k;
    int slices = inNumberFrames/csoundGetKsmps(cs);
    int ksmps = csoundGetKsmps(cs);
    MYFLT *spin = csoundGetSpin(cs);
    MYFLT *spout = csoundGetSpout(cs);
    Float32 *buffer;
    
    AudioUnitRender(*cdata->aunit, ioActionFlags, inTimeStamp, 1, inNumberFrames, ioData);
    
    NSMutableArray* cache = cdata->valuesCache;
    
    for(i=0; i < slices; i++){
        @autoreleasepool {
            for (int i = 0; i < cache.count; i++) {
                id<CsoundBinding> binding = [cache objectAtIndex:i];
                if ([binding respondsToSelector:@selector(updateValuesToCsound)]) {
                    [binding updateValuesToCsound];
                }
            }
            
            /* performance */
            if(cdata->useAudioInput) {
                for (k = 0; k < nchnls; k++){
                    buffer = (Float32 *) ioData->mBuffers[k].mData;
                    for(j=0; j < ksmps; j++){
                        spin[j*nchnls+k] = buffer[j+i*ksmps];
                    }
                }
            }
            if(!ret) {
                ret = csoundPerformKsmps(cdata->cs);
            } else {
                cdata->running = false;
            }
            
            for (k = 0; k < nchnls; k++) {
                buffer = (Float32 *) ioData->mBuffers[k].mData;
                if (cdata->shouldMute == false) {
                    for(j=0; j < ksmps; j++){
                        buffer[j+i*ksmps] = (Float32) spout[j*nchnls+k];
                    }
                } else {
                    memset(buffer, 0, sizeof(Float32) * inNumberFrames);
                }
            }
            
            for (int i = 0; i < cache.count; i++) {
                id<CsoundBinding> binding = [cache objectAtIndex:i];
                if ([binding respondsToSelector:@selector(updateValuesFromCsound)]) {
                    [binding updateValuesFromCsound];
                }
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
        
        cs = csoundCreate(NULL);
        csoundSetMessageCallback(cs, messageCallback);
        csoundSetHostData(cs, (__bridge void *)(self));
        
        //    if (_midiInEnabled) {
        //        [CsoundMIDI setMidiInCallbacks:cs];
        //    }
        
        char *argv[5] = { "csound", "-+ignore_csopts=0",
            "-+rtaudio=coreaudio", "-b256", (char*)[csdFilePath
                                                    cStringUsingEncoding:NSASCIIStringEncoding]};
        int ret = csoundCompile(cs, 5, argv);
        mCsData.running = true;
        
        if(!ret) {
            float coef = (float) SHRT_MAX / csoundGet0dBFS(cs);
            mCsData.cs = cs;
            mCsData.ret = ret;
            mCsData.nchnls = csoundGetNchnls(cs);
            mCsData.bufframes = (csoundGetOutputBufferSize(cs))/mCsData.nchnls;
            mCsData.running = true;
            mCsData.valuesCache = _bindings;
            mCsData.useAudioInput = _useAudioInput;
            
            MYFLT* spout = csoundGetSpout(cs);
            AudioBufferList bufferList;
            bufferList.mNumberBuffers = 1;
            
            [self setupBindings];
            
            [self notifyListenersOfStartup];
            
            if (mCsData.shouldRecord) {
                [self recordToURL:self.outputURL];
                bufferList.mBuffers[0].mNumberChannels = mCsData.nchnls;
                bufferList.mBuffers[0].mDataByteSize = mCsData.nchnls * csoundGetKsmps(cs) * 2; // 16-bit PCM output
                bufferList.mBuffers[0].mData = malloc(sizeof(short) * mCsData.nchnls * csoundGetKsmps(cs));
            }
            
            while (!mCsData.ret && mCsData.running) {
                for (int i = 0; i < _bindings.count; i++) {
                    id<CsoundBinding> binding = [_bindings objectAtIndex:i];
                    if ([binding respondsToSelector:@selector(updateValuesToCsound)]) {
                        [binding updateValuesToCsound];
                    }
                }
                
                mCsData.ret = csoundPerformKsmps(mCsData.cs);
                
                // Write to file.
                if (mCsData.shouldRecord) {
                    short* data = (short*)bufferList.mBuffers[0].mData;
                    for (int i = 0; i < csoundGetKsmps(cs) * mCsData.nchnls; i++) {
                        data[i] = (short)lrintf(spout[i] * coef);
                    }
                    OSStatus err = ExtAudioFileWriteAsync(mCsData.file, csoundGetKsmps(cs), &bufferList);
                    if (err != noErr) {
                        printf("***Error writing to file: %d\n", (int)err);
                    }
                }
                
                for (int i = 0; i < _bindings.count; i++) {
                    id<CsoundBinding> binding = [_bindings objectAtIndex:i];
                    if ([binding respondsToSelector:@selector(updateValuesFromCsound)]) {
                        [binding updateValuesFromCsound];
                    }
                }
            }
        }
        
        if (mCsData.shouldRecord) {
            ExtAudioFileDispose(mCsData.file);
        }
        
        csoundDestroy(cs);
        
        mCsData.running = false;
        
        [self cleanupBindings];
        [self notifyListenersOfCompletion];
    }
}
@end
