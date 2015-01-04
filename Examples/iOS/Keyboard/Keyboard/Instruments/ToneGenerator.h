//
//  ToneGenerator.h
//  AudioKit Example
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "AKFoundation.h"

@interface ToneGenerator : AKInstrument

@property (nonatomic, strong) AKInstrumentProperty *toneColor;

@property (readonly) AKAudio *auxilliaryOutput;

@end

// -----------------------------------------------------------------------------
#  pragma mark - Tone Generator Note
// -----------------------------------------------------------------------------

@interface ToneGeneratorNote : AKNote

@property (nonatomic, strong) AKNoteProperty *frequency;
@property (nonatomic, strong) AKNoteProperty *amplitude;

- (instancetype)initWithFrequency:(float)frequency;

@end