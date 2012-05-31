// CSDManager.m

#import "CSDManager.h"

@implementation CSDManager

@synthesize options;
@synthesize isRunning;

static CSDManager* _sharedCSDManager = nil;


+(CSDManager *)sharedCSDManager
{
    @synchronized([CSDManager class]) 
    {
        if(!_sharedCSDManager) 
            [[self alloc] init];
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
        isRunning = NO;

    }
    return self;
}   

-(void)runCSDFile:(NSString *)filename {
    NSLog(@"Running with %@.csd", filename);
    NSString *file = [[NSBundle mainBundle] pathForResource:filename ofType:@"csd"];  
    [csound startCsound:file];
    isRunning = YES;
}

-(void)runOrchestra:(CSDOrchestra *)orch {
    NSLog(@"Running With An Orchestra");
    
    isRunning = YES;
}

-(void)stop {
    NSLog(@"Stopping");
    [csound stopCsound];
    isRunning  = NO;
    
}

-(void)playNote:(NSString *)note{
    //[csound sendScore:<#(NSString *)#>
}

@end
