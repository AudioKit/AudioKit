//
//  OCSOrchestra.m
//  Objective-Csound
//
//  Created by Aurelius Prochazka on 5/30/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSOrchestra.h"
#import "OCSInstrument.h"
#import "OCSManager.h"

@interface OCSOrchestra () {
    NSMutableArray *instruments;
    NSMutableArray *udos;
    NSMutableArray *fTables;
}
@end

@implementation OCSOrchestra

@synthesize fTables;
@synthesize instruments;

- (id)init {
    self = [super init];
    if (self) {
        instruments = [[NSMutableArray alloc] init];
        udos = [[NSMutableArray alloc] init];
    }
    return self; 
}

- (void)addInstrument:(OCSInstrument *)newInstrument {
    [instruments addObject:newInstrument];
    [newInstrument joinOrchestra:self];
}

- (void)addUDO:(OCSUserDefinedOpcode *)newUserDefinedOpcode {
    [udos addObject:newUserDefinedOpcode];
}


- (NSString *) stringForCSD {

    NSMutableString *s = [NSMutableString stringWithString:@""];

    for ( OCSInstrument *i in instruments) {

        for (OCSUserDefinedOpcode *udo in [i userDefinedOpcodes]) {
            [s appendString:@"\n\n"];     
            [s appendString:[OCSManager stringFromFile:[udo udoFile]]];
            [s appendString:@"\n\n"];
        }

        
        [s appendFormat:@"instr %@\n", [i uniqueName]];
        [s appendString:[NSString stringWithFormat:@"%@\n",[i stringForCSD]]];
        [s appendString:@"endin\n\n"];
    }
    
    return s;
}

- (NSString *)fTableStringForCSD {
    NSMutableString *s = [NSMutableString stringWithString:@""];
    
    for ( OCSInstrument *i in instruments) {
        
        for (OCSFTable *fTable in [i fTables]) {
            [s appendString:[fTable fTableStringForCSD]];
            [s appendString:@"\n"];
        }
        
    }
    
    return s;
}

@end
