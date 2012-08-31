//
//  FMOscillator.h
//  Objective-C Sound Example
//
//  Created by Adam Boulanger on 6/4/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSInstrument.h"

@interface FMOscillator : OCSInstrument 

@property (nonatomic, strong) OCSEventProperty *frequency;
#define kFrequencyMin 110
#define kFrequencyMax 880

@property (nonatomic, strong) OCSInstrumentProperty *modulation;
#define kModulationMin 0.5
#define kModulationMax 2.0

@end
