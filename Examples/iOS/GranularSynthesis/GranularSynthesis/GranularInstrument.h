//
//  GranularInstrument.h
//  GranularSynthTest
//
//  Created by Nicholas Arner on 9/2/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

#import "AKInstrument.h"

@interface GranularInstrument : AKInstrument

@property (nonatomic, strong) AKInstrumentProperty *mix;
@property (nonatomic, strong) AKInstrumentProperty *frequency;
@property (nonatomic, strong) AKInstrumentProperty *duration;
@property (nonatomic, strong) AKInstrumentProperty *density;
@property (nonatomic, strong) AKInstrumentProperty *frequencyVariation;
@property (nonatomic, strong) AKInstrumentProperty *frequencyVariationDistribution;

@end

