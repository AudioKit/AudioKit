//
//  CSDFoscili.h
//
//  Created by Adam Boulanger on 5/29/12.
//  Copyright (c) 2012 MIT Media Lab. All rights reserved.
//

#import "CSDOpcode.h"

@interface CSDFoscili : CSDOpcode {
    CSDParam * amplitude;
    CSDParamControl * frequency;
    CSDParam * carrier;
    CSDParam * modulation;
    CSDParamControl * modIndex;
    CSDFunctionTable * functionTable;
    CSDParamConstant * phase;
    CSDParam * output;
}
@property (nonatomic, strong) CSDParam * output;

-(id)initWithAmplitude:(CSDParam *) amp
             Frequency:(CSDParamControl *) cps
               Carrier:(CSDParam *) car
            Modulation:(CSDParam *) mod
              ModIndex:(CSDParamControl *) aModIndex
         FunctionTable:(CSDFunctionTable *) f
      AndOptionalPhase:(CSDParamConstant *) phs;

@end
