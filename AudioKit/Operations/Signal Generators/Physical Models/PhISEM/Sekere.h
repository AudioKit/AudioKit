//
//  Sekere.h
//  AudioKitPlayground
//
//  Created by Nicholas Arner on 3/21/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKFoundation.h"

@interface Sekere : AKInstrument

// Instrument Properties
@property AKInstrumentProperty *amplitude;

// Audio outlet for global effects processing (choose mono or stereo accordingly)
@property (readonly) AKAudio *auxilliaryOutput;

@end

@interface SekereNote : AKNote

// Note properties
@property AKNoteProperty *count;
@property AKNoteProperty *dampingFactor;
@property AKNoteProperty *amplitude;


@end
