//
//  CSDOpcode.m
//  CsdReinvention
//
//  Created by Aurelius Prochazka on 4/11/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "CSDOpcode.h"

@implementation CSDOpcode

@synthesize output;

-(NSString *) textWithPValue:(int) p {
    return @"";
}

//-(id) initWithOscillatorType:(NSString *) opcode
//                      AtRate:(NSString *) rate 
//                OutputtingTo:(NSString *) output
//               WithAmplitude:(float) amp
//                AndFrequency:(float) freq 
//            WithFuncionTable:(int)ifn 
//           AndOptionalPhases:(NSArray *) iphs {
//    self = [super init];
//    if (self) {
//        textRepresentation = [NSString stringWithFormat:
//                 @"%@%@ %@ %0.2f, %0.2f, %i\n",
//                 rate, output, opcode, amp, freq, ifn];
//    }
//    return self; 
//    
//}


@end
