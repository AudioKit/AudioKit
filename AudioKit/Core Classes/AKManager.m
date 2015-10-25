//
//  AKManager.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 5/30/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//
#import <TargetConditionals.h>
#import "csound.h"

#if TARGET_OS_IPHONE
@import UIKit;
#elif TARGET_OS_MAC
@import AppKit;
#endif

#import "AKManager.h"
#import "AKSettings.h"

#import "AKStereoAudio.h" // Used for replace instrument which should be refactored


@interface AKManager () <CsoundObjListener, CsoundMsgDelegate> {
    NSString *_options;
    NSString *_csdFile;
    NSString *_batchInstructions;
    BOOL _isBatching;
    NSTimeInterval _totalRunDuration;
}

@end

@implementation AKManager

// -----------------------------------------------------------------------------
#  pragma mark - Singleton Setup
// -----------------------------------------------------------------------------

static AKManager *_sharedManager = nil;

+ (AKManager *)sharedManager
{
    @synchronized(self)
    {
        if(!_sharedManager) _sharedManager = [[self alloc] init];
        NSString *name = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
        if (name) {
            // This is an app that will contain the framework
            NSString *rawWavesDir = [NSString stringWithFormat:@"%@.app/Contents/Frameworks/CsoundLib.framework/Resources/RawWaves", name];
            NSString *opcodeDir   = [NSString stringWithFormat:@"%@.app/Contents/Frameworks/CsoundLib.framework/Resources/Opcodes", name];
            csoundSetGlobalEnv("OPCODE6DIR", [opcodeDir   cStringUsingEncoding:NSUTF8StringEncoding]);
            csoundSetGlobalEnv("RAWWAVE_PATH", [rawWavesDir cStringUsingEncoding:NSUTF8StringEncoding]);
        } else {
            // This is a command-line program that sits beside the framework
            csoundSetGlobalEnv("RAWWAVE_PATH", "CsoundLib.framework/Resources/RawWaves");
            csoundSetGlobalEnv("OPCODE6DIR", "CsoundLib.framework/Resources/Opcodes");
        }
        return _sharedManager;
    }
    return nil;
}

+ (id)alloc {
    @synchronized(self) {
        NSAssert(_sharedManager == nil, @"Attempted to allocate a 2nd AKManager");
        _sharedManager = [super alloc];
        return _sharedManager;
    }
    return nil;
}

+ (NSString *)stringFromFile:(NSString *)filename {
    NSError *err;
    NSString *str = [[NSString alloc] initWithContentsOfFile:filename
                                                    encoding:NSUTF8StringEncoding
                                                       error:&err];
    if (!str) {
        NSLog(@"Error reading contents of file %@: %@", filename, err);
    }
    return str;
}

+ (NSString *)pathToSoundFile:(NSString *)filename ofType:(NSString *)extension
{
    NSString *path = [[NSBundle mainBundle] pathForResource:filename ofType:extension
                                                   inDirectory:@"AKSoundFiles.bundle/Sounds"];
    NSAssert(path, @"Make sure to include AKSoundFiles.bundle in your project's resources! Unable to locate file: %@.%@", filename, extension);
    
    // If the file is still nil and we haven't aborted, then we are probably in tests
    if (!path) {
        path = [NSString stringWithFormat:@"AKSoundFiles.bundle/Sounds/%@.%@", filename, extension];
    }
    return path;
}

- (instancetype)init {
    self = [super init];
    if (self != nil) {
        
        _engine = [[CsoundObj alloc] init];
        [_engine addListener:self];
        _engine.messageDelegate = self;

#if !TARGET_OS_TV
        if (AKSettings.shared.MIDIEnabled) {
            _midi = [[AKMidi alloc] init];
        }
#endif

        _isRunning = NO;
        _isLogging = AKSettings.shared.loggingEnabled;
        _totalRunDuration = 10000000;

        _batchInstructions = [[NSString alloc] init];
        _isBatching = NO;
        
        _orchestra = [[AKOrchestra alloc] init];
        
        NSString *inputOption = [NSString stringWithFormat:@"-i %@", AKSettings.shared.audioInput];
#ifdef AK_TESTING
        inputOption = @"";
#endif

        _options = [NSString stringWithFormat:
                    @"-o %@           ; Write sound to the host audio output\n"
                    "--expression-opt ; Enable expression optimizations\n"
                    "-m0              ; Print raw amplitudes\n"
                    "-M0              ; Enable MIDI internally\n"
                    "-+rtmidi=null    ; No MIDI driver\n"
                    "%@\n",
                    AKSettings.shared.audioOutput, inputOption];
        
        _csdFile = [NSString stringWithFormat:@"%@/AudioKit-%@.csd", NSTemporaryDirectory(), @(getpid())];
        _sequences = [NSMutableDictionary dictionary];
        
        // Get notified when the application ends so we can a chance to do some cleanups
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_applicationWillTerminate:)
#if TARGET_OS_IPHONE
                                                     name:UIApplicationWillTerminateNotification
#elif TARGET_OS_MAC
                                                     name:NSApplicationWillTerminateNotification
#endif
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)cleanup
{
    [self.engine stop];
    [[NSFileManager defaultManager] removeItemAtPath:_csdFile error:nil];
}

- (void)_applicationWillTerminate:(NSNotification *)notification
{
    [self cleanup];
}

// -----------------------------------------------------------------------------
#  pragma mark - Handling CSD Files
// -----------------------------------------------------------------------------

- (void)writeCSDFileForOrchestra:(AKOrchestra *)orchestra 
{
    NSString *newCSD = [NSString stringWithFormat:
                        @"<CsoundSynthesizer>\n\n"
                        "<CsOptions>\n\%@\n</CsOptions>\n\n"
                        "<CsInstruments>\n\n"
                        "\%@\n"
                        "opcode AKControl, k, a \n ain xin \n xout downsamp(ain)       \n endop\n"
                        "opcode AKAudio,   a, k \n kin xin \n xout upsamp(kin)         \n endop\n"
                        "opcode AKAudio,   a, a \n ain xin \n aout = ain \n xout aout  \n endop\n"
                        "opcode AKControl, k, k \n kin xin \n kout = kin \n xout kout  \n endop\n"
                        "instr 1000 ; Turn off all notes    \n turnoff2 p4, 0, 1 \n endin \n"
                        "instr 1001 ; Event end or note off \n turnoff2 p4, 4, 1 \n endin \n"
                        "</CsInstruments>\n\n"
                        "<CsScore>\nf0 %ld\n</CsScore>\n\n"
                        "</CsoundSynthesizer>\n",
                        _options, [orchestra stringForCSD], lround(_totalRunDuration)];
    NSError *err;
    
    if ([newCSD writeToFile:_csdFile
                 atomically:YES
                   encoding:NSStringEncodingConversionAllowLossy
                      error:&err] == NO) {
        NSLog(@"Failed to write CSD file: %@", err);
    }
}

- (void)renderToFile:(NSString *)outputPath forDuration:(NSTimeInterval)duration
{
    _totalRunDuration = duration;
    [self writeCSDFileForOrchestra:_orchestra];
    [self.engine record:_csdFile toFile:outputPath];
}

- (void)runOrchestra
{
#ifdef AK_TESTING
    return;
#else
    if(_isRunning) {
        if (_isLogging) NSLog(@"Csound instance already active.");
        [self stop];
    }
    [self writeCSDFileForOrchestra:_orchestra];
    
    [self.engine play:_csdFile];
    if (_isLogging) NSLog(@"Starting \n\n%@\n", [AKManager stringFromFile:_csdFile]);
    
    // Pause to allow Csound to start, warn if nothing happens after 1 second
    int cycles = 0;
    while(!_isRunning) {
        cycles++;
        if (cycles > 100) {
            if (_isLogging) NSLog(@"Csound has not started in 1 second.");
            break;
        }
        [NSThread sleepForTimeInterval:0.01];
    }
#endif
}

- (void)runOrchestraForDuration:(NSTimeInterval)duration
{
    _totalRunDuration = duration;
    [self runOrchestra];
}

- (void)resetOrchestra
{
    _orchestra = [[AKOrchestra alloc] init];
}

// -----------------------------------------------------------------------------
#  pragma mark Audio Input from Hardware
// -----------------------------------------------------------------------------

/// Enable Audio Input
- (void)enableAudioInput {
    AKSettings.shared.audioInputEnabled = YES;
}

/// Disable AudioInput
- (void)disableAudioInput {
    AKSettings.shared.audioInputEnabled = NO;
}

// -----------------------------------------------------------------------------
#  pragma mark Recording Interface
// -----------------------------------------------------------------------------

- (void)stopRecording {
    [self.engine stopRecording];
}

- (void)startRecordingToURL:(NSURL *)url {
    [self.engine recordToURL:url];
}

// -----------------------------------------------------------------------------
#  pragma mark - Csound control
// -----------------------------------------------------------------------------

- (void)stop 
{
    if (_isLogging) NSLog(@"Stopping Csound");
    [self.engine stop];
}

- (void)triggerEvent:(AKEvent *)event
{
    [event runBlock];
}

- (void)startBatch
{
    _isBatching = YES;
}

- (void)endBatch
{
    [self.engine sendScore:_batchInstructions];
    _batchInstructions = @"";
    _isBatching = NO;
}

- (void)stopInstrument:(AKInstrument *)instrument
{
    if (_isLogging) NSLog(@"Stopping Instrument %@", @(instrument.instrumentNumber));
    if (_isBatching) {
        _batchInstructions = [_batchInstructions stringByAppendingString:[instrument stopStringForCSD]];
        _batchInstructions = [_batchInstructions stringByAppendingString:@"\n"];
    } else {
        [self.engine sendScore:[instrument stopStringForCSD]];
    }
    if (_isLogging) NSLog(@"%@", [instrument stopStringForCSD]);
}

- (void)stopNote:(AKNote *)note
{
    if (_isLogging) NSLog(@"Stopping Note with %@", [note stopStringForCSD]);
    
    if (_isBatching) {
        _batchInstructions = [_batchInstructions stringByAppendingString:[note stopStringForCSD]];
        _batchInstructions = [_batchInstructions stringByAppendingString:@"\n"];
    } else {
        [self.engine sendScore:[note stopStringForCSD]];
    }
}

- (void)updateNote:(AKNote *)note
{
    if (_isLogging) NSLog(@"Updating Note: %@", [note stringForCSD]);
    
    if (_isBatching) {
        _batchInstructions = [_batchInstructions stringByAppendingString:[note stringForCSD]];
        _batchInstructions = [_batchInstructions stringByAppendingString:@"\n"];
    } else {
        [self.engine sendScore:[note stringForCSD]];
    }
}

// -----------------------------------------------------------------------------
#  pragma mark - Csound Callbacks
// -----------------------------------------------------------------------------

- (void)messageReceivedFrom:(CsoundObj *)csoundObj attr:(int)attr message:(NSString *)msg
{    
    if ([msg length] > 4 && [[msg substringToIndex:5] isEqualToString:@"clock"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AKBeatClock"
                                                            object:nil
                                                          userInfo:@{@"message":[msg substringFromIndex:6]}];
    } 

    if (_isLogging && [msg rangeOfString: @"clock"].location != 0) {
        if (AKSettings.shared.messagesEnabled) {
            NSLog(@"Csound(%d): %@", attr, msg);
        } else {
            NSLog(@"%@", msg);
        }
    } else if (attr & CSOUNDMSG_ERROR) {
        NSLog(@"Csound Error: %@", msg);
    }
}

- (void)csoundObjWillStart:(CsoundObj *)csoundObj
{
    [_midi connectToCsound:_engine];
}

- (void)csoundObjStarted:(CsoundObj *)csoundObj {
    if (_isLogging) NSLog(@"Csound Started.");
    _isRunning = YES;
}

- (void)csoundObjCompleted:(CsoundObj *)csoundObj {
    if (_isLogging) NSLog(@"Csound Completed.");
    _isRunning  = NO;
}

+ (void)addBinding:(id)binding
{
    [[self sharedManager].engine addBinding:binding];
}

+ (void)removeBinding:(id)binding
{
    [[self sharedManager].engine removeBinding:binding];
}

@end
