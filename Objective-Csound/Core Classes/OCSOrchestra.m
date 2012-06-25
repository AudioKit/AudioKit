//
//  OCSOrchestra.m
//
//  Created by Aurelius Prochazka on 5/30/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSOrchestra.h"
#import "OCSInstrument.h"

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

- (void)addInstrument:(OCSInstrument *) instrument {
    [instruments addObject:instrument];
    [instrument joinOrchestra:self];
}

- (void)addUDO:(OCSUserDefinedOpcode *) udo {
    [myUDOs addObject:udo];
}


- (NSString *) stringForCSD {

    NSMutableString *s = [NSMutableString stringWithString:@""];

    
    for ( OCSInstrument *i in instruments) {
        
        [s appendString:@";UDOs\n"];
        for (OCSUserDefinedOpcode *u in [i myUDOs]) {
            //[s appendFormat:@"#include \"%@\"", [u myUDOFile]];  //Would be nice but it crashes Csound
            [s appendString:@"\n\n\n"];     
            [s appendString:[[NSString alloc] initWithContentsOfFile:[u udoFile]  
                                                            encoding:NSUTF8StringEncoding 
                                                               error:nil]];
            [s appendString:@"\n\n\n"];
        }
        [s appendString:@"\n;Done\n"];

        
        [s appendFormat:@"instr %@\n", [i uniqueName]];
        [s appendString:[NSString stringWithFormat:@"%@",[i csdRepresentation]]];
        [s appendString:@"endin\n\n"];
    }
    
    return s;
}

@end
