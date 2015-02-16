//
//  FMSynthesizer.h
//  AudioKitDemo
//
//  Created by Aurelius Prochazka on 2/15/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKFoundation.h"

@interface FMSynthesizer : AKInstrument
@end

@interface FMSynthesizerNote : AKNote

// Note properties
@property AKNoteProperty *frequency;
@property AKNoteProperty *color;

- (instancetype)initWithFrequency:(float)frequency color:(float)color;

@end
