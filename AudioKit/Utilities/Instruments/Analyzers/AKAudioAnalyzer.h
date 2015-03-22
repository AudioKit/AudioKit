//
//  AKAudioAnalyzer.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 11/14/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "AKInstrument.h"

@interface AKAudioAnalyzer : AKInstrument

@property AKInstrumentProperty *trackedFrequency;
@property AKInstrumentProperty *trackedAmplitude;

- (instancetype)initWithAudioSource:(AKParameter *)audioSource;

@end
