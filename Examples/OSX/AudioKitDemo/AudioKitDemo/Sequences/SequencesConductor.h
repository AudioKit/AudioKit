//
//  SequencesConductor.h
//  AudioKitDemo
//
//  Created by Aurelius Prochazka on 2/14/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SequencesConductor : NSObject

- (void)playPhraseOfNotesOfDuration:(float)duration;
- (void)playSequenceOfNotePropertiesOfDuration:(float)duration;
- (void)playSequenceOfInstrumentPropertiesOfDuration:(float)duration;

@end
