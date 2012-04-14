//
//  CSDOpcode.h
//  CsdReinvention
//
//  Created by Aurelius Prochazka on 4/11/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSDOpcode : NSObject {
//    NSString * textRepresentation;
}
@property (nonatomic, strong) NSString * output;

-(NSString *) textWithPValue:(int)p;

//-(id) initWithOscillatorType:(NSString *) opcode
//                      AtRate:(NSString *) rate 
//                OutputtingTo:(NSString *) output
//               WithAmplitude:(float) amp
//                AndFrequency:(float) freq 
//            WithFuncionTable:(int)ifn 
//           AndOptionalPhases:(NSArray *) iphs;
@end
