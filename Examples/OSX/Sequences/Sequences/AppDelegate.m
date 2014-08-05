//
//  AppDelegate.m
//  Sequences
//
//  Created by Aurelius Prochazka on 8/3/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//

#import "AppDelegate.h"
#import "SequencesConductor.h"
#import "AKTools.h"

@interface AppDelegate() {
    IBOutlet NSTextField *durationValue;
    IBOutlet NSSlider *durationSlider;
    
    SequencesConductor *conductor;
}
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    conductor = [[SequencesConductor alloc] init];
}

- (float)getDuration {
    return [AKTools scaleValueFromSlider:durationSlider minimum:0.05 maximum:0.2];
}

- (IBAction)playSequenceOfNotes:(id)sender {
    [conductor playSequenceOfNotesOfDuration:[self getDuration]];
}
- (IBAction)playSequenceOfNoteProperties:(id)sender {
    [conductor playSequenceOfNotePropertiesOfDuration:[self getDuration]];
}
- (IBAction)playSequenceOfInstrumentProperties:(id)sender {
    [conductor playSequenceOfInstrumentPropertiesOfDuration:[self getDuration]];
}
- (IBAction)moveDurationSlider:(id)sender
{
    float duration  = [AKTools scaleValueFromSlider:durationSlider minimum:0.05 maximum:0.2];
    [durationValue setStringValue:[NSString stringWithFormat:@"%g", duration]];
}

@end
