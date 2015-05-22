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
@end

@interface AKFMOscillatorNote : AKNote

// Note properties
@property AKNoteProperty *frequency;
@property AKNoteProperty *amplitude;

- (instancetype)initWithFrequency:(float)frequency amplitude:(float)amplitude;

@end
