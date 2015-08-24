//
//  Mandolin.h
//  AudioKit
//
//  Created by Nicholas Arner on 3/20/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKFoundation.h"

/// An instrument that wraps the mandolin physical model
@interface AKMandolinInstrument : AKInstrument

// Instrument Properties
@property AKInstrumentProperty *amplitude;
@property AKInstrumentProperty *bodySize;
@property AKInstrumentProperty *pairedStringDetuning;


// Audio outlet for global effects processing
@property (readonly) AKAudio *output;

@end

@interface AKMandolinNote : AKNote

// Note properties
@property AKNoteProperty *frequency;
@property AKNoteProperty *pluckPosition;
@property AKNoteProperty *amplitude;

@end
