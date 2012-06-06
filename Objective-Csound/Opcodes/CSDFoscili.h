//
//  CSDFoscili.h
//  Missilez
//
//  Created by Adam Boulanger on 5/29/12.
//  Copyright (c) 2012 MIT Media Lab. All rights reserved.
//

#import "CSDOpcode.h"
#import "CSDParam.h"
#import "CSDFunctionStatement.h"
#import "CSDSynthesizer.h"

@interface CSDFoscili : CSDOpcode
//ares foscili xamp, kcps, xcar, xmod, kndx, ifn [, iphs]
@property (nonatomic, strong) NSString *output;
@property (nonatomic, strong) NSString *opcode;
@property (nonatomic, strong) CSDParam *xAmplitude;
@property (nonatomic, strong) CSDParam *kPitch;
@property (nonatomic, strong) CSDParam *xCarrier;
@property (nonatomic, strong) CSDParam *xModulation;
@property (nonatomic, strong) CSDParam *kModIndex;
@property (nonatomic, strong) CSDFunctionStatement *functionTable;
@property (nonatomic, strong) CSDParam *iPhase;

//-(NSString *) textWithPValue:(int)p;

//H4Y - ARB: deprecated
/*
-(id) initWithOutput:(NSString *) out
Amplitude:(NSString *) amp 
Pitch:(NSString *) cps
Carrier:(NSString *)car
Modulation:(NSString *)mod
ModIndex:(NSString *)modIndx
FunctionTable:(CSDFunctionStatement *) f
AndOptionalPhase:(NSString *) phs;
 */

-(id)initFMOscillatorWithAmplitude:(CSDParam *)amp
kPitch:(CSDParam *)cps
kCarrier:(CSDParam *)car
xModulation:(CSDParam *)mod
kModIndex:(CSDParam *)modIndex
FunctionTable:(CSDFunctionStatement *)f
AndOptionalPhase:(CSDParam *)phs;

-(NSString *)convertToCsd;

@end
