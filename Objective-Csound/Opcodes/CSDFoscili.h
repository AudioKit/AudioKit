//
//  CSDFoscili.h
//
//  Created by Adam Boulanger on 5/29/12.
//  Copyright (c) 2012 MIT Media Lab. All rights reserved.
//

#import "CSDOpcode.h"

@interface CSDFoscili : CSDOpcode {
    CSDParam * output;
}

//ares foscili xamp, kcps, xcar, xmod, kndx, ifn [, iphs]
@property (nonatomic, strong) CSDParam * output;
@property (nonatomic, strong) CSDParam * amplitude;
@property (nonatomic, strong) CSDParamControl * frequency;
@property (nonatomic, strong) CSDParam * carrier;
@property (nonatomic, strong) CSDParam * modulation;
@property (nonatomic, strong) CSDParamControl * modIndex;
@property (nonatomic, strong) CSDFunctionTable * functionTable;
@property (nonatomic, strong) CSDParamConstant * phase;

-(id)initFMOscillatorWithAmplitude:(CSDParam *) amp
                         Frequency:(CSDParamControl *) cps
                           Carrier:(CSDParam *) car
                        Modulation:(CSDParam *) mod
                          ModIndex:(CSDParamControl *) aModIndex
                     FunctionTable:(CSDFunctionTable *) f
                  AndOptionalPhase:(CSDParamConstant *) phs;

@end
