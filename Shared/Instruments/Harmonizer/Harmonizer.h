//
//  Harmonizer.h
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 7/22/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSFoundation.h"

@interface Harmonizer : OCSInstrument

@property (nonatomic, strong) OCSInstrumentProperty *pitch;
#define kPitchInit 1.25
#define kPitchMin  0.75
#define kPitchMax  1.75


@property (nonatomic, strong) OCSInstrumentProperty *gain;
#define kGainInit 1.5
#define kGainMin  0.5
#define kGainMax  3.0

@end
