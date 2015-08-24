//
//  Sekere.h
//  AudioKitPlayground
//
//  Created by Nicholas Arner on 3/21/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKFoundation.h"

@interface AKSekereInstrument : AKInstrument

// Instrument Properties
@property AKInstrumentProperty *amplitude;

// Audio outlet for global effects processing 
@property (readonly) AKAudio *output;

@end

@interface AKSekereNote : AKNote

// Note properties
@property AKNoteProperty *count;
@property AKNoteProperty *dampingFactor;
@property AKNoteProperty *amplitude;

@end
