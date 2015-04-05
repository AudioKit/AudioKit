/*
 
 CsoundObj.h:
 
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

#import <AudioToolbox/ExtendedAudioFile.h>
#import <AudioUnit/AudioUnit.h>
#import <Foundation/Foundation.h>

#import "csound.h"

typedef struct csdata_ {
    CSOUND *cs;
    long bufframes;
    int ret;
    int nchnls;
    int nsmps;
    int nchnls_i;
    bool running;
    bool shouldRecord;
    bool shouldMute;
    bool useAudioInput;
    ExtAudioFileRef file;
    AudioUnit *aunit;
    __unsafe_unretained NSMutableArray *valuesCache;
} csdata;

typedef struct {
    CSOUND *cs;
    int attr;
    const char *format;
    va_list valist;
} Message;

// -----------------------------------------------------------------------------
#  pragma mark - Protocols (Bindings and Listeners)
// -----------------------------------------------------------------------------

@class CsoundObj;

@protocol CsoundBinding <NSObject>
- (void)setup:(CsoundObj *)csoundObj;
@optional
- (void)cleanup;
- (void)updateValuesFromCsound;
- (void)updateValuesToCsound;
@end

@protocol CsoundObjListener <NSObject>
@optional
- (void)csoundObjStarted:(CsoundObj *)csoundObj;
- (void)csoundObjCompleted:(CsoundObj *)csoundObj;
@end

// -----------------------------------------------------------------------------
#  pragma mark - CsoundObj Interface
// -----------------------------------------------------------------------------

@interface CsoundObj : NSObject

@property (nonatomic, strong) NSURL *outputURL;
@property (assign) BOOL midiInEnabled;
@property (assign) BOOL useAudioInput;

- (void)sendScore:(NSString *)score;

- (void)play:(NSString *)csdFilePath;
- (void)updateOrchestra:(NSString *)orchestraString;
- (void)stop;
- (void)mute;
- (void)unmute;

// -----------------------------------------------------------------------------
#  pragma mark - Recording
// -----------------------------------------------------------------------------

- (void)record:(NSString *)csdFilePath toURL:(NSURL *)outputURL;
- (void)record:(NSString *)csdFilePath toFile:(NSString *)outputFile;
- (void)recordToURL:(NSURL *)outputURL;
- (void)stopRecording;


// -----------------------------------------------------------------------------
#  pragma mark - Binding
// -----------------------------------------------------------------------------

@property (nonatomic, strong) NSMutableArray *bindings;
- (void)addBinding:(id<CsoundBinding>)binding;
- (void)removeBinding:(id<CsoundBinding>)binding;

// -----------------------------------------------------------------------------
#  pragma mark - Listeners and Messages
// -----------------------------------------------------------------------------

@property (assign) SEL messageCallbackSelector;
- (void)addListener:(id<CsoundObjListener>)listener;
- (void)setMessageCallback:(SEL)method withListener:(id)listener;
- (void)performMessageCallback:(NSValue *)infoObj;


// -----------------------------------------------------------------------------
#  pragma mark - Csound Internals / Advanced Methods
// -----------------------------------------------------------------------------

- (CSOUND *)getCsound;
- (AudioUnit *)getAudioUnit;

// get input or output that maps to a channel name and type, where type is
// CSOUND_AUDIO_CHANNEL, CSOUND_CONTROL_CHANNEL, etc.
- (MYFLT *)getInputChannelPtr:(NSString *)channelName
                  channelType:(controlChannelType)channelType;
- (MYFLT *)getOutputChannelPtr:(NSString *)channelName
                   channelType:(controlChannelType)channelType;

// Read-only samples
- (NSData *)getOutSamples;
- (NSData *)getInSamples;

// Writable alternatives
- (NSMutableData *)getMutableInSamples;
- (NSMutableData *)getMutableOutSamples;

- (int)getNumChannels;
- (int)getKsmps;

- (void)handleInterruption:(NSNotification *)notification;

@end