//
//  EffectsProcessor.h
//  AudioKit Example
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "AKFoundation.h"

@interface EffectsProcessor : AKInstrument 

- (instancetype)initWithAudioSource:(AKAudio *)audioSource;

@property AKInstrumentProperty *reverb;

@end
