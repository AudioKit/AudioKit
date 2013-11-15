#import "CsoundObj.h"
#import "CsoundValueCacheable.h"

typedef struct csdata_ {
	CSOUND *cs;
	int bufframes;
	int ret;
	int nchnls;
    bool running;
	bool shouldRecord;
	bool shouldMute;
    AudioUnit *aunit;
    __unsafe_unretained NSMutableArray *valuesCache;
} csdata;

@interface CsoundObj() {
    NSMutableArray *valuesCache;
    NSMutableArray *completionListeners;
    csdata mCsData;
	SEL mMessageCallback;
	id  mMessageListener;
}
//-(void)runCsound:(NSString *)csdFilePath;
@end

@implementation CsoundObj

- (instancetype)init
{
    self = [super init];
    if (self) {
		mCsData.shouldMute = false;
        valuesCache = [[NSMutableArray alloc] init];
        completionListeners = [[NSMutableArray alloc] init];
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
	//info.valist = valist;  //NOT VALID ON OSX
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

-(float*)getInputChannelPtr:(NSString*)channelName channelType:(controlChannelType)channelType
{
    float *value;
    csoundGetChannelPtr(mCsData.cs, &value, [channelName cStringUsingEncoding:NSASCIIStringEncoding],
                        channelType | CSOUND_INPUT_CHANNEL);
    return value;
}

-(void)startCsound:(NSString *)csdFilePath {
	mCsData.shouldRecord = false;
    [self performSelectorInBackground:@selector(runCsound:) withObject:csdFilePath];
}

-(void)stopCsound {
    mCsData.running = false;
    csoundStop(mCsData.cs);
}

-(void)muteCsound {
	mCsData.shouldMute = true;
}

-(void)unmuteCsound {
	mCsData.shouldMute = false;
}

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
    
    NSMutableArray *cache = cdata->valuesCache;
    
    for(i=0; i < slices; i++){
		
		for (int i = 0; i < cache.count; i++) {
			id<CsoundValueCacheable> cachedValue = [cache objectAtIndex:i];
			[cachedValue updateValuesToCsound];
		}
        
		// performance
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
    
    cdata->ret = ret;
    return 0;
}


uintptr_t csThread(void *data)
{
    csdata *cdata = (csdata *) data;
    NSMutableArray *cache = cdata->valuesCache;
    if(!cdata->ret)
    {
        int result = 0;
        while(result == 0) {
            for (int i = 0; i < cache.count; i++) {
                id<CsoundValueCacheable> cachedValue = [cache objectAtIndex:i];
                [cachedValue updateValuesToCsound];
            }
            result = csoundPerformKsmps(cdata->cs);
        }
        for (int i = 0; i < cache.count; i++) {
            id<CsoundValueCacheable> cachedValue = [cache objectAtIndex:i];
            [cachedValue updateValuesFromCsound];
        }


    }
    cdata->ret = 0;
    return 1;
}

-(void)runCsound:(NSString *)csdFilePath {
    
    CSOUND *cs;
    
	cs = csoundCreate(NULL);
    csoundPreCompile(cs);
    csoundSetHostImplementedAudioIO(cs, 0, 0);
    csoundSetMessageCallback(cs, messageCallback);
    
    
    NSLog(@"!!!! Running Csound");
    char *argv[2] = { "csound", (char*)[csdFilePath cStringUsingEncoding:NSASCIIStringEncoding]};
	int ret = csoundCompile(cs, 2, argv);
	mCsData.running = true;
    
    if(!ret) {
        
		mCsData.cs = cs;
		mCsData.ret = ret;
		mCsData.nchnls = csoundGetNchnls(cs);
		mCsData.bufframes = (int)(csoundGetOutputBufferSize(cs))/mCsData.nchnls;
		mCsData.running = true;
        mCsData.valuesCache = valuesCache;

		
        // SETUP VALUE CACHEABLE
        
        for (int i = 0; i < valuesCache.count; i++) {
            id<CsoundValueCacheable> cachedValue = [valuesCache objectAtIndex:i];
            [cachedValue setup:self];
        }
        
        csoundCreateThread(csThread, &mCsData);
        
        
        for (id<CsoundObjCompletionListener> listener in completionListeners) {
            [listener csoundObjDidStart:self];
        }

        while (!mCsData.ret && mCsData.running);
    }
    NSLog(@"!!!! Destroying Csound");
    csoundDestroy(cs);
    mCsData.running = false;
    for (int i = 0; i < valuesCache.count; i++) {
        id<CsoundValueCacheable> cachedValue = [valuesCache objectAtIndex:i];
        [cachedValue cleanup];
    }
    
    // NOTIFY COMPLETION LISTENERS
    
    for (id<CsoundObjCompletionListener> listener in completionListeners) {
        [listener csoundObjComplete:self];
    }

}




@end
