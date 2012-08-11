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
#import "CsoundValueCacheable.h"

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
        mUseOldParser = NO;
    }
    
    return self;
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

#pragma mark -

static void messageCallback(CSOUND *cs, int attr, const char *format, va_list valist) 
{	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	CsoundObj *obj = csoundGetHostData(cs);
	Message info;
	info.cs = cs;
	info.attr = attr;
	info.format = format;
	//info.valist = valist;
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

-(MYFLT*)getInputChannelPtr:(NSString*)channelName {
    MYFLT *value;
    csoundGetChannelPtr(mCsData.cs, &value, [channelName cStringUsingEncoding:NSASCIIStringEncoding], CSOUND_CONTROL_CHANNEL | CSOUND_INPUT_CHANNEL);
    return value;
}

-(MYFLT*)getOutputChannelPtr:(NSString *)channelName
{
	MYFLT *value;
	csoundGetChannelPtr(mCsData.cs, &value, [channelName cStringUsingEncoding:NSASCIIStringEncoding], CSOUND_AUDIO_CHANNEL | CSOUND_OUTPUT_CHANNEL);
	return value;
}

-(NSData*)getOutSamples {
    if (!mCsData.running) {
        return nil;
    }
    CSOUND *csound = [self getCsound];
    MYFLT *spout = csoundGetSpout(csound);
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
			printf("***Error writing to file: %dn", err);
		}
	}
        
    cdata->ret = ret;
    return 0;
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
        printf("***Not recording. Error: %d\n", err);
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
    NSLog(@"Running Csound at %@", csdFilePath);

    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];	
	CSOUND *cs;
    
	cs = csoundCreate(NULL);
//    csoundPreCompile(cs);
//    csoundSetHostImplementedAudioIO(cs, 1, 0);
//	
//	csoundSetMessageCallback(cs, messageCallback);
	//csoundSetHostData(cs, self);
    
    // Hardcoding to use old parser for time being
    char* parserFlag;
	
    
    if(self.useOldParser) {
       parserFlag = "--old-parser";
    } else {
       parserFlag = "--new-parser";
    }
    
    char *argv[3] = { "csound", parserFlag, (char*)[csdFilePath cStringUsingEncoding:NSASCIIStringEncoding]};
     
    NSLog(@"%@", csdFilePath);
    NSLog(@"%s %s %s", argv[0], argv[1], argv[2]);
	int ret = csoundCompile(cs, 3, argv);
    

    
    NSLog(@"%@", csdFilePath);
	mCsData.running = true;
    
  
	if(!ret) {
        
		mCsData.cs = cs;
		mCsData.ret = ret;
		mCsData.nchnls = csoundGetNchnls(cs);
		mCsData.bufframes = (int) (csoundGetOutputBufferSize(cs))/mCsData.nchnls;
		mCsData.running = true;
        mCsData.valuesCache = valuesCache;
		
        // SETUP VALUE CACHEABLE
        
        for (int i = 0; i < valuesCache.count; i++) {
            id<CsoundValueCacheable> cachedValue = [valuesCache objectAtIndex:i];
            [cachedValue setup:self];
        }
        
        for (id<CsoundObjCompletionListener> listener in completionListeners) {
            [listener csoundObjDidStart:self];
        }
        
        ret = csoundPerform(cs);

        
        
		csoundDestroy(cs);
	}	
	
    mCsData.running = false;
             
             
    
    // CLEANUP VALUE CACHEABLE
    
    for (int i = 0; i < valuesCache.count; i++) {
        id<CsoundValueCacheable> cachedValue = [valuesCache objectAtIndex:i];
        [cachedValue cleanup];
    }
    
    // NOTIFY COMPLETION LISTENERS
    
    for (id<CsoundObjCompletionListener> listener in completionListeners) {
        [listener csoundObjComplete:self];	
    }

	[pool release];
}

#pragma mark Memory Handling

-(void)dealloc {
    
    [valuesCache release];
    [completionListeners release];
    
    [super dealloc];
}


@end
