//
//  ToneGenerator.h
//  Objective-C Sound Example
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSFoundation.h"

@interface ToneGenerator : OCSInstrument 

@property (nonatomic, strong) OCSInstrumentProperty *frequency;
#define kFrequencyMin 110
#define kFrequencyMax 880

@property (readonly) OCSAudio *auxilliaryOutput;

@end
