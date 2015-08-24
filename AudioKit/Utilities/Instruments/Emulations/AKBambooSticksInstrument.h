//
//  BambooSticks.h
//  AudioKitPlayground
//
//  Created by Nicholas Arner on 3/21/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKFoundation.h"

/// An instrument that wraps the bamboo sticks physical model
@interface AKBambooSticksInstrument : AKInstrument

// Instrument Properties
@property AKInstrumentProperty *amplitude;

// Audio outlet for global effects processing
@property (readonly) AKAudio *output;

@end

@interface AKBambooSticksNote : AKNote

// Note properties
@property AKNoteProperty *count;
@property AKNoteProperty *mainResonantFrequency;
@property AKNoteProperty *firstResonantFrequency;
@property AKNoteProperty *secondResonantFrequency;
@property AKNoteProperty *amplitude;


@end
