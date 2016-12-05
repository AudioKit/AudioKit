//
//  AKFormantFilterAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKFormantFilterAudioUnit_h
#define AKFormantFilterAudioUnit_h

#import "AKAudioUnit.h"

@interface AKFormantFilterAudioUnit : AKAudioUnit
@property (nonatomic) float x;
@property (nonatomic) float y;
@end

#endif /* AKFormantFilterAudioUnit_h */
