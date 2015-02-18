//
//  ViewController.m
//  HelloWorld
//
//  Created by Aurelius Prochazka on 2/14/15.
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
- (IBAction)toggleSound:(UIButton *)sender {
    if (![sender.titleLabel.text isEqual: @"Stop"]) {
        [instrument play];
        [sender setTitle:@"Stop" forState:UIControlStateNormal];
    } else {
        [instrument stop];
        [sender setTitle:@"Play Sine Wave at 440Hz" forState:UIControlStateNormal];
    }
}

@end
