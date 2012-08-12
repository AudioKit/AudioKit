//
//  OCSManager.m
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 5/30/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSManager.h"

@interface OCSManager () {
    BOOL isRunning;
    NSString *options;
    NSString *csdFile;
    NSString *templateString;
    
    CsoundObj *csound;
}
@end

@implementation OCSManager

@synthesize isRunning;

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

- (id)init {
    self = [super init];
    if (self != nil) {
        csound = [[CsoundObj alloc] init];
        [csound addCompletionListener:self];
        [csound setMessageCallback:@selector(messageCallback:) withListener:self];
        
        isRunning = NO;
        
//        "-+rtmidi=null    ; Disable the use of any realtime midi plugin\n"
//        "-+rtaudio=null   ; Disable the use of any realtime audio plugin\n"
        options = @"-o dac           ; Write sound to the host audio output\n"
                   "-d               ; Suppress all displays\n"
                   "-+msg_color=0    ; Disable message attributes\n"
                   "--expression-opt ; Enable expression optimatizations\n"
                   "-m0              ; Print raw amplitudes\n";
                  // "-i adc           ; Request sound from the host audio input device";
        
        //Setup File System access
        NSString *template;
        template = [[NSBundle mainBundle] pathForResource: @"template" ofType: @"csd"];
        templateString = [OCSManager stringFromFile:template]; 
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        csdFile = [NSString stringWithFormat:@"%@/new.csd", documentsDirectory];
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
        //NSLog(@"Waiting for Csound to startup completely.");
    }
    NSLog(@"Started.");
}

- (void)writeCSDFileForOrchestra:(OCSOrchestra *)orchestra 
{
    NSString *newCSD = [NSString stringWithFormat:templateString, options, [orchestra stringForCSD]];

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
    
    [csound startCsound:csdFile];
    NSLog(@"Starting \n\n%@\n", [OCSManager stringFromFile:csdFile]);

    // Clean up the IDs for next time
    [OCSParameter resetID];
    [OCSInstrument resetID];
    [OCSEvent resetID];
    
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

- (void)triggerEvent:(OCSEvent *)event  
{
    if ([[event notePropertyValues] count] > 0 ) {
        [event setNoteProperties];
    }
    if ([[event properties] count] > 0) {
        [event setInstrumentProperties];
    }
    [csound sendScore:[event stringForCSD]];
}

- (void)updateValueCacheWithProperties:(OCSOrchestra *)orchestra
{
    NSArray *arr = [NSArray arrayWithArray:[orchestra instruments]];
    for (OCSInstrument *instrument in arr ) {
        for (OCSInstrumentProperty *c in [instrument properties]) {
            [csound addValueCacheable:c];
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

@end
