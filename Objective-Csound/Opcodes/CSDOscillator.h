//
//  CSDOscillator.h
//
//  Created by Aurelius Prochazka on 4/13/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "CSDOpcode.h"

@interface CSDOscillator : CSDOpcode {
    CSDParam * amplitude;
    CSDParam * frequency;
    CSDFunctionTable *functionTable;
    BOOL isControl;
    CSDParam * output;
}
@property (nonatomic, strong) CSDParam * output;


-(id) initWithAmplitude:(CSDParam *) amp 
              Frequency:(CSDParam *) freq
          FunctionTable:(CSDFunctionTable *) f
              isControl:(BOOL)control;

-(id) initWithAmplitude:(CSDParam *) amp 
              Frequency:(CSDParam *) freq
          FunctionTable:(CSDFunctionTable *) f;

@end
