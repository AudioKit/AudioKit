//
//  OCSManager.m
//
//  Created by Aurelius Prochazka on 5/30/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSManager.h"
#import "OCSPropertyManager.h"

@interface OCSManager () {
    //TODO: odbfs, sr stuff
    BOOL isRunning;
    NSString *options;
    int sampleRate;
    int samplesPerControlPeriod;
    NSNumber *zeroDBFullScaleValue;
    NSString *myCSDFile;
    NSString *templateCSDFileContents;
    
    //OCSPropertyManager *myPropertyManager;
    
    CsoundObj *csound;
}
@end

@implementation OCSManager

@synthesize isRunning;
@synthesize zeroDBFullScaleValue;
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

/// Initializes to default values
- (id)init {
    self = [super init];
    if (self != nil) {
        csound = [[CsoundObj alloc] init];
        [csound addCompletionListener:self];
        [csound setMessageCallback:@selector(messageCallback:) withListener:self];
        
        isRunning = NO;
        
        //myPropertyManager = [[OCSPropertyManager alloc] init];
        
        options = @"-odac -+rtmidi=null -+rtaudio=null -dm0";
        sampleRate = 44100;
        samplesPerControlPeriod = 256;
        //int numberOfChannels = 1; //MONO
        zeroDBFullScaleValue = [NSNumber numberWithFloat:1.0f];
        
        //Setup File System access
        NSString *templateFile = [[NSBundle mainBundle] pathForResource: @"template" 
                                                                  ofType: @"csd"];
        templateCSDFileContents = [[NSString alloc] initWithContentsOfFile:templateFile  
                                                                  encoding:NSUTF8StringEncoding 
                                                                     error:nil];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        myCSDFile = [NSString stringWithFormat:@"%@/new.csd", documentsDirectory];

    }
    return self;
}   

- (void)runCSDFile:(NSString *)filename 
{
    if(isRunning) {
        NSLog(@"Csound instance already active.");
        [self stop];
    }
    
    NSLog(@"Running with %@.csd", filename);
    NSString *file = [[NSBundle mainBundle] pathForResource:filename 
                                                     ofType:@"csd"];  
    [csound startCsound:file];
    NSLog(@"Starting \n\n%@\n",[[NSString alloc] initWithContentsOfFile:file 
                                                           usedEncoding:nil 
                                                                  error:nil]);
    while(!isRunning) {
        NSLog(@"Waiting for Csound to startup completely.");
    }
}

- (void)writeCSDFileForOrchestra:(OCSOrchestra *) orchestra 
{
    NSString *header = [NSString stringWithFormat:@"nchnls = 2\nsr = %d\n0dbfs = %@\nksmps = %d", 
                         sampleRate, zeroDBFullScaleValue, samplesPerControlPeriod];
    NSString *newCSD = [NSString stringWithFormat:templateCSDFileContents, options, header, [orchestra stringForCSD], @""  ];

    [newCSD writeToFile:myCSDFile 
             atomically:YES  
               encoding:NSStringEncodingConversionAllowLossy 
                  error:nil];
}

- (void)runOrchestra:(OCSOrchestra *)orch 
{
    if(isRunning) {
        NSLog(@"Csound instance already active.");
        [self stop];
    }
    NSLog(@"Running Orchestra with %i instruments", [[orch instruments] count]);
    
    [self writeCSDFileForOrchestra:orch];
    [self updateValueCacheWithProperties:orch];
    [csound startCsound:myCSDFile];
    NSLog(@"Starting \n\n%@\n",[[NSString alloc] initWithContentsOfFile:myCSDFile usedEncoding:nil error:nil]);

    // Clean up the IDs for next time
    [OCSParameter resetID];
    [OCSInstrument resetID];
    
    // Pause to give Csound time to start, warn if nothing happens after one second
    int cycles = 0;
    while(!isRunning) {
        cycles++;
        if (cycles > 100) {
            NSLog(@"There might be a bug in the generated CSD File, Csound has not started" );
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
    NSString *scoreline = [NSString stringWithFormat:@"i \"%@\" 0 %@", [instrument uniqueName], note];
    NSLog(@"%@", scoreline);
    [csound sendScore:scoreline];
}

#pragma mark CsoundCallbacks

- (void)updateValueCacheWithProperties:(OCSOrchestra *)orchestra
{
    NSArray *arr = [NSArray arrayWithArray:[orchestra instruments]];
    for (OCSInstrument *instrument in arr ) {
        for (OCSProperty *c in [instrument properties]) {
            [csound addValueCacheable:c];
        }
    }
}
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
