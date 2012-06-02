/* 
 
 CsoundObj.m:
 
 Copyright (C) 2011 Steven Yi, Victor Lazzarini
 
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

#import "CsoundObj.h"
#import "CachedSlider.h"
#import "CachedButton.h"
#import "CachedSwitch.h"
#import "CachedAccelerometer.h"
#import "CachedGyroscope.h"
#import "CachedAttitude.h"
#import "CsoundValueCacheable.h"
#import "CsoundMIDI.h"

OSStatus  Csound_Render(void *inRefCon,
                        AudioUnitRenderActionFlags *ioActionFlags,
                        const AudioTimeStamp *inTimeStamp,
                        UInt32 dump,
                        UInt32 inNumberFrames,
                        AudioBufferList *ioData);
void InterruptionListener(void *inClientData, UInt32 inInterruption);

@interface CsoundObj() 

-(void)runCsound:(NSString*)csdFilePath;

@end

@implementation CsoundObj

@synthesize outputURL;
@synthesize midiInEnabled = mMidiInEnabled;
@synthesize motionManager = mMotionManager;
@synthesize useOldParser = mUseOldParser;

//+(void)initializeAudio {
//    /* CONFIGURING AUDIO SETTINGS */
//    
//    //    self.graphSampleRate = 44100.0; // Hertz
//    //    
//    //    NSError *audioSessionError = nil;
//    //    AVAudioSession *mySession = [AVAudioSession sharedInstance];     
//    //    [mySession setPreferredHardwareSampleRate: self.graphSampleRate       
//    //                                        error: &audioSessionError];
//    //    [mySession setCategory: AVAudioSessionCategoryPlayAndRecord      
//    //                     error: &audioSessionError];
//    //    [mySession setActive: YES                                        
//    //                   error: &audioSessionError];
//    //    self.graphSampleRate = [mySession currentHardwareSampleRate];    
//    
//    
//}

- (id)init
{
    self = [super init];
    if (self) {
		mCsData.shouldMute = false;
        valuesCache = [[NSMutableArray alloc] init];
        completionListeners = [[NSMutableArray alloc] init];
        mMidiInEnabled = NO;
        self.motionManager = [[CMMotionManager alloc] init];
        mUseOldParser = NO;
    }
    
    return self;
}

-(id<CsoundValueCacheable>)addSwitch:(UISwitch*)uiSwitch forChannelName:(NSString*)channelName {
    CachedSwitch* cachedSwitch = [[[CachedSwitch alloc] init:uiSwitch 
												 channelName:channelName] autorelease];
    [valuesCache addObject:cachedSwitch];
	
    return cachedSwitch;
}

-(id<CsoundValueCacheable>)addSlider:(UISlider*)uiSlider forChannelName:(NSString*)channelName { 

    CachedSlider* cachedSlider = [[[CachedSlider alloc] init:uiSlider 
                                                channelName:channelName] autorelease];
    [valuesCache addObject:cachedSlider];
    
    return cachedSlider;
}

-(id<CsoundValueCacheable>)addButton:(UIButton*)uiButton forChannelName:(NSString*)channelName {
    CachedButton* cachedButton = [[[CachedButton alloc] init:uiButton 
                                                channelName:channelName] autorelease];
    [valuesCache addObject:cachedButton];
    return cachedButton;
}

-(void)addValueCacheable:(id<CsoundValueCacheable>)valueCacheable {
    if (valueCacheable != nil) {
        [valuesCache addObject:valueCacheable];
    }
}

-(void)removeValueCaheable:(id<CsoundValueCacheable>)valueCacheable {
	if (valueCacheable != nil && [valuesCache containsObject:valueCacheable]) {
		[valuesCache removeObject:valueCacheable];
	}
}

-(id<CsoundValueCacheable>)enableAccelerometer {
    
    if (!mMotionManager.accelerometerAvailable) {
        NSLog(@"Accelerometer not available");
        return nil;
    }
    
    CachedAccelerometer* accelerometer = [[CachedAccelerometer alloc] init:mMotionManager];
    [valuesCache addObject:accelerometer];
        
    [accelerometer release];
    
    mMotionManager.accelerometerUpdateInterval = 1 / 100.0; // 100 hz
    
    [mMotionManager startAccelerometerUpdates];
	
	return accelerometer;
}

-(id<CsoundValueCacheable>)enableGyroscope {
    
    if (!mMotionManager.isGyroAvailable) {
        NSLog(@"Gyroscope not available");
        return nil;
    }
    
    CachedGyroscope* gyro = [[[CachedGyroscope alloc] init:mMotionManager] autorelease];
    [valuesCache addObject:gyro];
    
    mMotionManager.gyroUpdateInterval = 1 / 100.0; // 100 hz
    
    [mMotionManager startGyroUpdates];
	
	return gyro;
}

-(id<CsoundValueCacheable>)enableAttitude {
    if (!mMotionManager.isDeviceMotionAvailable) {
        NSLog(@"Attitude not available");
        return nil;
    }
    
    CachedAttitude* attitude = [[[CachedAttitude alloc] init:mMotionManager] autorelease];
    [valuesCache addObject:attitude];
    
    mMotionManager.deviceMotionUpdateInterval = 1 / 100.0; // 100hz
    
    [mMotionManager startDeviceMotionUpdates];
	
	return attitude;
}

#pragma mark -

static void messageCallback(CSOUND *cs, int attr, const char *format, va_list valist) 
{	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	CsoundObj *obj = csoundGetHostData(cs);
	Message info;
	info.cs = cs;
	info.attr = attr;
	info.format = format;
	info.valist = valist;
	NSValue *infoObj = [NSValue value:&info withObjCType:@encode(Message)];
	[obj performSelector:@selector(performMessageCallback:) withObject:infoObj];
	[pool drain];
} 

- (void)setMessageCallback:(SEL)method withListener:(id)listener
{
	mMessageCallback = method;
	mMessageListener = listener;
}

- (void)performMessageCallback:(NSValue *)infoObj
{
	[mMessageListener performSelector:mMessageCallback withObject:infoObj];
}

#pragma mark -

-(void)sendScore:(NSString *)score {
    if (mCsData.cs != NULL) {
        csoundInputMessage(mCsData.cs, [score cStringUsingEncoding:NSASCIIStringEncoding]);
    }
}

#pragma mark -

-(void)addCompletionListener:(id<CsoundObjCompletionListener>)listener {
    [completionListeners addObject:listener];
}


-(CSOUND*)getCsound {
    if (!mCsData.running) {
        return NULL;
    }
    return mCsData.cs;
}

-(float*)getInputChannelPtr:(NSString*)channelName {
    float *value;
    csoundGetChannelPtr(mCsData.cs, &value, [channelName cStringUsingEncoding:NSASCIIStringEncoding], CSOUND_CONTROL_CHANNEL | CSOUND_INPUT_CHANNEL);
    return value;
}

-(float*)getOutputChannelPtr:(NSString *)channelName
{
	float *value;
	csoundGetChannelPtr(mCsData.cs, &value, [channelName cStringUsingEncoding:NSASCIIStringEncoding], CSOUND_AUDIO_CHANNEL | CSOUND_OUTPUT_CHANNEL);
	return value;
}

-(NSData*)getOutSamples {
    if (!mCsData.running) {
        return nil;
    }
    CSOUND* csound = [self getCsound];
    float* spout = csoundGetSpout(csound);
    int nchnls = csoundGetNchnls(csound);
    int ksmps = csoundGetKsmps(csound);
    NSData* data = [NSData dataWithBytes:spout length:(nchnls * ksmps * sizeof(MYFLT))];
    return data;
}

-(int)getNumChannels {
    if (!mCsData.running) {
        return -1;
    }
    return csoundGetNchnls(mCsData.cs);
}
-(int)getKsmps {
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
    
    int i,j,k;
    int slices = inNumberFrames/csoundGetKsmps(cs);
    int ksmps = csoundGetKsmps(cs);
    MYFLT *spin = csoundGetSpin(cs);
    MYFLT *spout = csoundGetSpout(cs);
    AudioUnitSampleType *buffer; 
    
    AudioUnitRender(*cdata->aunit, ioActionFlags, inTimeStamp, 1, inNumberFrames, ioData);
    
    NSMutableArray* cache = cdata->valuesCache;
    
    for(i=0; i < slices; i++){
		
		for (int i = 0; i < cache.count; i++) {
			id<CsoundValueCacheable> cachedValue = [cache objectAtIndex:i];
			[cachedValue updateValuesToCsound];
		}
        
		/* performance */
		for (k = 0; k < nchnls; k++){
			buffer = (AudioUnitSampleType *) ioData->mBuffers[k].mData;
			for(j=0; j < ksmps; j++){
				spin[j*nchnls+k] =(1./coef)*buffer[j+i*ksmps];
			}
		}
        if(!ret) {
            ret = csoundPerformKsmps(cs);
        } else {
            cdata->running = false;
        }
		
		for (k = 0; k < nchnls; k++) {
			buffer = (AudioUnitSampleType *) ioData->mBuffers[k].mData;
			if (cdata->shouldMute == false) {
				for(j=0; j < ksmps; j++){
					buffer[j+i*ksmps] = (AudioUnitSampleType) lrintf(spout[j*nchnls+k]*coef) ;
				}
			} else {
				memset(buffer, 0, sizeof(AudioUnitSampleType) * inNumberFrames);
			}
		}
        
		
		for (int i = 0; i < cache.count; i++) {
			id<CsoundValueCacheable> cachedValue = [cache objectAtIndex:i];
			[cachedValue updateValuesFromCsound];
		}
		
    }
	
	// Write to file.
	if (cdata->shouldRecord) {
		OSStatus err = ExtAudioFileWriteAsync(cdata->file, inNumberFrames, ioData);
		if (err != noErr) {
			printf("***Error writing to file: %ld\n", err);
		}
	}
        
    cdata->ret = ret;
    return 0;
}


void InterruptionListener(void *inClientData, UInt32 inInterruption)
{
	csdata *cdata  = (csdata *)inClientData;
    
	if (inInterruption == kAudioSessionEndInterruption) {
		// make sure we are again the active session
		AudioSessionSetActive(true);
		AudioOutputUnitStart(*(cdata->aunit));
	}
	
	if (inInterruption == kAudioSessionBeginInterruption) {
		AudioOutputUnitStop(*(cdata->aunit));
    }
}

-(void)startCsound:(NSString*)csdFilePath {
	mCsData.shouldRecord = false;
    [self performSelectorInBackground:@selector(runCsound:) withObject:csdFilePath];
}

-(void)startCsound:(NSString *)csdFilePath recordToURL:(NSURL *)outputURL_{
	mCsData.shouldRecord = true;
	self.outputURL = outputURL_;
	[self performSelectorInBackground:@selector(runCsound:) withObject:csdFilePath];
}

-(void)recordToURL:(NSURL *)outputURL_
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
    CFURLRef fileURL = (CFURLRef)outputURL_;
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
        printf("***Not recording. Error: %ld\n", err);
        err = noErr;
    }
    
    mCsData.shouldRecord = true;
}

-(void)stopRecording
{
    mCsData.shouldRecord = false;
    ExtAudioFileDispose(mCsData.file);
}
    
-(void)stopCsound {
    mCsData.running = false;
}

-(void)muteCsound{
	mCsData.shouldMute = true;
}

-(void)unmuteCsound{
	mCsData.shouldMute = false;
}

-(void)runCsound:(NSString*)csdFilePath {
	
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];	
	CSOUND *cs;
    
	cs = csoundCreate(NULL);
    csoundPreCompile(cs);
    csoundSetHostImplementedAudioIO(cs, 1, 0);
	
	csoundSetMessageCallback(cs, messageCallback);
	csoundSetHostData(cs, self);
    
    if (mMidiInEnabled) {
        [CsoundMIDI setMidiInCallbacks:cs];
    }
    
    // Hardcoding to use old parser for time being
    char* parserFlag;
	
    
    if(self.useOldParser) {
       parserFlag = "--old-parser";
    } else {
       parserFlag = "--new-parser";
    }
    
    char *argv[3] = { "csound", parserFlag, (char*)[csdFilePath cStringUsingEncoding:NSASCIIStringEncoding]};
	int ret = csoundCompile(cs, 3, argv);
	mCsData.running = true;
    
	if(!ret) {
        
		mCsData.cs = cs;
		mCsData.ret = ret;
		mCsData.nchnls = csoundGetNchnls(cs);
		mCsData.bufframes = (csoundGetOutputBufferSize(cs))/mCsData.nchnls;
		mCsData.running = true;
        mCsData.valuesCache = valuesCache;
		AudioStreamBasicDescription format;
		OSStatus err;
		
        /* SETUP VALUE CACHEABLE */
        
        for (int i = 0; i < valuesCache.count; i++) {
            id<CsoundValueCacheable> cachedValue = [valuesCache objectAtIndex:i];
            [cachedValue setup:self];
        }
        
        
		/* Audio Session handler */
        AudioSessionInitialize(NULL, NULL, InterruptionListener, &mCsData);
		AudioSessionSetActive(true);
//		UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
//		AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute, sizeof(audioRouteOverride), &audioRouteOverride);
		UInt32 audioCategory = kAudioSessionCategory_PlayAndRecord;
		AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(audioCategory), &audioCategory);
		
		Float32 preferredBufferSize = mCsData.bufframes / csoundGetSr(cs);
		AudioSessionSetProperty(kAudioSessionProperty_PreferredHardwareIOBufferDuration, sizeof(preferredBufferSize), &preferredBufferSize);
		AudioComponentDescription cd = {kAudioUnitType_Output, kAudioUnitSubType_RemoteIO, kAudioUnitManufacturer_Apple, 0, 0};
		AudioComponent HALOutput = AudioComponentFindNext(NULL, &cd);
		
		AudioUnit csAUHAL;
		err = AudioComponentInstanceNew(HALOutput, &csAUHAL);

		
		if(!err) {
            
            mCsData.aunit = &csAUHAL;
            UInt32 enableIO = 1;
            AudioUnitSetProperty(csAUHAL, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Output, 0, &enableIO, sizeof(enableIO));
            AudioUnitSetProperty(csAUHAL, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Input, 1, &enableIO, sizeof(enableIO));
            
            if (enableIO) {
                UInt32 maxFPS;
                UInt32 outsize;
                int elem;
                for(elem = 1; elem >= 0; elem--){
                    outsize = sizeof(maxFPS);
                    AudioUnitGetProperty(csAUHAL, kAudioUnitProperty_MaximumFramesPerSlice, kAudioUnitScope_Global, elem, &maxFPS, &outsize);
                    AudioUnitSetProperty(csAUHAL, kAudioUnitProperty_MaximumFramesPerSlice, kAudioUnitScope_Global, elem, (UInt32*)&(mCsData.bufframes), sizeof(UInt32));
                    outsize = sizeof(AudioStreamBasicDescription);
                    AudioUnitGetProperty(csAUHAL, kAudioUnitProperty_StreamFormat, (elem ? kAudioUnitScope_Output : kAudioUnitScope_Input), elem, &format, &outsize);
                    format.mSampleRate	= csoundGetSr(cs);
                    format.mFormatID = kAudioFormatLinearPCM;
                    format.mFormatFlags = kAudioFormatFlagsCanonical | kLinearPCMFormatFlagIsNonInterleaved;         
                    format.mBytesPerPacket = sizeof(AudioUnitSampleType);
                    format.mFramesPerPacket = 1;
                    format.mBytesPerFrame = sizeof(AudioUnitSampleType);
                    format.mChannelsPerFrame = mCsData.nchnls;
                    format.mBitsPerChannel = sizeof(AudioUnitSampleType)*8;
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
					CFURLRef fileURL = (CFURLRef)self.outputURL;
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
						printf("***Not recording. Error: %ld\n", err);
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
					
					/* NOTIFY COMPLETION LISTENERS*/
					
					for (id<CsoundObjCompletionListener> listener in completionListeners) {
						[listener csoundObjDidStart:self];
					}
                    
                    if(!err) while (!mCsData.ret && mCsData.running);
						
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
    
    /* CLEANUP VALUE CACHEABLE */
    
    for (int i = 0; i < valuesCache.count; i++) {
        id<CsoundValueCacheable> cachedValue = [valuesCache objectAtIndex:i];
        [cachedValue cleanup];
    }
    
    /* NOTIFY COMPLETION LISTENERS*/
    
    for (id<CsoundObjCompletionListener> listener in completionListeners) {
        [listener csoundObjComplete:self];	
    }
    
    [mMotionManager stopAccelerometerUpdates];
    [mMotionManager stopGyroUpdates];
    [mMotionManager stopDeviceMotionUpdates];
    
	[pool release];
}

#pragma mark Memory Handling

-(void)dealloc {
    
    [valuesCache release];
    [completionListeners release];
    [mMotionManager release];
    
    [super dealloc];
}


@end
