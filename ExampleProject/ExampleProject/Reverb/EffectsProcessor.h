//
//  EffectsProcessor.h
//  Objective-C Sound Example
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSInstrument.h"
#import "ToneGenerator.h"

@interface EffectsProcessor : OCSInstrument 

- (id)initWithToneGenerator:(ToneGenerator *) toneGenerator;
- (void)start;

@end
