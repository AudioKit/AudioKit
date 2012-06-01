//
//  Oscillator.h
//  CsdReinvention
//
//  Created by Aurelius Prochazka on 4/13/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "CSDOpcode.h"
#import "CSDFunctionStatement.h"
#import "CSDSynthesizer.h"

@interface CSDOscillator : CSDOpcode 

@property (nonatomic, strong) NSString * output;
@property (nonatomic, strong) NSString * opcode;
@property (nonatomic, strong) NSString * amplitude;
@property (nonatomic, strong) NSString * frequency;
@property (nonatomic, strong) CSDFunctionStatement * functionTable;
@property (nonatomic, strong) NSString * phase;

-(NSString *) textWithPValue:(int)p;

-(id) initWithOutput:(NSString *) out
           Amplitude:(NSString *) amp 
           Frequency:(NSString *) freq
       FunctionTable:(CSDFunctionStatement *) f
   AndOptionalPhases:(NSString *) phs;

@end
