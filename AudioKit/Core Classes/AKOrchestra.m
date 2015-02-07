//
//  AKOrchestra.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 5/30/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "AKOrchestra.h"
#import "AKInstrument.h"
#import "AKManager.h"
#import "AKStereoAudio.h"

@implementation AKOrchestra
{
    int sampleRate;
    int samplesPerControlPeriod;
    NSMutableSet *udoFiles;
}

// -----------------------------------------------------------------------------
#  pragma mark - Initialization
// -----------------------------------------------------------------------------

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"AudioKit" ofType:@"plist"];
        NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:path];
        
        // Default Values (for tests that don't load the AudioKit.plist)
        sampleRate = 44100;
        samplesPerControlPeriod = 64;
        _numberOfChannels = 2;
        _zeroDBFullScaleValue = 1.0f;

        if (dict) {
            sampleRate = [[dict objectForKey:@"Sample Rate"] intValue];
            samplesPerControlPeriod = [[dict objectForKey:@"Samples Per Control Period"] intValue];
            _numberOfChannels = [[dict objectForKey:@"Number Of Channels"] intValue];
            _zeroDBFullScaleValue = [[dict objectForKey:@"Number Of Channels"] floatValue];
        }
        
        udoFiles = [[NSMutableSet alloc] init];
    }
    return self;
}

// -----------------------------------------------------------------------------
#  pragma mark - Starting and Testing
// -----------------------------------------------------------------------------


+ (void)start
{
    if (![[AKManager sharedManager] isRunning]) {
        [[AKManager sharedManager] runOrchestra];
    }
}

+ (void)reset
{
    [[AKManager sharedManager] resetOrchestra];
}


+ (void)testForDuration:(float)duration
{
    [[AKManager sharedManager] setIsLogging:YES];
    if (![[AKManager sharedManager] isRunning]) {
        [[AKManager sharedManager] runOrchestraForDuration:duration];
    }
}


// -----------------------------------------------------------------------------
#  pragma mark - Csound Implementation
// -----------------------------------------------------------------------------

+ (void)addInstrument:(AKInstrument *)instrument
{
    [[[AKManager sharedManager] orchestra] addInstrument:instrument];
}

- (void)addInstrument:(AKInstrument *)instrument
{
    NSMutableString *instrumentString = [NSMutableString string];
    
    [instrumentString appendString:[NSString stringWithFormat:@"\n\n;=== %@ ===\n\n", [instrument uniqueName] ]];

    [instrumentString appendString:@";--- Global Parameters ---\n"];
    
    if ([[AKManager sharedManager] numberOfSineWaveReferences] > 0) {
        [instrumentString appendString:[[AKManager standardSineWave] stringForCSD]];
    }
    
    for (AKFunctionTable *functionTable in instrument.functionTables) {
        [instrumentString appendString:[functionTable stringForCSD]];
        [instrumentString appendString:@"\n"];
    }
    for (AKParameter *globalParameter in instrument.globalParameters) {
        [instrumentString appendString:@"\n"];
        if ([globalParameter class] == [AKStereoAudio class]) {
            [instrumentString appendString:[NSString stringWithFormat:@"%@ init 0, 0\n", globalParameter]];
        } else {
            [instrumentString appendString:[NSString stringWithFormat:@"%@ init 0\n", globalParameter]];
        }
        [instrumentString appendString:@"\n"];
    }
    [instrumentString appendString:@"\n"];
    
    [instrumentString appendFormat:@"instr %i\n", [instrument instrumentNumber]];
    [instrumentString appendString:[NSString stringWithFormat:@"%@\n",[instrument stringForCSD]]];
    [instrumentString appendString:@"endin\n"];
    NSLog(@"%@", instrumentString);
    
    [[[AKManager sharedManager] engine] updateOrchestra:instrumentString];
    
    // Update Bindings
    for (AKInstrumentProperty *instrumentProperty in [instrument properties]) {
        //[instrumentProperty setup:[[AKManager sharedManager] engine]];
        [[[AKManager sharedManager] engine] addBinding:(AKInstrumentProperty<CsoundBinding> *)instrumentProperty];
    }

}

- (NSString *) stringForCSD
{
    NSMutableString *initialFile = [NSMutableString stringWithString:@""];
    
    [initialFile appendString:@";=== HEADER ===\n"];
    [initialFile appendString:[NSString stringWithFormat:
                               @"nchnls = %d \n"
                               @"sr     = %d \n"
                               @"0dbfs  = %g \n"
                               @"ksmps  = %d \n",
                               _numberOfChannels,
                               sampleRate,
                               _zeroDBFullScaleValue,
                               samplesPerControlPeriod]];
    [initialFile appendString:@"\n"];
    return initialFile;
}


@end
