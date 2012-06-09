//
//  CSDFoscili.h
//  Missilez
//
//  Created by Adam Boulanger on 5/29/12.
//  Copyright (c) 2012 MIT Media Lab. All rights reserved.
//

#import "CSDOpcode.h"
#import "CSDParamControl.h"
#import "CSDFunctionTable.h"

@interface CSDFoscili : CSDOpcode
//ares foscili xamp, kcps, xcar, xmod, kndx, ifn [, iphs]
@property (nonatomic, strong) CSDParam *xAmplitude;
@property (nonatomic, strong) CSDParam *kPitch;
@property (nonatomic, strong) CSDParam *xCarrier;
@property (nonatomic, strong) CSDParam *xModulation;
@property (nonatomic, strong) CSDParam *kModIndex;
@property (nonatomic, strong) CSDFunctionTable *functionTable;
@property (nonatomic, strong) CSDParam *iPhase;

//-(NSString *) textWithPValue:(int)p;

-(id)initFMOscillatorWithAmplitude:(CSDParam *)amp
                            kPitch:(CSDParam *)cps
                          kCarrier:(CSDParam *)car
                       xModulation:(CSDParam *)mod
                         kModIndex:(CSDParam *)modIndex
                     FunctionTable:(CSDFunctionTable *)f
                  AndOptionalPhase:(CSDParam *)phs;

-(NSString *)convertToCsd;

@end
