//
//  OCSManager.m
//  Objective-Csound
//
//  Created by Aurelius Prochazka on 5/30/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSManager.h"

@interface OCSManager () {
    BOOL isRunning;
    BOOL isMidiEnabled;
    OCSHeader *header;
    NSString *options;
    NSString *csdFile;
    NSString *templateString;
    
    CsoundObj *csound;
    OCSMidi *midi;
}
@end

@implementation OCSManager

@synthesize isRunning;
@synthesize isMidiEnabled;
@synthesize header;

//@synthesize myPropertyManager;

static OCSManager *_sharedOCSManager = nil;


+ (OCSManager *)sharedOCSManager
{
    @synchronized([OCSManager class]) 
    {
        if(!_sharedOCSManager) _sharedOCSManager = [[self alloc] init];
        return _sharedOCSManager;
    }
    return nil;
}

+ (id)alloc {
    @synchronized([OCSManager class]) {
        NSAssert(_sharedOCSManager == nil, @"Attempted to allocate a 2nd OCSManager");
        _sharedOCSManager = [super alloc];
        return _sharedOCSManager;
    }
    return nil;
}

+ (NSString *)stringFromFile:(NSString *)filename {
    return [[NSString alloc] initWithContentsOfFile:filename 
                                           encoding:NSUTF8StringEncoding 
                                              error:nil];
}

/// Initializes to default values
- (id)init {
    self = [super init];
    if (self != nil) {
        csound = [[CsoundObj alloc] init];
        [csound addCompletionListener:self];
        [csound setMessageCallback:@selector(messageCallback:) withListener:self];
        
        isRunning = NO;
        isMidiEnabled = NO;
        
        //myPropertyManager = [[OCSPropertyManager alloc] init];
        
        options = @"-odac -+rtmidi=null -+rtaudio=null -dm0";
        header = [[OCSHeader alloc] init];
        
        //Setup File System access
        NSString *template;
        template = [[NSBundle mainBundle] pathForResource: @"template" ofType: @"csd"];
        templateString = [OCSManager stringFromFile:template]; 
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        csdFile = [NSString stringWithFormat:@"%@/new.csd", documentsDirectory];
        
        midi = [[OCSMidi alloc] init];
    }
    return self;
}   

- (void)runCSDFile:(NSString *)filename 
{
    if(isRunning) {
        NSLog(@"Csound instance already active.");
        [self stop];
    }
    NSString *file = [[NSBundle mainBundle] pathForResource:filename 
                                                     ofType:@"csd"];  
    [csound startCsound:file];
    NSLog(@"Starting %@ \n\n%@\n",filename, [OCSManager stringFromFile:file]);
    while(!isRunning) {
        NSLog(@"Waiting for Csound to startup completely.");
    }
}

- (void)writeCSDFileForOrchestra:(OCSOrchestra *)orchestra 
{
    NSString *newCSD = [NSString stringWithFormat:
                        templateString, options, header, 
                        [orchestra fTableStringForCSD],
                        [orchestra stringForCSD]];

    [newCSD writeToFile:csdFile 
             atomically:YES  
               encoding:NSStringEncodingConversionAllowLossy 
                  error:nil];
}

- (void)runOrchestra:(OCSOrchestra *)orchestra 
{
    if(isRunning) {
        NSLog(@"Csound instance already active.");
        [self stop];
    }    
    [self writeCSDFileForOrchestra:orchestra];
    [self updateValueCacheWithProperties:orchestra];
    [self updateMidiProperties:orchestra];
    [csound startCsound:csdFile];
    NSLog(@"Starting \n\n%@\n", [OCSManager stringFromFile:csdFile]);

    // Clean up the IDs for next time
    [OCSParameter resetID];
    [OCSInstrument resetID];
    
    // Pause to allow Csound to start, warn if nothing happens after 1 second
    int cycles = 0;
    while(!isRunning) {
        cycles++;
        if (cycles > 100) {
            NSLog(@"Csound has not started in 1 second." );
            break;
        }
        [NSThread sleepForTimeInterval:0.01];
    } 
}

- (void)stop 
{
    NSLog(@"Stopping Csound");
    [csound stopCsound];
    while(isRunning) {} // Do nothing
}

- (void)playNote:(NSString *)note OnInstrument:(OCSInstrument *)instrument
{
    NSString *scoreline = [NSString stringWithFormat:
                           @"i \"%@\" 0 %@", [instrument uniqueName], note];
    [csound sendScore:scoreline];
}

- (void)updateValueCacheWithProperties:(OCSOrchestra *)orchestra
{
    NSArray *arr = [NSArray arrayWithArray:[orchestra instruments]];
    for (OCSInstrument *instrument in arr ) {
        for (OCSProperty *c in [instrument properties]) {
            [csound addValueCacheable:c];
        }
    }
}

- (void)updateMidiProperties:(OCSOrchestra *)orchestra
{
    NSArray *arr = [NSArray arrayWithArray:[orchestra instruments]];
    for (OCSInstrument *i in arr) {
        for (OCSProperty *p in [i properties]) {
            if( [p isMidiEnabled]) {
                [midi addProperty:p];
            }
        }
    }
}

#pragma mark CsoundCallbacks
- (void)messageCallback:(NSValue *)infoObj
{
	Message info;
	[infoObj getValue:&info];
	char message[1024];
	vsnprintf(message, 1024, info.format, info.valist);
	NSLog(@"%s", message);
}

#pragma mark CsoundObjCompletionListener

- (void)csoundObjDidStart:(CsoundObj *)csoundObj {
    NSLog(@"Csound Started.");
    isRunning = YES;
}

- (void)csoundObjComplete:(CsoundObj *)csoundObj {
    NSLog(@"Csound Completed.");
    isRunning  = NO;
}

#pragma mark OCSMidi
- (void)enableMidi 
{
    NSLog(@"Csound midi enabled");
    [csound setMidiInEnabled:YES];
    isMidiEnabled = YES;
    [midi openMidiIn];
}
@end
