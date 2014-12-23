//
//  TweakableInstrument.h
//  AudioKit Example
//
//  Created by Aurelius Prochazka on 6/30/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

#import "AKFoundation.h"

@interface TweakableInstrument : AKInstrument

@property (nonatomic, strong) AKInstrumentProperty *amplitude;
@property (nonatomic, strong) AKInstrumentProperty *frequency;
@property (nonatomic, strong) AKInstrumentProperty *modulation;
@property (nonatomic, strong) AKInstrumentProperty *modIndex;

@end
