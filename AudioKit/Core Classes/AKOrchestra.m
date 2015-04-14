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
    CsoundObj *csound;
}

// -----------------------------------------------------------------------------
#  pragma mark - Initialization
// -----------------------------------------------------------------------------

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        _userDefinedOperations = [[NSMutableSet alloc] init];
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"AudioKit" ofType:@"plist"];
        NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:path];
        
        // Default Values (for tests that don't load the AudioKit.plist)
        sampleRate = 44100;
        samplesPerControlPeriod = 64;
        _numberOfChannels = 2;
        _zeroDBFullScaleValue = 1.0f;
        
        if (dict) {
            sampleRate = [dict[@"Sample Rate"] intValue];
            samplesPerControlPeriod = [dict[@"Samples Per Control Period"] intValue];
            _numberOfChannels = [dict[@"Number Of Channels"] intValue];
            _zeroDBFullScaleValue = [dict[@"Zero dB Full Scale Value"] floatValue];
        }
        
        udoFiles = [[NSMutableSet alloc] init];
        csound = [[AKManager sharedManager] engine];
    }
    return self;
}

// -----------------------------------------------------------------------------
#  pragma mark - Starting and Testing
// -----------------------------------------------------------------------------

+ (void)start
{
    if (![[AKManager sharedManager] isRunning]) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"AudioKit" ofType:@"plist"];
        NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:path];
        
        // Default Value
        BOOL enableAudioInput = YES;
        
        if (dict) {
            enableAudioInput = [dict[@"Enable Audio Input By Default"] boolValue];
        }
        
        if (enableAudioInput) {
            [[AKManager sharedManager] enableAudioInput];
        }else{
            [[AKManager sharedManager] disableAudioInput];
        }
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
    [AKOrchestra start];
    while (![[AKManager sharedManager] isRunning]) {
        // do nothing
    }
    [[[AKManager sharedManager] orchestra] addInstrument:instrument];
}

+ (void)updateInstrument:(AKInstrument *)instrument
{
    [self addInstrument:instrument];
}

- (void)addInstrument:(AKInstrument *)instrument
{
    NSMutableString *instrumentString = [NSMutableString string];
    
    [instrumentString appendString:[NSString stringWithFormat:@"\n\n;=== %@ ===\n\n", [instrument uniqueName] ]];
    
    [instrumentString appendString:@";--- Global Parameters ---\n"];
    
    for (AKParameter *globalParameter in instrument.globalParameters) {
        [instrumentString appendString:@"\n"];
        if ([globalParameter class] == [AKStereoAudio class]) {
            [instrumentString appendString:[NSString stringWithFormat:@"%@ init 0, 0\n", globalParameter]];
        } else {
            [instrumentString appendString:[NSString stringWithFormat:@"%@ init 0\n", globalParameter]];
        }
        [instrumentString appendString:@"\n"];
    }
    
    NSString *stringForCSD = [instrument stringForCSD];
    if (instrument.userDefinedOperations.count > 0) {
        [instrumentString appendString:@"\n;--- User-defined operations ---\n"];
        for (NSString *udo in instrument.userDefinedOperations) {
            if (![[[[AKManager sharedManager] orchestra] userDefinedOperations] containsObject:udo]) {
                [instrumentString appendFormat:@"%@\n", udo];
                [[[[AKManager sharedManager] orchestra] userDefinedOperations] addObject:udo];
            }
        }
    }
    
    [instrumentString appendFormat:@"instr %i\n", [instrument instrumentNumber]];
    [instrumentString appendString:[NSString stringWithFormat:@"%@\n", stringForCSD]];
    [instrumentString appendString:@"endin\n"];
    
    if ([[AKManager sharedManager] isLogging]) {
        NSLog(@"%@", instrumentString);
    }
    
    [csound updateOrchestra:instrumentString];
    
    // Update Bindings
    for (AKInstrumentProperty *instrumentProperty in [instrument properties]) {
        [csound addBinding:(AKInstrumentProperty<CsoundBinding> *)instrumentProperty];
    }
}

- (NSString *) stringForCSD
{
    return [NSString stringWithFormat:
            @"nchnls = %d \n"
            @"sr     = %d \n"
            @"0dbfs  = %g \n"
            @"ksmps  = %d \n",
            _numberOfChannels,
            sampleRate,
            _zeroDBFullScaleValue,
            samplesPerControlPeriod];
}

@end
