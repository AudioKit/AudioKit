//
//  AKOperationEffectAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#ifndef AKOperationEffectAudioUnit_h
#define AKOperationEffectAudioUnit_h

#import "AKAudioUnit.h"

@interface AKOperationEffectAudioUnit : AKAudioUnit
@property (nonatomic) NSArray *parameters;
- (void)setSporth:(NSString *)sporth;
@end

#endif /* AKOperationEffectAudioUnit_h */
