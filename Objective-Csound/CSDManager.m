// CSDManager.m

#import "CSDManager.h"

@implementation CSDManager

//@synthesize options;
@synthesize isRunning;

static CSDManager * _sharedCSDManager = nil;


+(CSDManager *)sharedCSDManager
{
    @synchronized([CSDManager class]) 
    {
        if(!_sharedCSDManager) 
            _sharedCSDManager = [[self alloc] init];
        return _sharedCSDManager;
    }
    return nil;
}

+(id) alloc {
    NSLog(@"Allocating");
    @synchronized([CSDManager class]) {
        NSAssert(_sharedCSDManager == nil,
                 @"Attempted to allocate a second CSD Manager");
        _sharedCSDManager = [super alloc];
        return _sharedCSDManager;
    }
    return nil;
}

-(id) init {
    self = [super init];
    if (self != nil) {
        NSLog(@"Initializing");
        csound = [[CsoundObj alloc] init];
        [csound addCompletionListener:self];
        isRunning = NO;
        
        options = @"-odac -dm0 -+rtmidi=null -+rtaudio=null -+msg_color=0";
        sampleRate = 44100;
        samplesPerControlPeriod = 256;
        //int numberOfChannels = 1; //MONO
        zeroDBFullScaleValue = 1.0f;

    }
    return self;
}   

-(void)runCSDFile:(NSString *)filename {
    if(isRunning) {
        NSLog(@"csound already running...killing previous...attempting additional runCSDFile");
        [self stop];
    }
    
    NSLog(@"Running with %@.csd", filename);
    NSString *file = [[NSBundle mainBundle] pathForResource:filename ofType:@"csd"];  
    [csound startCsound:file];
    isRunning = YES;
}

-(void) writeString:(NSString *) content toFile:(NSString *) fileName{
    //get the documents directory:
    NSArray *paths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    //make a file name to write the data to using the documents directory:
    fileName = [NSString stringWithFormat:@"%@/%@", documentsDirectory, fileName];
    
    //save content to the documents directory
    [content writeToFile:fileName 
              atomically:NO 
                encoding:NSStringEncodingConversionAllowLossy 
                   error:nil];
    
}

-(void)runOrchestra:(CSDOrchestra *)orch {
    if(isRunning) {
        NSLog(@"csound already running...killing previous...attempting additional runOrch");
        [self stop];
    }
    
    NSLog(@"Running With An Orchestra");
    NSLog(@"Orchestra has %i instruments", [[orch instruments] count]);

    NSString * header = [NSString stringWithFormat:@"sr = %d\n0dbfs = %f\nksmps = %d", 
              sampleRate, zeroDBFullScaleValue, samplesPerControlPeriod];

    NSString * instrumentsText = [orch instrumentsForCsd];
    
    NSString * templateFile = [[NSBundle mainBundle] pathForResource: @"template" ofType: @"csd"];
    NSString * template = [[NSString alloc] initWithContentsOfFile:templateFile  encoding:NSUTF8StringEncoding error:nil];
    template = [NSString stringWithFormat:template, options, header, instrumentsText, @""  ];
    [self writeString:template toFile:@"new.csd"];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString * fileName = [NSString stringWithFormat:@"%@/new.csd", documentsDirectory];
    NSLog(@"%@",[[NSString alloc] initWithContentsOfFile:fileName usedEncoding:nil error:nil]);
    
    [csound startCsound:fileName];
    
    isRunning = YES;
}

-(void)stop {
    NSLog(@"Stopping");
    [csound stopCsound];
    isRunning  = NO;
    
}

-(void)playNote:(NSString *)note OnInstrument:(int)instrument{
    NSLog(@"i%i 0 %@", instrument, note);
    [csound sendScore:[NSString stringWithFormat:@"i%i 0 %@", instrument, note]];
}

#pragma mark CsoundObjCompletionListener

-(void)csoundObjDidStart:(CsoundObj *)csoundObj {
}

-(void)csoundObjComplete:(CsoundObj *)csoundObj {
}

@end
