//
//  ToneGenerator.h
//  AudioKit Example
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "AKFoundation.h"

@interface ToneGenerator : AKInstrument

@property AKInstrumentProperty *toneColor;

@property (readonly) AKAudio *auxilliaryOutput;

@end

// -----------------------------------------------------------------------------
#  pragma mark - Tone Generator Note
// -----------------------------------------------------------------------------

@interface ToneGeneratorNote : AKNote

@property AKNoteProperty *frequency;
@property AKNoteProperty *amplitude;

- (instancetype)initWithFrequency:(float)frequency;

@end