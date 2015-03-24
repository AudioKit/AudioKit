//
//  Stick.h
//  AudioKit
//
//  Created by Nicholas Arner on 3/21/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKFoundation.h"

/// An instrument that wraps the stick physical model
@interface Stick : AKInstrument

// Instrument Properties
@property AKInstrumentProperty *amplitude;

// Audio outlet for global effects processing (choose mono or stereo accordingly)
@property (readonly) AKAudio *auxilliaryOutput;

@end

@interface StickNote : AKNote

// Note properties
@property AKNoteProperty *intensity;
@property AKNoteProperty *dampingFactor;
@property AKNoteProperty *amplitude;


@end
