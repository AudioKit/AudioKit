//
//  SimpleFMOscillator.h
//  OCSiPad
//
//  Created by Aurelius Prochazka on 9/2/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSInstrument.h"

@interface SimpleFMOscillator : OCSInstrument

@property (nonatomic, strong) OCSEventProperty *frequency;
#define kFrequencyMin 110
#define kFrequencyMax 880

@property (nonatomic, strong) OCSInstrumentProperty *modulation;
#define kModulationMin 0.5
#define kModulationMax 2.0

@end
