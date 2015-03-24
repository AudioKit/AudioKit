//
//  Marimba.h
//  AudioKit
//
//  Created by Nicholas Arner on 3/20/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKFoundation.h"

/// An instrument that wraps the marimba physical model
@interface Marimba : AKInstrument

// Instrument Properties
@property AKInstrumentProperty *amplitude;
@property AKInstrumentProperty *vibratoAmplitude;
@property AKInstrumentProperty *vibratoFrequency;


// Audio outlet for global effects processing (choose mono or stereo accordingly)
@property (readonly) AKAudio *auxilliaryOutput;
//@property (readonly) AKStereoAudio *auxilliaryOutput;

@end

@interface MarimbaNote : AKNote

// Note properties
@property AKNoteProperty *frequency;
@property AKNoteProperty *stickHardness;
@property AKNoteProperty *strikePosition;
@property AKNoteProperty *amplitude;


@end
