//
//  UDOMSROscillator.h
//  ExampleProject
//
//  Created by Aurelius Prochazka on 6/24/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSUserDefinedOpcode.h"

typedef enum {
    kMSROscillatorTypeSine,
    kMSROscillatorTypeTriangle,
    kMSROscillatorTypeSaw,
    kMSROscillatorTypeSquare,
    kMSROscillatorTypeTubeDistortion,
    kMSROscillatorTypeHalfTriangle,
    kMSROscillatorTypeHalfSquare,
    kMSROscillatorTypeHalfSaw,
    kMSROscillatorTypeWhiteNoise
} OscillatorType;

@interface UDOMSROscillator : OCSUserDefinedOpcode {
    OCSParam *output;
    OCSParamConstant *amplitude;
    OCSParamConstant *frequency;
    OscillatorType type;
}

@property (nonatomic, strong) OCSParam *output;

- (id)initWithAmplitude:(OCSParamConstant *)amp 
              Frequency:(OCSParamConstant *)cps 
                   Type:(OscillatorType)t;

@end
