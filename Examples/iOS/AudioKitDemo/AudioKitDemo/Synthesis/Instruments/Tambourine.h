//
//  Tambourine.h
//  AudioKitDemo
//
//  Created by Aurelius Prochazka on 2/15/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKFoundation.h"

@interface Tambourine : AKInstrument
@end

@interface TambourineNote : AKNote

// Note properties
@property AKNoteProperty *intensity;
@property AKNoteProperty *dampingFactor;

- (instancetype)initWithIntensity:(float)intensity dampingFactor:(float)dampingFactor;

@end
