//
//  AppDelegate.m
//  Sequences
//
//  Created by Aurelius Prochazka on 8/3/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

#import "AppDelegate.h"
#import "SequencesConductor.h"
#import "AKTools.h"

@implementation AppDelegate
{
    IBOutlet NSTextField *durationValue;
    IBOutlet NSSlider *durationSlider;
    
    SequencesConductor *conductor;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    conductor = [[SequencesConductor alloc] init];
}

- (float)getDuration {
    return [AKTools scaleValueFromSlider:durationSlider minimum:0.05 maximum:0.2];
}

- (IBAction)playPhrase:(id)sender
{
    [conductor playPhraseOfNotesOfDuration:[self getDuration]];
}

- (IBAction)playSequenceOfNoteProperties:(id)sender
{
    [conductor playSequenceOfNotePropertiesOfDuration:[self getDuration]];
}

- (IBAction)playSequenceOfInstrumentProperties:(id)sender
{
    [conductor playSequenceOfInstrumentPropertiesOfDuration:[self getDuration]];
}

- (IBAction)moveDurationSlider:(id)sender
{
    float duration  = [AKTools scaleValueFromSlider:durationSlider minimum:0.05 maximum:0.2];
    [durationValue setStringValue:[NSString stringWithFormat:@"%g", duration]];
}

@end
