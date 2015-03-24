//
//  Vibraphone.h
//  AudioKit
//
//  Created by Nicholas Arner on 3/20/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKFoundation.h"

/// An instrument that wraps the vibraphone physical model
@interface Vibraphone : AKInstrument

// Instrument Properties
@property AKInstrumentProperty *amplitude;

// Audio outlet for global effects processing (choose mono or stereo accordingly)
@property (readonly) AKAudio *auxilliaryOutput;

@end

@interface VibraphoneNote : AKNote

// Note properties
@property AKNoteProperty *frequency;
@property AKNoteProperty *amplitude;
@property AKNoteProperty *stickHardness;
@property AKNoteProperty *strikePosition;


@end
