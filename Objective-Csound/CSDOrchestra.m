//
//  CSDOrchestra.m
//
//  Created by Aurelius Prochazka on 5/30/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "CSDOrchestra.h"

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
    // Inserting instrument at the beginning to allow for instruments that feed into others to be done last
    [instruments insertObject:instrument atIndex:0];
}
-(NSString *) instrumentsForCsd {
    
    NSMutableString * instrumentsText = [NSMutableString stringWithString:@""];
    
    for ( CSDInstrument* instrument in instruments) {
        [instrumentsText appendFormat:@"instr %i\n", [instruments indexOfObject:instrument]+1];
        [instrumentsText appendString:[NSString stringWithFormat:@"%@",[instrument csdRepresentation]]];
        //Deprecating using output in this way to allow for stereo output, globals, etc.
        //[instrumentsText appendString:[NSString stringWithFormat:@"out %@", FINAL_OUTPUT]],
        [instrumentsText appendString:@"\nendin\n"];
    }
    
    return instrumentsText;
}
@end
