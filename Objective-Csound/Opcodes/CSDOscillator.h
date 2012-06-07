//
//  Oscillator.h
//  CsdReinvention
//
//  Created by Aurelius Prochazka on 4/13/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "CSDOpcode.h"
#import "CSDFunctionStatement.h"
#import "CSDParam.h"

@interface CSDOscillator : CSDOpcode 

@property (nonatomic, strong) NSString *output;
@property (nonatomic, strong) NSString *opcode;
@property (nonatomic, strong) CSDParam *xAmplitude;
@property (nonatomic, strong) CSDParam *kPitch;
@property (nonatomic, strong) CSDFunctionStatement *functionTable;

-(NSString *) convertToCsd;

-(id) initWithOutput:(NSString *) out
           Amplitude:(CSDParam *) amp 
              kPitch:(CSDParam *) freq
       FunctionTable:(CSDFunctionStatement *) f;

@end
