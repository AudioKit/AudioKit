//
//  OCSOrchestra.m
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 5/30/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSOrchestra.h"
#import "OCSInstrument.h"
#import "OCSManager.h"

@interface OCSOrchestra () {
    int sampleRate;
    int samplesPerControlPeriod;
    NSMutableArray *udos;
}
@end

@implementation OCSOrchestra

// -----------------------------------------------------------------------------
#  pragma mark - Initialization
// -----------------------------------------------------------------------------

- (id)init {
    self = [super init];
    if (self) {
        sampleRate = 44100;
        samplesPerControlPeriod = 64;
        _numberOfChannels = 2;
        _zeroDBFullScaleValue = 1.0f;
        udos = [[NSMutableArray alloc] init];
        _instruments = [[NSMutableArray alloc] init];
    }
    return self; 
}

// -----------------------------------------------------------------------------
#  pragma mark - Collections
// -----------------------------------------------------------------------------

- (void)addInstrument:(OCSInstrument *)newInstrument {
    [_instruments addObject:newInstrument];
    [newInstrument joinOrchestra:self];
}

//- (void)addUDO:(OCSUserDefinedOperation *)newUserDefinedOperation {
//    [udos addObject:newUserDefinedOperation];
//}

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
    for ( OCSInstrument *i in _instruments) {
        for (OCSFTable *fTable in [i fTables]) {
            [s appendString:[fTable fTableStringForCSD]];
            [s appendString:@"\n"];
        } 
    }
    [s appendString:@"\n"];
    
    [s appendString:@";=== USER-DEFINED OPCODES ===\n"];
    for ( OCSInstrument *i in _instruments) {
        for (OCSParameter *udo in [i userDefinedOperations]) {
            [s appendString:@"\n"];     
            [s appendString:[OCSManager stringFromFile:[udo udoFile]]];
            [s appendString:@"\n"];
        }
    }
    [s appendString:@"\n"];

    [s appendString:@";=== INSTRUMENTS ===\n"];
    for ( OCSInstrument *i in _instruments) {
        [s appendString:[NSString stringWithFormat:@"\n;--- %@ ---\n\n", [i uniqueName] ]];
        [s appendFormat:@"instr %i\n", [i instrumentNumber]];
        [s appendString:[NSString stringWithFormat:@"%@\n",[i stringForCSD]]];
        [s appendString:@"endin\n"];
    }
    [s appendString:@"\n"];
    
    return s;
}


@end
