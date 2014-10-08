//
//  AKOrchestra.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 5/30/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKOrchestra.h"
#import "AKInstrument.h"
#import "AKManager.h"

@implementation AKOrchestra
{
    int sampleRate;
    int samplesPerControlPeriod;
    NSMutableSet *udoFiles;
}

// -----------------------------------------------------------------------------
#  pragma mark - Initialization
// -----------------------------------------------------------------------------

- (instancetype)init {
    self = [super init];
    if (self) {
        sampleRate = 44100;
        samplesPerControlPeriod = 64;
        _numberOfChannels = 2;
        _zeroDBFullScaleValue = 1.0f;
        udoFiles = [[NSMutableSet alloc] init];
        _instruments = [[NSMutableArray alloc] init];
    }
    return self; 
}

// -----------------------------------------------------------------------------
#  pragma mark - Collections
// -----------------------------------------------------------------------------

- (void)addInstrument:(AKInstrument *)newInstrument {
    [_instruments addObject:newInstrument];
    [newInstrument joinOrchestra:self];
}

// -----------------------------------------------------------------------------
#  pragma mark - Csound Implementation
// -----------------------------------------------------------------------------

- (NSString *) stringForCSD {
 
    NSMutableString *s = [NSMutableString stringWithString:@""];
    
    [s appendString:@";=== HEADER ===\n"];
    [s appendString:[NSString stringWithFormat:
                     @"nchnls = %d \n"
                     @"sr     = %d \n"
                     @"0dbfs  = %g \n"
                     @"ksmps  = %d \n",
                     _numberOfChannels,
                     sampleRate, 
                     _zeroDBFullScaleValue,
                     samplesPerControlPeriod]];
    [s appendString:@"\n"];
    
    [s appendString:@";=== GLOBAL F-TABLES ===\n"];
    for ( AKInstrument *i in _instruments) {
        for (AKFTable *fTable in [i fTables]) {
            [s appendString:[fTable fTableStringForCSD]];
            [s appendString:@"\n"];
        } 
    }
    [s appendString:@"\n"];
    
    [s appendString:@";=== USER-DEFINED OPCODES ===\n"];
    for ( AKInstrument *i in _instruments) {
        for (AKParameter *udo in [i userDefinedOperations]) {
            NSString *newUDOFile = [udo udoFile];
            for (AKParameter *udo in udoFiles) {
                if ([newUDOFile isEqualToString:[udo udoFile]]) {
                    newUDOFile  = @"";
                }
            }
            if (![newUDOFile isEqualToString:@""]) {
                [udoFiles addObject:udo];
            }
        }
    }
    for (AKParameter *udo in udoFiles) {
        [s appendString:@"\n"];
        [s appendString:[AKManager stringFromFile:[udo udoFile]]];
        [s appendString:@"\n"];

    }
    [s appendString:@"\n"];

    [s appendString:@";=== INSTRUMENTS ===\n"];
    for ( AKInstrument *i in _instruments) {
        [s appendString:[NSString stringWithFormat:@"\n;--- %@ ---\n\n", [i uniqueName] ]];
        [s appendFormat:@"instr %i\n", [i instrumentNumber]];
        [s appendString:[NSString stringWithFormat:@"%@\n",[i stringForCSD]]];
        [s appendString:@"endin\n"];
    }
    [s appendString:@"\n"];
    
    return s;
}


@end
