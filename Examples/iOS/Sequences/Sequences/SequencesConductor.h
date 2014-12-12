//
//  SequencesConductor.h
//  Sequences
//
//  Created by Aurelius Prochazka on 8/4/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SequencesConductor : NSObject

- (void)playPhraseOfNotesOfDuration:(float)duration;
- (void)playSequenceOfNotePropertiesOfDuration:(float)duration;
- (void)playSequenceOfInstrumentPropertiesOfDuration:(float)duration;

@end
