//
//  OCSOrchestra.m
//
//  Created by Aurelius Prochazka on 5/30/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSOrchestra.h"
#import "OCSInstrument.h"

@interface OCSOrchestra () {
    NSMutableArray *instruments;
    NSMutableArray *myUDOs;
}
@end

@implementation OCSOrchestra

@synthesize instruments;

- (id)init {
    self = [super init];
    if (self) {
        instruments = [[NSMutableArray alloc] init];
        myUDOs = [[NSMutableArray alloc] init];
    }
    return self; 
}

- (void)addInstrument:(OCSInstrument *)newInstrument {
    [instruments addObject:newInstrument];
    [newInstrument joinOrchestra:self];
}

- (void)addUDO:(OCSUserDefinedOpcode *)newUserDefinedOpcode {
    [myUDOs addObject:newUserDefinedOpcode];
}


- (NSString *) stringForCSD {

    NSMutableString *s = [NSMutableString stringWithString:@""];

    
    for ( OCSInstrument *i in instruments) {

        for (OCSUserDefinedOpcode *u in [i userDefinedOpcodes]) {
            //[s appendFormat:@"#include \"%@\"", [u myUDOFile]];  //Would be nice but it crashes Csound
            [s appendString:@"\n\n\n"];     
            [s appendString:[[NSString alloc] initWithContentsOfFile:[u udoFile]  
                                                            encoding:NSUTF8StringEncoding 
                                                               error:nil]];
            [s appendString:@"\n\n\n"];
        }

        
        [s appendFormat:@"instr %@\n", [i uniqueName]];
        [s appendString:[NSString stringWithFormat:@"%@\n",[i stringForCSD]]];
        [s appendString:@"endin\n\n"];
    }
    
    return s;
}

@end
