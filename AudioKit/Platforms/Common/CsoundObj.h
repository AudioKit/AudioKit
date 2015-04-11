/*
 
 CsoundObj.h:
 
 Copyright (C) 2014 Steven Yi, Victor Lazzarini, Aurelius Prochazka
 
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

@import Foundation;
@import AudioToolbox;
@import AudioUnit;

#import "csound.h"

// -----------------------------------------------------------------------------
#  pragma mark - Protocols (Bindings, Listeners and Message Delegate)
// -----------------------------------------------------------------------------

@class CsoundObj;

@protocol CsoundBinding <NSObject>
- (void)setup:(CsoundObj * __nonnull)csoundObj;
@optional
- (void)cleanup;
- (void)updateValuesFromCsound;
- (void)updateValuesToCsound;
@end

@protocol CsoundObjListener <NSObject>
@optional
- (void)csoundObjStarted:(CsoundObj * __nonnull)csoundObj;
- (void)csoundObjCompleted:(CsoundObj * __nonnull)csoundObj;
@end

@protocol CsoundMsgDelegate <NSObject>
- (void)messageReceivedFrom:(CsoundObj * __nonnull)csoundObj attr:(int)attr message:(NSString * __nonnull)msg;
@end

// -----------------------------------------------------------------------------
#  pragma mark - CsoundObj Interface
// -----------------------------------------------------------------------------

@interface CsoundObj : NSObject

@property (nonatomic, strong, nullable) NSURL *outputURL;
@property (assign) BOOL midiInEnabled;
@property (assign) BOOL useAudioInput;

- (void)sendScore:(NSString * __nonnull)score;

- (void)play:(NSString * __nonnull)csdFilePath;
- (void)updateOrchestra:(NSString * __nonnull)orchestraString;
- (void)stop;
- (void)mute;
- (void)unmute;

// -----------------------------------------------------------------------------
#  pragma mark - Recording
// -----------------------------------------------------------------------------

- (void)record:(NSString * __nonnull)csdFilePath toURL:(NSURL * __nonnull)outputURL;
- (void)record:(NSString * __nonnull)csdFilePath toFile:(NSString * __nonnull)outputFile;
- (void)recordToURL:(NSURL * __nonnull)outputURL;
- (void)stopRecording;


// -----------------------------------------------------------------------------
#  pragma mark - Binding
// -----------------------------------------------------------------------------

@property (nonatomic, strong, nonnull) NSMutableArray *bindings;
- (void)addBinding:(__nonnull id<CsoundBinding>)binding;
- (void)removeBinding:(__nonnull id<CsoundBinding>)binding;

// -----------------------------------------------------------------------------
#  pragma mark - Listeners and Messages
// -----------------------------------------------------------------------------

- (void)addListener:(__nonnull id<CsoundObjListener>)listener;

@property (weak, nullable) id<CsoundMsgDelegate> messageDelegate;

// -----------------------------------------------------------------------------
#  pragma mark - Csound Internals / Advanced Methods
// -----------------------------------------------------------------------------

@property (nonatomic,readonly,nonnull,getter=getCsound) CSOUND *csound;

@property (readonly,nonatomic, getter=getNumChannels) int numChannels;
@property (readonly,nonatomic, getter=getKsmps)       int ksmps;


// get input or output that maps to a channel name and type, where type is
// CSOUND_AUDIO_CHANNEL, CSOUND_CONTROL_CHANNEL, etc.
- (MYFLT * __nullable)getInputChannelPtr:(NSString * __nonnull)channelName
                             channelType:(controlChannelType)channelType;
- (MYFLT * __nullable)getOutputChannelPtr:(NSString * __nonnull)channelName
                              channelType:(controlChannelType)channelType;

// Read-only samples
- (NSData * __nonnull)getOutSamples;
- (NSData * __nonnull)getInSamples;

// Writable alternatives
- (NSMutableData * __nonnull)getMutableInSamples;
- (NSMutableData * __nonnull)getMutableOutSamples;

@end