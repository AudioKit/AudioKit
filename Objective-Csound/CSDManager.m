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
        
        //Setup File System access
        NSString * templateFile = [[NSBundle mainBundle] pathForResource: @"template" ofType: @"csd"];
        templateCSDFileContents = [[NSString alloc] initWithContentsOfFile:templateFile  encoding:NSUTF8StringEncoding error:nil];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        myCSDFile = [NSString stringWithFormat:@"%@/%new.csd", documentsDirectory];

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
    NSLog(@"%@",[[NSString alloc] initWithContentsOfFile:file usedEncoding:nil error:nil]);

}

-(void) writeCSDFileForOrchestra:(CSDOrchestra *) orch {
    
    NSString * header = [NSString stringWithFormat:@"nchnls = 2\nsr = %d\n0dbfs = %f\nksmps = %d", 
                         sampleRate, zeroDBFullScaleValue, samplesPerControlPeriod];
    NSString * instrumentsText = [orch instrumentsForCsd];

    NSString * newCSD = [NSString stringWithFormat:templateCSDFileContents, options, header, instrumentsText, @""  ];
    
    [newCSD writeToFile:myCSDFile atomically:YES  encoding:NSStringEncodingConversionAllowLossy error:nil];

//    NSString * newCSD2 =  @"";
//    while (![newCSD2 isEqualToString:newCSD]) {
//        NSLog(@"retrying");
//        newCSD2 = [NSString stringWithContentsOfFile:myCSDFile encoding:NSStringEncodingConversionAllowLossy error:nil];
//    }

    NSLog(@"%@",[[NSString alloc] initWithContentsOfFile:myCSDFile usedEncoding:nil error:nil]);
}


-(void)runOrchestra:(CSDOrchestra *)orch {
    if(isRunning) {
        NSLog(@"csound already running...killing previous...attempting additional runOrch");
        [self stop];
    }
    NSLog(@"Running Orchestra with %i instruments", [[orch instruments] count]);
    [self writeCSDFileForOrchestra:orch];
    [csound startCsound:myCSDFile];
    isRunning = YES;
    
    //Clean up the IDs for next time
    [CSDOpcode resetID];
    [CSDFunctionTable resetID];
    [CSDInstrument resetID];
}

-(void)stop {
    NSLog(@"Stopping");
    [csound stopCsound];
    isRunning  = NO;
    
}

-(void)playNote:(NSString *)note OnInstrument:(CSDInstrument *)instrument{
    if ([csound getNumChannels] < 0) {
        NSLog(@"%@", @"Csound is not really running");
        return;
    }
    NSString * scoreline = [NSString stringWithFormat:@"i \"%@\" 0 %@", [instrument uniqueName], note];
    NSLog(@"%@", scoreline);
    [csound sendScore:scoreline];
}

#pragma mark CsoundObjCompletionListener

-(void)csoundObjDidStart:(CsoundObj *)csoundObj {
}

-(void)csoundObjComplete:(CsoundObj *)csoundObj {
}

@end
