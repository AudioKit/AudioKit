//
//  AKVCOscillatorInstrument.h
//  AudioKitPlayground
//
//  Created by Aurelius Prochazka on 3/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKFoundation.h"

/// An instrument for the Voltage-controlled oscillator operation
@interface AKVCOscillatorInstrument : AKInstrument
@property AKInstrumentProperty *amplitude;
// Audio outlet for global effects processing
@property (readonly) AKAudio *output;
@end



@interface AKVCOscillatorNote : AKNote
@property AKNoteProperty *frequency;
@property AKNoteProperty *waveformType;
@end