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
    AKOscillator *oscillator;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    oscillator = [[AKOscillator alloc] init];
    AudioKit.output = oscillator;
    [AudioKit start];
}

- (IBAction)toggleSound:(UIButton *)sender {

    if (oscillator.isStarted) {
        [oscillator stop];
        [sender setTitle:@"Play Sine Wave" forState:UIControlStateNormal];
    } else {
        oscillator.amplitude = ((float)rand() / RAND_MAX) * 0.5 + 0.5;
        oscillator.frequency = ((float)rand() / RAND_MAX) * 660.0 + 220.0;
        [oscillator start];
        NSString *title = [NSString stringWithFormat:@"Stop Sine Wave at %0.2fHz", oscillator.frequency];
        [sender setTitle:title forState:UIControlStateNormal];
    }
    [sender setNeedsDisplay];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
