//
//  CSDFoscili.h
//  Missilez
//
//  Created by Adam Boulanger on 5/29/12.
//  Copyright (c) 2012 MIT Media Lab. All rights reserved.
//

#import "CSDOpcode.h"
#import "CSDFunctionStatement.h"
#import "CSDSynthesizer.h"

@interface CSDFoscili : CSDOpcode
//ares foscili xamp, kcps, xcar, xmod, kndx, ifn [, iphs]
@property (nonatomic, strong) NSString *output;
@property (nonatomic, strong) NSString *opcode;
@property (nonatomic, strong) NSString *amplitude;
@property (nonatomic, strong) NSString *pitch;
@property (nonatomic, strong) NSString *carrier;
@property (nonatomic, strong) NSString *modulation;
@property (nonatomic, strong) NSString *modIndex;
@property (nonatomic, strong) CSDFunctionStatement *functionTable;
@property (nonatomic, strong) NSString *phase;

-(NSString *) textWithPValue:(int)p;

-(id) initWithOutput:(NSString *) out
Amplitude:(NSString *) amp 
Pitch:(NSString *) cps
Carrier:(NSString *)car
Modulation:(NSString *)mod
ModIndex:(NSString *)modIndx
FunctionTable:(CSDFunctionStatement *) f
AndOptionalPhase:(NSString *) phs;
@end
