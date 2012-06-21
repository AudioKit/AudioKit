//
//  CSDOrchestra.m
//
//  Created by Aurelius Prochazka on 5/30/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "CSDOrchestra.h"
#import "CSDInstrument.h"
@implementation CSDOrchestra

@synthesize instruments;

-(id) init {
    self = [super init];
    if (self) {
        instruments = [[NSMutableArray alloc] init];
    }
    return self; 
}

-(void) addInstrument:(CSDInstrument *) instrument {
    [instruments addObject:instrument];
}
-(NSString *) instrumentsForCsd {
    
    NSMutableString * instrumentsText = [NSMutableString stringWithString:@""];
    
    for ( CSDInstrument* instrument in instruments) {
        [instrumentsText appendFormat:@"instr %@\n", [instrument uniqueName]];
        [instrumentsText appendString:[NSString stringWithFormat:@"%@",[instrument csdRepresentation]]];
        [instrumentsText appendString:@"endin\n\n"];
    }
    
    return instrumentsText;
}

@end
