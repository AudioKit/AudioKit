/* 
 
 CsoundObj.h:
 
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

#import <AudioToolbox/ExtendedAudioFile.h>
#import <AudioToolbox/AudioConverter.h>
#import <AudioToolbox/AudioServices.h>
#import <AudioUnit/AudioUnit.h>
#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>
#import "csound.h"
#import <CoreMotion/CoreMotion.h>
#import "UIKnob.h"

typedef struct csdata_ {
	CSOUND *cs;
	int bufframes;
	int ret;
	int nchnls;
    bool running;
	bool shouldRecord;
	bool shouldMute;
	ExtAudioFileRef file;
	AudioUnit *aunit;
     __unsafe_unretained NSMutableArray* valuesCache;
} csdata;

typedef struct {
	CSOUND *cs;
	int attr;
	const char *format;
	va_list valist;
} Message;

@class CsoundObj;
@protocol CsoundValueCacheable;

@protocol CsoundObjCompletionListener 

-(void)csoundObjDidStart:(CsoundObj*)csoundObj;
-(void)csoundObjComplete:(CsoundObj*)csoundObj;

@end

@interface CsoundObj : NSObject {
    NSMutableArray* valuesCache;
    NSMutableArray* completionListeners;
    csdata mCsData;
    BOOL mMidiInEnabled;
    CMMotionManager* mMotionManager;
	NSURL *outputURL;
	SEL mMessageCallback;
	id  mMessageListener;
    BOOL mUseOldParser;
}

@property (nonatomic, retain) NSURL *outputURL;
@property (assign) BOOL midiInEnabled;
@property (nonatomic, retain) CMMotionManager* motionManager;
@property (assign) BOOL useOldParser;



#pragma mark UI and Hardware Methods

-(id<CsoundValueCacheable>)addSwitch:(UISwitch*)uiSwitch forChannelName:(NSString*)channelName;
-(id<CsoundValueCacheable>)addSlider:(UISlider*)uiSlider forChannelName:(NSString*)channelName;
-(id<CsoundValueCacheable>)addButton:(UIButton*)uiButton forChannelName:(NSString*)channelName;

-(void)addValueCacheable:(id<CsoundValueCacheable>)valueCacheable;
-(void)removeValueCaheable:(id<CsoundValueCacheable>)valueCacheable;

-(id<CsoundValueCacheable>)enableAccelerometer;
-(id<CsoundValueCacheable>)enableGyroscope;
-(id<CsoundValueCacheable>)enableAttitude;

#pragma mark -

-(void)sendScore:(NSString*)score;

#pragma mark -

-(void)addCompletionListener:(id<CsoundObjCompletionListener>)listener;

#pragma mark -

-(void)startCsound:(NSString*)csdFilePath;
-(void)startCsound:(NSString *)csdFilePath recordToURL:(NSURL *)outputURL;
-(void)recordToURL:(NSURL *)outputURL;
-(void)stopRecording;
-(void)stopCsound;
-(void)muteCsound;
-(void)unmuteCsound;

-(CSOUND*)getCsound;
-(float*)getInputChannelPtr:(NSString*)channelName;	
-(float*)getOutputChannelPtr:(NSString*)channelName;
-(NSData*)getOutSamples;
-(int)getNumChannels;
-(int)getKsmps;

-(void)setMessageCallback:(SEL)method withListener:(id)listener;
-(void)performMessageCallback:(NSValue *)infoObj;

@end




