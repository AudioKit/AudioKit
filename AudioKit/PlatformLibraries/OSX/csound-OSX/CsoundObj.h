#import <AudioUnit/AudioUnit.h>
#include "csound.h"

typedef struct {
	CSOUND *cs;
	int attr;
	const char *format;
	va_list valist;
} Message;


@class CsoundObj;
@protocol CsoundValueCacheable;

@protocol CsoundObjCompletionListener
-(void)csoundObjDidStart:(CsoundObj *)csoundObj;
-(void)csoundObjComplete:(CsoundObj *)csoundObj;
@end


@interface CsoundObj : NSObject

-(void)addValueCacheable:(id<CsoundValueCacheable>)valueCacheable;
-(void)removeValueCaheable:(id<CsoundValueCacheable>)valueCacheable;

-(float*)getInputChannelPtr:(NSString*)channelName channelType:(controlChannelType)channelType;


-(void)setMessageCallback:(SEL)method withListener:(id)listener;
-(void)performMessageCallback:(NSValue *)infoObj;


-(void)addCompletionListener:(id<CsoundObjCompletionListener>)listener;

-(void)startCsound:(NSString *)csdFilePath;
-(void)stopCsound;
-(void)sendScore:(NSString *)score;
-(void)muteCsound;
-(void)unmuteCsound;

@end




