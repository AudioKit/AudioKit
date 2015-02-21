//
//  ViewController.m
//  HelloWorld
//
//  A simple intrument and UI to make sure your set up is working on OSX.
//
//  Created by Aurelius Prochazka on 2/13/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "ViewController.h"

// STEP 1 : Import AudioKit's suite of classes
#import "AKFoundation.h"

@implementation ViewController {
    // STEP 2 : Set up an instance variable for the instrument
    AKInstrument *instrument;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // STEP 3 : Define the instrument as a simple oscillator
    instrument = [AKInstrument instrument];
    [instrument setAudioOutput:[AKOscillator oscillator]];
    
    // STEP 4 : Add the instrument to the orchestra
    [AKOrchestra addInstrument:instrument];
    
}

// STEP 5 : React to a button press on the Storyboard UI by
//          playing or stopping the instrument and updating the button text.
- (IBAction)toggleSound:(NSButton *)sender {

    if (![sender.title isEqual: @"Stop"]) {
        [instrument play];
        sender.title = @"Stop";
    } else {
        [instrument stop];
        sender.title = @"Play Sine Wave at 440Hz";
    }
}



@end
