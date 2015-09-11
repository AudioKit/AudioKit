/*
 
 CsoundObj.h:
 
 Copyright (C) 2014 Steven Yi, Victor Lazzarini, Aurelius Prochazka
 Copyright (C) 2015 Stephane Peter
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 
 */

@import Foundation;
@import AudioToolbox;
@import AudioUnit;

#import "AKCompatibility.h"

// -----------------------------------------------------------------------------
#  pragma mark - Protocols (Bindings, Listeners and Message Delegate)
// -----------------------------------------------------------------------------

@class CsoundObj;

typedef struct CSOUND_ CSOUND;

/// Equivalent type to Csound's controlChannelType
typedef NS_ENUM(NSUInteger, AKControlChannelType) {
    AKControlChannel = 1,
    AKAudioChannel   = 2,
    AKStringChannel  = 3,
    AKPVSChannel     = 4,
    AKVarChannel     = 5
};

NS_ASSUME_NONNULL_BEGIN
@protocol CsoundBinding <NSObject>
- (void)setup:(CsoundObj *)csoundObj;
@optional
- (void)cleanup;
- (void)updateValuesFromCsound;
- (void)updateValuesToCsound;
@end

@protocol CsoundObjListener <NSObject>
@optional
/// Called before CSD compilation and startup.
- (void)csoundObjWillStart:(CsoundObj *)csoundObj;
/// The Csound engine is now running.
- (void)csoundObjStarted:(CsoundObj *)csoundObj;
/// The Csound engine stopped running.
- (void)csoundObjCompleted:(CsoundObj *)csoundObj;
@end

@protocol CsoundMsgDelegate <NSObject>
- (void)messageReceivedFrom:(CsoundObj *)csoundObj
                       attr:(int)attr
                    message:(NSString *)msg;
@end


// -----------------------------------------------------------------------------
#  pragma mark - CsoundObj notification names
// -----------------------------------------------------------------------------
extern NSString * const AKCsoundAPIMessageNotification;

// -----------------------------------------------------------------------------
#  pragma mark - CsoundObj Interface
// -----------------------------------------------------------------------------

@interface CsoundObj : NSObject

@property (nonatomic, strong, nullable) NSURL *outputURL;

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

- (void)addListener:(id<CsoundObjListener>)listener;

@property (weak, nullable) id<CsoundMsgDelegate> messageDelegate;

// -----------------------------------------------------------------------------
#  pragma mark - Csound Internals / Advanced Methods
// -----------------------------------------------------------------------------

@property (nonatomic,readonly,getter=getCsound)       CSOUND *csound;

@property (readonly,nonatomic, getter=getNumChannels) int numChannels;
@property (readonly,nonatomic, getter=getKsmps)       int ksmps;


// get input or output that maps to a channel name and type, where type is
// CSOUND_AUDIO_CHANNEL, CSOUND_CONTROL_CHANNEL, etc.
- (nullable float *)getInputChannelPtr:(NSString *)channelName
                           channelType:(AKControlChannelType)channelType;
- (nullable float *)getOutputChannelPtr:(NSString *)channelName
                            channelType:(AKControlChannelType)channelType;

// Read-only samples
- (NSData *)getOutSamples;
- (NSData *)getInSamples;

// Writable alternatives
- (NSMutableData *)getMutableInSamples;
- (NSMutableData *)getMutableOutSamples;

// Reset the audio session, i.e. if we change audio I/O options
- (void)resetSession;

// -----------------------------------------------------------------------------
#  pragma mark - Csound debugger and breakpoints (not for release builds)
// -----------------------------------------------------------------------------

#ifdef DEBUG

typedef void (^AKBreakpointHandler)(NSString *opcode, int line, NSDictionary *vars);

/// The handler that is being called when breakpoints are triggered.
@property (strong,nonatomic) AKBreakpointHandler breakpointHandler;

- (void)debugStop;
- (void)debugContinue;
- (void)debugNext;

/** Set a breakpoint on a particular line
 *
 * @param line The line number in the score, when instr is 0.
 * @param instr When a number is given, it should
 * refer to an instrument that has been compiled on the fly using
 * csoundParseOrc().
 * @param skip Number of control blocks to skip.
 *
 */
- (void)setBreakpointAt:(int)line instrument:(int)instr skip:(int)skip;

/// Remove a previously set line breakpoint.
- (void)removeBreakpointAt:(int)line instrument:(int)instr;

/** Set a breakpoint for an instrument number
 *
 * Sets a breakpoint for an instrument number with optional number of skip
 * control blocks. You can specify a fractional instrument number to identify
 * particular instances. Specifying a value greater than 1 will result in that
 * number of control blocks being skipped before this breakpoint is called
 * again. A value of 0 and 1 has the same effect.
 *
 * @param instr Instrument number.
 * @param skip Number of control blocks to skip.
 */
- (void)setInstrumentBreakpoint:(float)instr skip:(int)skip;

/// Remove a previously set instrument breakpoint.
- (void)removeInstrumentBreakpoint:(float)instr;

/// Remove all previously set breakpoints.
- (void)clearBreakpoints;
#endif

// -----------------------------------------------------------------------------
#  pragma mark - Support for unit testing
// -----------------------------------------------------------------------------

- (void)setUpForTest;
- (void)teardownForTest;

@end
NS_ASSUME_NONNULL_END
