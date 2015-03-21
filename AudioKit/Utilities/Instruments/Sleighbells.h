//
//  Sleighbells.h
//  AudioKitPlayground
//
//  Created by Nicholas Arner on 3/21/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKFoundation.h"

@interface Sleighbells : AKInstrument

// Instrument Properties
@property AKInstrumentProperty *amplitude;

// Audio outlet for global effects processing (choose mono or stereo accordingly)
@property (readonly) AKAudio *auxilliaryOutput;
//@property (readonly) AKStereoAudio *auxilliaryOutput;

@end

@interface SleighbellsNote : AKNote

// Note properties
@property AKNoteProperty *intensity;
@property AKNoteProperty *dampingFactor;
@property AKNoteProperty *mainResonantFrequency;
@property AKNoteProperty *firstResonantFrequency;
@property AKNoteProperty *secondResonantFrequency;
@property AKNoteProperty *amplitude;


@end
