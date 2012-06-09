//
//  Oscillator.h
//  CsdReinvention
//
//  Created by Aurelius Prochazka on 4/13/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "CSDManager.h"

@interface CSDOscillator : CSDOpcode 

@property (nonatomic, strong) CSDParam * amplitude;
@property (nonatomic, strong) CSDParam * pitch;
@property (nonatomic, strong) CSDFunctionTable *functionTable;

-(NSString *) convertToCsd;

-(id) initWithAmplitude:(CSDParam *) amp 
                  Pitch:(CSDParam *) freq
          FunctionTable:(CSDFunctionTable *) f;

@end
