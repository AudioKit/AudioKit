//
//  OCSOscillator.h
//
//  Created by Aurelius Prochazka on 4/13/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSOpcode.h"

@interface OCSOscillator : OCSOpcode {
    OCSParam *amplitude;
    OCSParam *frequency;
    OCSFunctionTable *functionTable;
    OCSParam *audio;
    OCSParamControl *control;
    OCSParam *output;
}
@property (nonatomic, strong) OCSParam *audio;
@property (nonatomic, strong) OCSParamControl *control;
@property (nonatomic, strong) OCSParam *output;

- (id)initWithAmplitude:(OCSParam *) amp 
              Frequency:(OCSParam *) freq
          FunctionTable:(OCSFunctionTable *) f;

@end
