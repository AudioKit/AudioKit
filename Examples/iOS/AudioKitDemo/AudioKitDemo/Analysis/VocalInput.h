//
//  VocalInput.h
//  AudioKitDemo
//
//  Created by Aurelius Prochazka on 2/14/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKFoundation.h"

@interface VocalInput : AKInstrument

// Audio outlet for global effects processing
@property (readonly) AKAudio *auxilliaryOutput;

@end

