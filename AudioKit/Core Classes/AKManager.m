//
//  AKManager.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 5/30/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "AKManager.h"

#import "AKStereoAudio.h" // Used for replace instrument which should be refactored

@interface AKManager () <CsoundObjListener> {
    NSString *options;
    NSString *csdFile;
    NSString *templateString;
    NSString *batchInstructions;
    BOOL isBatching;
    
    CsoundObj *csound;
    int totalRunDuration;
}

// Run Csound from a given filename
// @param filename CSD file use when running Csound.
- (void)runCSDFile:(NSString *)filename;

@end

@implementation AKManager

// -----------------------------------------------------------------------------
#  pragma mark - Singleton Setup
// -----------------------------------------------------------------------------

static AKManager *_sharedManager = nil;

+ (AKManager *)sharedManager
{
    @synchronized([AKManager class]) 
    {
        if(!_sharedManager) _sharedManager = [[self alloc] init];
        NSString *name = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
        if (name) {
            // This is an app that will contain the framework
            NSString *rawWavesDir = [NSString stringWithFormat:@"%@.app/Contents/Frameworks/CsoundLib64.framework/Resources/RawWaves", name];
            NSString *opcodeDir   = [NSString stringWithFormat:@"%@.app/Contents/Frameworks/CsoundLib64.framework/Resources/Opcodes64", name];
            csoundSetGlobalEnv("OPCODE6DIR64", [opcodeDir   cStringUsingEncoding:NSUTF8StringEncoding]);
            csoundSetGlobalEnv("RAWWAVE_PATH", [rawWavesDir cStringUsingEncoding:NSUTF8StringEncoding]);
        } else {
            // This is a command-line program that sits beside the framework
            csoundSetGlobalEnv("RAWWAVE_PATH", "CsoundLib64.framework/Resources/RawWaves");
            csoundSetGlobalEnv("OPCODE6DIR64", "CsoundLib64.framework/Resources/Opcodes64");
        }
        return _sharedManager;
    }
    return nil;
}

+ (id)alloc {
    @synchronized([AKManager class]) {
        NSAssert(_sharedManager == nil, @"Attempted to allocate a 2nd AKManager");
        _sharedManager = [super alloc];
        return _sharedManager;
    }
    return nil;
}

+ (NSString *)stringFromFile:(NSString *)filename {
    return [[NSString alloc] initWithContentsOfFile:filename 
                                           encoding:NSUTF8StringEncoding 
                                              error:nil];
}

- (instancetype)init {
    self = [super init];
    if (self != nil) {
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"AudioKit" ofType:@"plist"];
        NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:path];
        
        // Default Values
        NSString *audioOutput = @"dac";
        NSString *audioInput  = @"adc";
        
        if (dict) {
            audioOutput = dict[@"Audio Output"];
            audioInput  = dict[@"Audio Input"];
        }
        
        csound = [[CsoundObj alloc] init];
        _engine= csound; 
        [csound addListener:self];
        [csound setMessageCallback:@selector(messageCallback:) withListener:self];
        
        _isRunning = NO;
        _isLogging = [dict[@"Enable Logging By Default"] boolValue];
        
        totalRunDuration = 10000000;

        batchInstructions = [[NSString alloc] init];
        isBatching = NO;
        
        _orchestra = [[AKOrchestra alloc] init];

        options = [NSString stringWithFormat:
                   @"-o %@           ; Write sound to the host audio output\n"
                   "--expression-opt ; Enable expression optimizations\n"
                   "-m0              ; Print raw amplitudes\n"
                   "-i %@            ; Request sound from the host audio input device",
                   audioOutput, audioInput];
        
        templateString = @""
        "<CsoundSynthesizer>\n\n"
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
        "<CsScore>\nf0 %d\n</CsScore>\n\n"
        "</CsoundSynthesizer>\n";
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = paths[0];
        csdFile = [NSString stringWithFormat:@"%@/.new.csd", documentsDirectory];
        _midi = [[AKMidi alloc] init];
        _sequences = [NSMutableDictionary dictionary];
    }
    return self;
}   

// -----------------------------------------------------------------------------
#  pragma mark - Handling CSD Files
// -----------------------------------------------------------------------------

- (void)runCSDFile:(NSString *)filename 
{
    if(_isRunning) {
        if (_isLogging) NSLog(@"Csound instance already active.");
        [self stop];
    }
    NSString *file = [[NSBundle mainBundle] pathForResource:filename
                                                     ofType:@"csd"];  
    [csound play:file];
    if (_isLogging) NSLog(@"Starting %@ \n\n%@\n",filename, [AKManager stringFromFile:file]);
    while(!_isRunning) {
        if (_isLogging) NSLog(@"Waiting for Csound to startup completely.");
    }
    if (_isLogging) NSLog(@"Started.");
}

- (void)writeCSDFileForOrchestra:(AKOrchestra *)orchestra 
{
    NSString *newCSD = [NSString stringWithFormat:
                        templateString,
                        options, [orchestra stringForCSD], totalRunDuration];

    [newCSD writeToFile:csdFile 
             atomically:YES  
               encoding:NSStringEncodingConversionAllowLossy 
                  error:nil];
}

- (void)runOrchestra
{
    if(_isRunning) {
        if (_isLogging) NSLog(@"Csound instance already active.");
        [self stop];
    }
    [self writeCSDFileForOrchestra:_orchestra];
    
    [csound play:csdFile];
    if (_isLogging) NSLog(@"Starting \n\n%@\n", [AKManager stringFromFile:csdFile]);
    
    // Pause to allow Csound to start, warn if nothing happens after 1 second
    int cycles = 0;
    while(!_isRunning) {
        cycles++;
        if (cycles > 100) {
            if (_isLogging) NSLog(@"Csound has not started in 1 second." );
            break;
        }
        [NSThread sleepForTimeInterval:0.01];
    }
}

- (void)runOrchestraForDuration:(int)duration
{
    totalRunDuration = duration;
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
    [csound setUseAudioInput:YES];
}

/// Disable AudioInput
- (void)disableAudioInput {
    [csound setUseAudioInput:NO];    
}

// -----------------------------------------------------------------------------
#  pragma mark Recording Interface
// -----------------------------------------------------------------------------

- (void)stopRecording {
    [csound stopRecording];
}

- (void)startRecordingToURL:(NSURL *)url {
    [csound recordToURL:url];
}

// -----------------------------------------------------------------------------
#  pragma mark AKMidi
// -----------------------------------------------------------------------------

- (void)enableMidi
{
    [_midi openMidiIn];
}

- (void)disableMidi
{
    [_midi closeMidiIn];
}

// -----------------------------------------------------------------------------
#  pragma mark - Csound control
// -----------------------------------------------------------------------------

- (void)stop 
{
    if (_isLogging) NSLog(@"Stopping Csound");
    [csound stop];
    while(_isRunning) {} // Do nothing
}

- (void)triggerEvent:(AKEvent *)event
{
    [event runBlock];
}

- (void)startBatch
{
    isBatching = YES;
}

- (void)endBatch
{
    [csound sendScore:batchInstructions];
    batchInstructions = @"";
    isBatching = NO;
}

- (void)stopInstrument:(AKInstrument *)instrument
{
    if (_isLogging) NSLog(@"Stopping Instrument %d", [instrument instrumentNumber]);
    if (isBatching) {
        batchInstructions = [batchInstructions stringByAppendingString:[instrument stopStringForCSD]];
        batchInstructions = [batchInstructions stringByAppendingString:@"\n"];
    } else {
        [csound sendScore:[instrument stopStringForCSD]];
    }
    if (_isLogging) NSLog(@"%@", [instrument stopStringForCSD]);
}

- (void)stopNote:(AKNote *)note
{
    if (_isLogging) NSLog(@"Stopping Note with %@", [note stopStringForCSD]);
    
    if (isBatching) {
        batchInstructions = [batchInstructions stringByAppendingString:[note stopStringForCSD]];
        batchInstructions = [batchInstructions stringByAppendingString:@"\n"];
    } else {
        [csound sendScore:[note stopStringForCSD]];
    }
}

- (void)updateNote:(AKNote *)note
{
    if (_isLogging) NSLog(@"Updating Note: %@", [note stringForCSD]);
    
    if (isBatching) {
        batchInstructions = [batchInstructions stringByAppendingString:[note stringForCSD]];
        batchInstructions = [batchInstructions stringByAppendingString:@"\n"];
    } else {
        [csound sendScore:[note stringForCSD]];
    }
}

// -----------------------------------------------------------------------------
#  pragma mark - Csound Callbacks
// -----------------------------------------------------------------------------

- (void)messageCallback:(NSValue *)infoObj
{
	Message info;
	[infoObj getValue:&info];
	char message[1024];
	vsnprintf(message, 1024, info.format, info.valist);
	if (_isLogging) NSLog(@"%s", message);
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
    [[[self sharedManager] engine] addBinding:binding];
}

+ (void)removeBinding:(id)binding
{
    [[[self sharedManager] engine] removeBinding:binding];
}

@end
