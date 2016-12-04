//
//  AKOperationGeneratorAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#ifndef AKOperationGeneratorAudioUnit_h
#define AKOperationGeneratorAudioUnit_h

#import "AKAudioUnit.h"

@interface AKOperationGeneratorAudioUnit : AKAudioUnit
@property (nonatomic) NSArray *parameters;
- (void)setSporth:(NSString *)sporth;
- (void)trigger:(int)trigger;
@end

#endif /* AKOperationGeneratorAudioUnit_h */
