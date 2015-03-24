//
//  PluckedString.h
//  AudioKit
//
//  Created by Nicholas Arner on 3/21/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKFoundation.h"

/// An instrument that wraps the plucked string physical model
@interface PluckedString : AKInstrument

// Instrument Properties
@property AKInstrumentProperty *amplitude;

// Audio outlet for global effects processing (choose mono or stereo accordingly)
@property (readonly) AKAudio *auxilliaryOutput;
//@property (readonly) AKStereoAudio *auxilliaryOutput;

@end

@interface PluckedStringNote : AKNote

// Note properties
@property AKNoteProperty *frequency;
@property AKNoteProperty *pluckPosition;
@property AKNoteProperty *samplePosition;
@property AKNoteProperty *reflectionCoefficient;
@property AKNoteProperty *amplitude;


@end
