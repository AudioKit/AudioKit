//
//  PluckedString.h
//  AudioKit
//
//  Created by Nicholas Arner on 3/21/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKFoundation.h"

/// An instrument that wraps the plucked string physical model
@interface AKPluckedStringInstrument : AKInstrument

// Instrument Properties
@property AKInstrumentProperty *amplitude;

@property (readonly) AKAudio *output;

@end

@interface AKPluckedStringNote : AKNote

// Note properties
@property AKNoteProperty *frequency;
@property AKNoteProperty *pluckPosition;
@property AKNoteProperty *samplePosition;
@property AKNoteProperty *reflectionCoefficient;
@property AKNoteProperty *amplitude;


@end
