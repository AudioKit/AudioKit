// CSDManager.m

#import "CSDManager.h"
#import "CSDPropertyManager.h"

@implementation CSDManager

//@synthesize options;
@synthesize isRunning;
//@synthesize myPropertyManager;

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
        
        //myPropertyManager = [[CSDPropertyManager alloc] init];
        
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
        NSLog(@"Csound instance already active.");
        [self stop];
    }
    
    NSLog(@"Running with %@.csd", filename);
    NSString *file = [[NSBundle mainBundle] pathForResource:filename ofType:@"csd"];  
    [csound startCsound:file];
    isRunning = YES;
    NSLog(@"Starting \n%@",[[NSString alloc] initWithContentsOfFile:file usedEncoding:nil error:nil]);

}

-(void) writeCSDFileForOrchestra:(CSDOrchestra *) orch {
    
    NSString * header = [NSString stringWithFormat:@"nchnls = 2\nsr = %d\n0dbfs = %f\nksmps = %d", 
                         sampleRate, zeroDBFullScaleValue, samplesPerControlPeriod];
    NSString * instrumentsText = [orch instrumentsForCsd];

    NSString * newCSD = [NSString stringWithFormat:templateCSDFileContents, options, header, instrumentsText, @""  ];
    
    [newCSD writeToFile:myCSDFile atomically:YES  encoding:NSStringEncodingConversionAllowLossy error:nil];
}

-(void)runOrchestra:(CSDOrchestra *)orch {
    if(isRunning) {
        NSLog(@"Csound instance already active.");
        [self stop];
    }
    NSLog(@"Running Orchestra with %i instruments", [[orch instruments] count]);
    
    [self writeCSDFileForOrchestra:orch];
    [self updateValueCacheWithProperties:orch];
    [csound startCsound:myCSDFile];
    isRunning = YES;
    
    NSLog(@"Starting \n%@",[[NSString alloc] initWithContentsOfFile:myCSDFile usedEncoding:nil error:nil]);
    
    //Clean up the IDs for next time
    [CSDOpcode resetID];
    [CSDFunctionTable resetID];
    [CSDInstrument resetID];
    [CSDProperty resetID];
}

-(void)stop {
    NSLog(@"Stopping Csound");
    [csound stopCsound];
    isRunning  = NO;
    // Hackfor giving csound time to fully stop before trying to restart
    [NSThread sleepForTimeInterval:0.1];
}

-(void)playNote:(NSString *)note OnInstrument:(CSDInstrument *)instrument{
    if ([csound getNumChannels] < 0) {
        NSLog(@"%@", @"Csound is not really running");
        [self runOrchestra:[instrument orchestra]];
        return;
    }
    NSString * scoreline = [NSString stringWithFormat:@"i \"%@\" 0 %@", [instrument uniqueName], note];
    NSLog(@"%@", scoreline);
    [csound sendScore:scoreline];
}

-(void)updateValueCacheWithProperties:(CSDOrchestra *)orch
{
    NSArray *arr = [NSArray arrayWithArray:[orch instruments]];
    for (CSDInstrument *i in arr ) {
        for (CSDProperty *c in [i propertyList]) {
            [csound addValueCacheable:c];
        }
    }
}

#pragma mark CsoundObjCompletionListener

-(void)csoundObjDidStart:(CsoundObj *)csoundObj {
}

-(void)csoundObjComplete:(CsoundObj *)csoundObj {
}

@end
