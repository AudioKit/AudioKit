//
//  AKManager.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 5/30/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKManager.h"
#import "CsoundObj.h"

@interface AKManager () <CsoundObjListener> {
    NSString *options;
    NSString *csdFile;
    NSString *templateString;
    
    CsoundObj *csound;
}

// Run Csound from a given filename
// @param filename CSD file use when running Csound.
- (void)runCSDFile:(NSString *)filename;

@end

@implementation AKManager

// -----------------------------------------------------------------------------
#  pragma mark - Singleton Setup
// -----------------------------------------------------------------------------


static AKManager *_sharedAKManager = nil;

+ (AKManager *)sharedAKManager
{
    @synchronized([AKManager class]) 
    {
        if(!_sharedAKManager) _sharedAKManager = [[self alloc] init];
        return _sharedAKManager;
    }
    return nil;
}

+ (id)alloc {
    @synchronized([AKManager class]) {
        NSAssert(_sharedAKManager == nil, @"Attempted to allocate a 2nd AKManager");
        _sharedAKManager = [super alloc];
        return _sharedAKManager;
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
        csound = [[CsoundObj alloc] init];
        [csound addListener:self];
        [csound setMessageCallback:@selector(messageCallback:) withListener:self];
        
        _isRunning = NO;
        
//        "-+rtmidi=null    ; Disable the use of any realtime midi plugin\n"
//        "-+rtaudio=null   ; Disable the use of any realtime audio plugin\n"
        options = @"-o dac           ; Write sound to the host audio output\n"
                   "-d               ; Suppress all displays\n"
                   "-+msg_color=0    ; Disable message attributes\n"
                   "--expression-opt ; Enable expression optimatizations\n"
                   "-m0              ; Print raw amplitudes\n"
                   "-i adc           ; Request sound from the host audio input device";
        
        templateString = @""
        "<CsoundSynthesizer>\n\n"
        "<CsOptions>\n\%@\n</CsOptions>\n\n"
        "<CsInstruments>\n\n"
        "\%@\n\n"
        "; Deactivates a complete instrument\n"
        "instr DeactivateInstrument\n"
        "turnoff2 p4, 0, 1\n"
        "endin\n\n"
        "; Event End or Note Off\n"
        "instr DeactivateNote\n"
        "turnoff2 p4, 4, 1\n"
        "endin\n\n"
        "</CsInstruments>\n\n"
        "<CsScore>\nf0 10000000\n</CsScore>\n\n"
        "</CsoundSynthesizer>\n";
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = paths[0];
        csdFile = [NSString stringWithFormat:@"%@/.new.csd", documentsDirectory];
        _midi = [[AKMidi alloc] init];
    }
    return self;
}   

// -----------------------------------------------------------------------------
#  pragma mark - Handling CSD Files
// -----------------------------------------------------------------------------

- (void)runCSDFile:(NSString *)filename 
{
    if(_isRunning) {
        NSLog(@"Csound instance already active.");
        [self stop];
    }
    NSString *file = [[NSBundle mainBundle] pathForResource:filename
                                                     ofType:@"csd"];  
    [csound play:file];
    NSLog(@"Starting %@ \n\n%@\n",filename, [AKManager stringFromFile:file]);
    while(!_isRunning) {
        //NSLog(@"Waiting for Csound to startup completely.");
    }
    NSLog(@"Started.");
}

- (void)writeCSDFileForOrchestra:(AKOrchestra *)orchestra 
{
    NSString *newCSD = [NSString stringWithFormat:templateString, options, [orchestra stringForCSD]];

    [newCSD writeToFile:csdFile 
             atomically:YES  
               encoding:NSStringEncodingConversionAllowLossy 
                  error:nil];
}

- (void)runOrchestra:(AKOrchestra *)orchestra 
{
    if(_isRunning) {
        NSLog(@"Csound instance already active.");
        [self stop];
    }
    [self writeCSDFileForOrchestra:orchestra];
    [self updateBindingsWithProperties:orchestra];
    
    [csound play:csdFile];
    NSLog(@"Starting \n\n%@\n", [AKManager stringFromFile:csdFile]);

    // Clean up the IDs for next time
    //[AKParameter resetID]; //Should work but generating lots of out of bounds errors
    [AKInstrument resetID];
    [AKNote resetID];
    
    // Pause to allow Csound to start, warn if nothing happens after 1 second
    int cycles = 0;
    while(!_isRunning) {
        cycles++;
        if (cycles > 100) {
            NSLog(@"Csound has not started in 1 second." );
            break;
        }
        [NSThread sleepForTimeInterval:0.01];
    } 
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
    [csound setUseAudioInput:YES];    
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
    NSLog(@"Stopping Csound");
    [csound stop];
    while(_isRunning) {} // Do nothing
}

- (void)triggerEvent:(AKEvent *)event
{
    [event playNote];
    [event runBlock];
}

- (void)stopInstrument:(AKInstrument *)instrument
{
    NSLog(@"Stopping Instrument with '%@'", [instrument stopStringForCSD]);
    [csound sendScore:[instrument stopStringForCSD]];
}

- (void)stopNote:(AKNote *)note
{
    NSLog(@"Stopping Note with %@", [note stopStringForCSD]);
    [csound sendScore:[note stopStringForCSD]];
}

- (void)updateNote:(AKNote *)note
{
    NSLog(@"updating Note with %@", [note stringForCSD]);
    [csound sendScore:[note stringForCSD]];
}

- (void)updateBindingsWithProperties:(AKOrchestra *)orchestra
{
    NSArray *arr = [NSArray arrayWithArray:[orchestra instruments]];
    for (AKInstrument *instrument in arr ) {
        for (AKInstrumentProperty *c in [instrument properties]) {
            [csound addBinding:(AKInstrumentProperty<CsoundBinding> *)c];
        }
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
	NSLog(@"%s", message);
}

- (void)csoundObjDidStart:(CsoundObj *)csoundObj {
    NSLog(@"Csound Started.");
    _isRunning = YES;
}

- (void)csoundObjComplete:(CsoundObj *)csoundObj {
    NSLog(@"Csound Completed.");
    _isRunning  = NO;
}

@end
