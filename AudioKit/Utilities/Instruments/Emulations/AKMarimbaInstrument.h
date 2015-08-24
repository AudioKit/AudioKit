//
//  Marimba.h
//  AudioKit
//
//  Created by Nicholas Arner on 3/20/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKFoundation.h"

/// An instrument that wraps the marimba physical model
@interface AKMarimbaInstrument : AKInstrument

// Instrument Properties
@property AKInstrumentProperty *amplitude;
@property AKInstrumentProperty *vibratoAmplitude;
@property AKInstrumentProperty *vibratoFrequency;

@property (readonly) AKAudio *output;

@end

@interface AKMarimbaNote : AKNote

// Note properties
@property AKNoteProperty *frequency;
@property AKNoteProperty *stickHardness;
@property AKNoteProperty *strikePosition;
@property AKNoteProperty *amplitude;


@end
