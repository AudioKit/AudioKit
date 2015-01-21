//
//  AKAudioAnalyzer.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 11/14/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "AKInstrument.h"

@interface AKAudioAnalyzer : AKInstrument

@property (nonatomic, strong) AKInstrumentProperty *trackedFrequency;

@property (nonatomic, strong) AKInstrumentProperty *trackedAmplitude;

- (instancetype)initWithAudioSource:(AKAudio *)audioSource;

@end
