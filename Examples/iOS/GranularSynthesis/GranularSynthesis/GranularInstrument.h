//
//  GranularInstrument.h
//  GranularSynthTest
//
//  Created by Nicholas Arner on 9/2/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

#import "AKInstrument.h"

@interface GranularInstrument : AKInstrument

@property AKInstrumentProperty *mix;
@property AKInstrumentProperty *frequency;
@property AKInstrumentProperty *duration;
@property AKInstrumentProperty *density;
@property AKInstrumentProperty *frequencyVariation;
@property AKInstrumentProperty *frequencyVariationDistribution;

@end

