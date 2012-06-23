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
    }
    return self; 
}

- (void)addInstrument:(OCSInstrument *) instrument {
    [instruments addObject:instrument];
    [instrument joinOrchestra:self];
}

- (NSString *)instrumentsForCsd {
    
    NSMutableString *instrumentsText = [NSMutableString stringWithString:@""];
    
    for ( OCSInstrument* instrument in instruments) {
        [instrumentsText appendFormat:@"instr %@\n", [instrument uniqueName]];
        [instrumentsText appendString:[NSString stringWithFormat:@"%@",[instrument csdRepresentation]]];
        [instrumentsText appendString:@"endin\n\n"];
    }
    
    return instrumentsText;
}

@end
