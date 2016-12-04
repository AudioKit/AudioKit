//
//  AKVariableDelayAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKVariableDelayAudioUnit_h
#define AKVariableDelayAudioUnit_h

#import "AKAudioUnit.h"

@interface AKVariableDelayAudioUnit : AKAudioUnit
@property (nonatomic) float time;
@property (nonatomic) float feedback;
@end

#endif /* AKVariableDelayAudioUnit_h */
