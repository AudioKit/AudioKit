//
//  Harmonizer.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 7/22/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKFoundation.h"

@interface Harmonizer : AKInstrument

@property (nonatomic, strong) AKInstrumentProperty *pitch;
#define kPitchInit 1.25
#define kPitchMin  0.75
#define kPitchMax  1.75


@property (nonatomic, strong) AKInstrumentProperty *gain;
#define kGainInit 1.5
#define kGainMin  0.5
#define kGainMax  3.0

@end
