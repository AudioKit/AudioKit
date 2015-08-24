//
//  Tambourine.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 2/15/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKFoundation.h"

/// An instrument that wraps the tambourine physical model
@interface AKTambourineInstrument : AKInstrument
@property AKInstrumentProperty *amplitude;
@property (readonly) AKAudio *output;
@end

@interface AKTambourineNote : AKNote

// Note properties
@property AKNoteProperty *dampingFactor;
@property AKNoteProperty *intensity;
@property AKNoteProperty *mainResonantFrequency;
@property AKNoteProperty *firstResonantFrequency;
@property AKNoteProperty *secondResonantFrequency;

- (instancetype)initWithIntensity:(float)intensity dampingFactor:(float)dampingFactor;

@end
