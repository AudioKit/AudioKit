//
//  AKAudioAnalyzer.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 11/14/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "AKFoundation.h"

/// An instrument that has two properties that detect the amplitude and frequency of an audio source signal.
@interface AKAudioAnalyzer : AKInstrument

@property AKInstrumentProperty *trackedFrequency;
@property AKInstrumentProperty *trackedAmplitude;

// Audio outlet for global effects processing
@property (readonly) AKAudio *output;

- (instancetype)initWithInput:(AKParameter *)audioSource;

@end
