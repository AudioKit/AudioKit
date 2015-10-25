//
//  AKFMOscillatorInstrument.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 3/20/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKFoundation.h"

/// A synth that uses FM Synthesis to generate sounds, with frequency and amplitude defined
@interface AKFMOscillatorInstrument : AKInstrument

// Instrument Properties
@property AKInstrumentProperty *amplitude;
// Audio outlet for global effects processing
@property (readonly) AKAudio *output;

@end

@interface AKFMOscillatorNote : AKNote

// Note properties
@property AKNoteProperty *frequency;
@property AKNoteProperty *carrierMultiplier;
@property AKNoteProperty *modulatingMultiplier;
@property AKNoteProperty *modulationIndex;
@property AKNoteProperty *amplitude;

- (instancetype)initWithFrequency:(float)frequency
                carrierMultiplier:(float)carrierMultiplier
             modulatingMultiplier:(float)modulatingMultiplier
                  modulationIndex:(float)modulationIndex
                        amplitude:(float)amplitude;

@end
