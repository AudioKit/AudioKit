//
//  AKMicrophone.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 4/4/15.
//  Copyright (c) 2015 AudioKit. All rights reserved.
//

#import "AKFoundation.h"

@interface AKMicrophone : AKInstrument

// Instrument Properties
@property AKInstrumentProperty *amplitude;

// Audio outlet for global effects processing 
@property (readonly) AKAudio *output;

@end


