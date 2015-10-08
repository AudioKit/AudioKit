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
#import "AKSettings.h"
#import "AKStereoAudio.h"

@implementation AKOrchestra
{
    UInt32 _sampleRate;
    UInt32 _samplesPerControlPeriod;
    NSMutableSet *_udoFiles;
    CsoundObj *_csound;
}

// -----------------------------------------------------------------------------
#  pragma mark - Initialization
// -----------------------------------------------------------------------------

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        _userDefinedOperations = [[NSMutableSet alloc] init];
        
        // Default Values (for tests that don't load the AudioKit.plist)
        _sampleRate = AKSettings.shared.sampleRate;
        _samplesPerControlPeriod = AKSettings.shared.samplesPerControlPeriod;
        _numberOfChannels = AKSettings.shared.numberOfChannels;
        _zeroDBFullScaleValue = AKSettings.shared.zeroDBFullScaleValue;
        
        _udoFiles = [[NSMutableSet alloc] init];
        _csound = [[AKManager sharedManager] engine];
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


+ (void)testForDuration:(NSTimeInterval)duration
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
#ifdef AK_TESTING
            [instrumentString appendFormat:@"%@\n", udo];
#else
            if (![[[[AKManager sharedManager] orchestra] userDefinedOperations] containsObject:udo]) {
                [instrumentString appendFormat:@"%@\n", udo];
                [[[[AKManager sharedManager] orchestra] userDefinedOperations] addObject:udo];
            }
#endif
        }
    }
    
    if (instrument.maximumNoteAllocation) {
        [instrumentString appendFormat:@"maxalloc %@, %@\n", @(instrument.instrumentNumber), @(instrument.maximumNoteAllocation)];
    }
    
    [instrumentString appendFormat:@"instr %@\n", @(instrument.instrumentNumber)];
    [instrumentString appendString:[NSString stringWithFormat:@"%@\n", stringForCSD]];
    [instrumentString appendString:@"endin\n"];
    
    if ([[AKManager sharedManager] isLogging]) {
        NSLog(@"%@", instrumentString);
    }
    
    [_csound updateOrchestra:instrumentString];
    
    // Update Bindings
    for (AKInstrumentProperty *instrumentProperty in [instrument properties]) {
        [_csound addBinding:(AKInstrumentProperty<CsoundBinding> *)instrumentProperty];
    }
}

- (NSString *) stringForCSD
{
    return [NSString stringWithFormat:
            @"nchnls = %@ \n"
            @"sr     = %@ \n"
            @"0dbfs  = %g \n"
            @"ksmps  = %@ \n",
            @(_numberOfChannels),
            @(_sampleRate),
            _zeroDBFullScaleValue,
            @(_samplesPerControlPeriod)];
}

@end
