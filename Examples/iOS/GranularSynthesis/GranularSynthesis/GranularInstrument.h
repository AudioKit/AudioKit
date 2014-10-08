//
//  GranularInstrument.h
//  GranularSynthTest
//
//  Created by Nicholas Arner on 9/2/14.
//  Copyright (c) 2014 Nicholas Arner. All rights reserved.
//

#import "AKInstrument.h"

@interface GranularInstrument : AKInstrument

@property (nonatomic, strong) AKInstrumentProperty *averageGrainDuration;
@property (nonatomic, strong) AKInstrumentProperty *grainDensity;
@property (nonatomic, strong) AKInstrumentProperty *granularFrequencyDeviation;
@property (nonatomic, strong) AKInstrumentProperty *granularAmplitude;

@end

