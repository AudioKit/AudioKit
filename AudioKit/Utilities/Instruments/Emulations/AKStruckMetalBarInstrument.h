//
//  StruckMetalBar.h
//  AudioKitPlayground
//
//  Created by Nicholas Arner on 3/21/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKFoundation.h"

/// An instrument that wraps the struck metal bar physical model
@interface AKStruckMetalBarInstrument : AKInstrument

// Instrument Properties
@property AKInstrumentProperty *amplitude;

// Audio outlet for global effects processing
@property (readonly) AKAudio *output;

@end

@interface AKStruckMetalBarNote : AKNote

// Note properties
@property AKNoteProperty *decayTime;
@property AKNoteProperty *dimensionlessStiffness;
@property AKNoteProperty *highFrequencyLoss;
@property AKNoteProperty *strikePosition;
@property AKNoteProperty *strikeVelocity;
@property AKNoteProperty *strikeWidth;
@property AKNoteProperty *leftBoundaryCondition;
@property AKNoteProperty *rightBoundaryCondition;
@property AKNoteProperty *scanSpeed;


@end
