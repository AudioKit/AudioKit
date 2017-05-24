//
//  ViewController.m
//  HelloObjectiveC
//
//  Created by Aurelius Prochazka on 1/27/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

#import "ViewController.h"

@import AudioKit;

@interface ViewController () {
    AKOscillator *oscillator1;
    AKOscillator *oscillator2;
    AKMixer *mixer;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    oscillator1 = [[AKOscillator alloc] init];
    oscillator2 = [[AKOscillator alloc] init];
    mixer = [[AKMixer alloc] init: @[oscillator1, oscillator2]];
    mixer.volume = 0.5;
    AudioKit.output = mixer;
    [AudioKit start];
}

- (IBAction)toggleSound:(UIButton *)sender {
    if (oscillator1.isStarted) {
        [oscillator1 stop];
        [oscillator2 stop];
        [sender setTitle:@"Play Random Sine Waves" forState:UIControlStateNormal];
    } else {
        oscillator1.frequency = ((float)rand() / RAND_MAX) * 660.0 + 220.0;
        oscillator2.frequency = ((float)rand() / RAND_MAX) * 660.0 + 220.0;
        [oscillator1 start];
        [oscillator2 start];
        NSString *title = [NSString stringWithFormat:@"Stop %0.2fHz & %0.2fHz", oscillator1.frequency, oscillator2.frequency];
        [sender setTitle:title forState:UIControlStateNormal];
    }
    [sender setNeedsDisplay];
}

@end
